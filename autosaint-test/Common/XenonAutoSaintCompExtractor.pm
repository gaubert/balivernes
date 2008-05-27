package AutoSaintCompExtractor;

use strict;
use DBI;
use Data::Dumper;
use Common::Util;
use Common::Extractor;

#inheritance
use base qw(Extractor);

my $COMP_DEBUG = 0;

# Class Members
my $GETREFIDSFROMSTATIONIDS = "select distinct gsa.SAMPLE_REF_ID from rmsuser.gards_sample_aux gsa,rmsuser.gards_sample gs where gsa.sample_id=gs.sample_id and gs.station_code in (##VALS##) and gs.SPECTRAL_QUALIFIER=\'FULL\' and gs.data_type=\'S\'";

my $GETREFIDSFROMSAMPLEIDS = "select distinct gsa.SAMPLE_REF_ID from rmsuser.gards_sample_aux gsa,rmsuser.gards_sample gs where gsa.sample_id=gs.sample_id and gs.sample_id in (##VALS##) and gs.SPECTRAL_QUALIFIER=\'FULL\' and gs.data_type=\'S\'";


# Class Methods

# Constructor


sub new 
{
  my($class,@more) = @_;
  my $self     = $class->SUPER::new(@more);

  bless ($self,$class);
}

# Destructor
sub DESTROY 
{

} 

# retrieve and store on file sample_ids found from a list of ref_ids
sub _get_sample_id_from_ref_ids
{

  my ($self,$force,$loc_dbh,$ref_ids,@more) = @_;

  Util::create_dir("$self->{directory}/cache");

  my $file = "$self->{directory}/cache/sample_ids.yaml";

  print "Get sample_ids\n";

  # no force so check if there is already a file containing the ref_ids
  if (!$force)
  {
    if (-f $file)
    {
       print "Get sample_ids: Read sample_ids from a file $file\n";
       #revive list
       use YAML;

       my @h = @{YAML::LoadFile($file)};
       
       return @h;
    }
  }

  my $size_ref_ids = @$ref_ids;
  my $sth;
  my $end_index=0;

  # increment of 800 elements
  my $inc = 200;

  # to get retrieved sample ID before to store them
  my @dummy_list = ();

  for (my $i=0 ; $i < $size_ref_ids ; $i = $i + $inc)
  {
    # slice list of each $inc ref_ids because it could be too big
    my $end_index = (($i+$inc-1) >= $size_ref_ids) ? $size_ref_ids-1 : ($i+$inc-1);

    my $str_sample_ref_ids = join(', ', map { $loc_dbh->quote($_) } @$ref_ids[$i..$end_index]);

    print "Get sample_ids:Read sample_ids from database \n";

    my $sql = "select distinct concat(concat(to_char(gsa.sample_ref_id),'-'),to_char(gs.sample_id)) from rmsuser.gards_sample_aux gsa,rmsuser.gards_sample gs where gsa.sample_id=gs.sample_id and gsa.sample_ref_id in ($str_sample_ref_ids) and gs.SPECTRAL_QUALIFIER=\'FULL\' and gs.data_type=\'S\'";

    $sth = $loc_dbh->prepare($sql);

    print "Get sample_ids:Execute sql request to find sample_ids\n";

    print "Sample_id Request = $sql\n" if $COMP_DEBUG;

    $sth->execute();

    # fill up dummy_list
    my $arr_ref;
    while( $arr_ref = $sth->fetchrow_arrayref())
    {
      # add first elem in array
      push(@dummy_list,@$arr_ref);
    }
  }

  if (@dummy_list > 0)
  {
    print "Get sample_ids: Store sample_ids values on file $file \n";

    # store list of ref_ids as sample_ref_id.perst (yaml or dump)
    my $YAML_HANDLE;
    open($YAML_HANDLE,">$file") || die("Could not open file $file");

    use YAML;
    print {$YAML_HANDLE} Dump \@dummy_list;
  }

  print "Leave Get sample_ids\n";

  return @dummy_list;
}

# start from sampleids or stationids and return ref_ids 
sub _get_sample_ref_ids
{

  my ($self,$type,$ids_list_ref,$no_cache,$loc_dbh,@more) = @_;

  Util::create_dir("$self->{directory}/cache");

  my $file = "$self->{directory}/cache/sample_ref_id.yaml";

  print "Get sample reference ids\n";

  # no_cache is false so check if there is already a file containing the ref_ids
  if ($no_cache == 0)
  {
    if (-f $file)
    {
       print "Use Cached data\n";
       print "Get sample_refs_ids: Read ref_ids from cache file $file\n";
       #revive list
       use YAML;

       my @h = @{YAML::LoadFile($file)};
       
       return @h;
    }
  }

  print "Get sample_refs_ids: Read ref_ids from database \n";

  # if a loc_dbh is passed then use it otherwise use the default one
  $loc_dbh = $self->{dbh} unless (defined $loc_dbh);

  # set date format
  my $sth =  $loc_dbh->prepare("alter session set NLS_DATE_FORMAT=\'DD-MON-YYYY HH:MI:SS\'");

  $sth->execute();


  # get the reference ids of each of the sample_ids issued for this stations 

  my $ids_str = join(',',@$ids_list_ref);

  my $sql = "";

  if ($type eq "STATIONIDS")
  {
    $sql = $GETREFIDSFROMSTATIONIDS;
  }
  elsif ($type eq "SAMPLEIDS")
  {
    $sql = $GETREFIDSFROMSAMPLEIDS;
  }
  else
  {
    die "Error: $type is an unknown type. Only STATIONIDS and SAMPLEIDS is supported";
  }

  # substitue ##VALS## with real values
  $sql =~ s/##VALS##/$ids_str/g;


  print "Get sample_refs_ids: sql request = $sql\n" if $COMP_DEBUG;

  $sth = $loc_dbh->prepare($sql);

  print "Get sample_refs_ids: Execute initial sql request to find sample_ref_ids\n";
  $sth->execute();

  my $arr_ref;
  my @dummy_list = ();
  while( $arr_ref = $sth->fetchrow_arrayref())
  {
    # add first elem in array
    push(@dummy_list,@$arr_ref[0]);
  }

  die "Error Get sample_refs_ids: No sample_ref_ids retrieved. Please check the list of sample_ids or stations passed as arguments \n" if (@dummy_list == 0);

  print "Get sample_refs_ids: Store ref_ids values on file $file \n" if (@dummy_list > 0);

  # store list of ref_ids as sample_ref_id.perst (yaml or dump)
  my $YAML_HANDLE;
  open($YAML_HANDLE,">$file") || die("Could not open file $file");

  use YAML;
  print {$YAML_HANDLE} Dump \@dummy_list;

  return @dummy_list;
}

# create a hash table containing all necessary reference data
sub extract_comparison_data
{
  my ($self,$force,$ref_sample_ids_list_ref,$l_dbh,@more) = @_;

  #die "not connected to the primary database" unless $self->connected();
  die "undefined force" unless defined $force;

  # prepare request
  my $sql;

  # check and create dir where to put the data
  Util::create_dir($self->{directory});

  my $arr_ref = undef;

  # if a loc_dbh is passed then use it otherwise use the default one
  $l_dbh = $self->{dbh} unless (defined $l_dbh);

  # get corresponding sample_ids
  my @arr_sample_ids = $self->_get_sample_id_from_ref_ids($force,$l_dbh,$ref_sample_ids_list_ref);

  print "Extract comparison data: execute sql requests to get the necessary data\n";

  #prepare statements
  my $get_energy_cal     = $l_dbh->prepare("select coeff1,coeff2,coeff3,coeff4,coeff5,coeff6,coeff7,coeff8 from rmsuser.gards_energy_cal where sample_id=?");

  my $get_resolution_cal  = $l_dbh->prepare("select coeff1,coeff2,coeff3,coeff4,coeff5,coeff6,coeff7,coeff8 from rmsuser.gards_resolution_cal where sample_id=?");

  my $get_efficiency_cal = $l_dbh->prepare("select coeff1,coeff2,coeff3,coeff4,coeff5,coeff6,coeff7,coeff8 from rmsuser.gards_efficiency_cal where sample_id=?");


  my $get_peaks_info = $l_dbh->prepare("select centroid, centroid_err, energy, energy_err, back_count, back_uncer, fwhm, fwhm_err, area, area_err, counts_sec, counts_sec_err,efficiency, eff_error, back_channel, lc from rmsuser.gards_peaks_orig where sample_id=?");

  my $get_nucl_lines_ided = $l_dbh->prepare("select name,energy,energy_err,activity,activ_err from rmsuser.gards_nucl_lines_ided where sample_id=? and peak > 0");

  my $get_nucl_ided = $l_dbh->prepare("select name,ave_activ,ave_activ_err,activ_key,activ_key_err,mda,mda_err,activ_decay,activ_decay_err from rmsuser.gards_nucl_ided where sample_id=? and activ_key > 0");

  my $peaks_ided_info = $l_dbh->prepare("select max(peak_id),count(distinct gl.peak)-max(peak_id) from rmsuser.gards_nucl_lines_ided gl, rmsuser.gards_peaks gp where gl.sample_id=gp.sample_id and gl.sample_id=?");

  my $category_gards_sample_cat    = $l_dbh->prepare("select name,category from rmsuser.gards_sample_cat where sample_id=?");

  my $category_gards_sample_status = $l_dbh->prepare("select category,auto_category from rmsuser.gards_sample_status where sample_id=?");

  # Columns informations to be inserted in arrays
  my @p_peaks_desc = ("centroid", "centroid_err", "energy", "energy_err", "back_count", "back_uncer", "fwhm", "fwhm_err","area" , "area_err", "counts_sec", "counts_sec_err","efficiency", "eff_error", "back_channel", "lc");

  my @p_nucl_lines_ided_desc = ("name","energy","energy_err","activity","activ_err");

  my @p_nucl_ided_desc = ("name","ave_activ","ave_activ_err","activ_key","activ_key_err","mda","mda_err","activ_decay","activ_decay_err");

  my @p_gards_sample_cat = ("name","category");

  my $data;
  my $sampleID;
  my $sample_refID;

  foreach my $tempo (@arr_sample_ids)
  {
     ($sample_refID,$sampleID) = split(/-/, $tempo);

     print "\nExtract comparison data: Get data for ref_id $sample_refID, Local sample_id = $sampleID\n";

     my %sample = ();

     # Add sample ref id
     $sample{'sample_ref_id'}   = $sample_refID;
     $sample{'local_sample_id'} = $sampleID;
    
     #---
     # CALIBRATION
     #---

     # get energy_cal
     $get_energy_cal->execute(($sampleID));

     # get line retrieved
     $data = $get_energy_cal->fetchrow_hashref();

     $sample{"energy_cal"} = $data;

     # get resolution_cal
     $get_resolution_cal->execute(($sampleID));

     # get line retrieved
     $data = $get_resolution_cal->fetchrow_hashref();
     
     $sample{"resolution_cal"} = $data;  

     # get efficiency_cal
     $get_efficiency_cal->execute(($sampleID));

     # get line retrieved
     $data = $get_efficiency_cal->fetchrow_hashref();
     
     $sample{"efficiency_cal"} = $data;  

     #---
     # PEAKS Info
     #---
 
     $get_peaks_info->execute(($sampleID)); 

     my @peaks_data = ();

     # add of the description as line 0 of the array 
     push(@peaks_data,\@p_peaks_desc);     

     while ($data = $get_peaks_info->fetchrow_arrayref())
     {
        my @p_data = ();

        push(@p_data,@$data);
        push(@peaks_data,\@p_data);   
     }    

     $sample{"peaks_data"} = \@peaks_data;

     #---
     # NUCLIDE Identification
     #---
     $get_nucl_lines_ided->execute(($sampleID));   

     my @line_ided_data = ();

     # add of the description as line 0 of the array 
     push(@line_ided_data, \@p_nucl_lines_ided_desc);

     while ($data = $get_nucl_lines_ided->fetchrow_arrayref())
     {
        my @l_data = ();

        push(@l_data,@$data);
        push(@line_ided_data,\@l_data);   
     }    
     $sample{"nucl_line_ided_data"} = \@line_ided_data;

     $get_nucl_ided->execute(($sampleID));   

     my @ided_data = ();

     # add of the description as line 0 of the array 
     push(@ided_data, \@p_nucl_ided_desc);

     while ($data = $get_nucl_ided->fetchrow_arrayref())
     {
        my @l_data = ();

        push(@l_data,@$data);
        push(@ided_data,\@l_data);   
     }    
     $sample{"nucl_ided_data"} = \@ided_data;
     
     #get peaks ided and found   
     $peaks_ided_info->execute(($sampleID));

     $data = $peaks_ided_info->fetchrow_hashref();

     $sample{"peaks_identified_and_found"} = $data;

     #---
     # Category
     #---
     $category_gards_sample_cat->execute(($sampleID));   

     my @categories_sample = ();

     # add of the description as line 0 of the array 
     push(@categories_sample, \@p_gards_sample_cat);

     while ($data = $category_gards_sample_cat->fetchrow_arrayref())
     {
        my @c_data = ();

        push(@c_data,@$data);
        push(@categories_sample,\@c_data);   
     }    
     $sample{"categories_sample_cat"} = \@categories_sample;

     $category_gards_sample_status->execute(($sampleID));   

     $data = $category_gards_sample_status->fetchrow_hashref();

     $sample{"categories_sample_status"} = $data;

     print "Extract comparison data: Store data for $sample_refID on $self->{directory}/$sample_refID.yaml\n";

     my $YAML_HANDLE;
     open($YAML_HANDLE,">$self->{directory}/$sample_refID.yaml");

     use YAML;
     print {$YAML_HANDLE} Dump \%sample;

 }
}

sub get_autosaint_data_to_compare_from_sample_ids
{
  my ($self,$sample_ids_list_ref,$no_cache,@more) = @_;

  ## get referenceIDs
  my @ref_ids = $self->_get_sample_ref_ids("SAMPLEIDS",$sample_ids_list_ref,$no_cache);

  $self->extract_comparison_data($no_cache,\@ref_ids);
}


sub get_autosaint_data_to_compare_from_stations_ids
{
  my ($self,$stations_list_ref,$no_cache,@more) = @_;

  my @ref_ids = $self->_get_sample_ref_ids("STATIONIDS",$stations_list_ref,$no_cache);

  $self->extract_comparison_data($no_cache,\@ref_ids);
}

# get reference_ids from fogo
sub get_reference_data
{
  my ($self,$no_cache,@more) = @_;

  # get referenceIDs
  my @list = ('\'AUP08\'','\'CAP16\'','\'DEP33\'','\'FRP27\'','\'SEP63\'');

  # get connection on fogo 
  print "\nGet Connection on fogo\n";
  my $maui_dbh = $self->_get_connection_on_db("fogo","rmsuser","rmsuser");
  
  # get connection on idcdev
  print "\nGet Connection on idcdev\n";

  my $idcdev_dbh = $self->_get_connection_on_db("idcdev","centre","data");

  # get ref_ids from idcdev 
  print "\nGet sample_ref_ids from stations\n";

  my @ref_ids = $self->_get_sample_ref_ids("STATIONIDS",\@list,$no_cache,$idcdev_dbh);

  # get comparison data from maui
  $self->extract_comparison_data($no_cache,\@ref_ids,$maui_dbh);

  print "\nExtraction Done\n";
}

1;
__END__

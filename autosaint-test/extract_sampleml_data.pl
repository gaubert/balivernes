#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use Pod::Usage;
use File::Path;
use Data::Dumper;
use Common::Extractor;

#
# Release number.
#
my $RELEASE         = '0.5';

# Default Values
my $OVERWRITE       = 1;
my $DATATYPE        = 'SPECTRUM';
my $DIR             = '/tmp/autosaintTests';
my $USER            = 'centre';
my $PASS            = 'data';
my $DB              = 'idcdev.ctbto.org';
my $TRANSFORMATIONS = undef;
my %TRANSHASH       = ();

#my $USER            = 'RMSMAN';
#my $PASS            = 'RMSMAN';
#my $DB              = '172.27.71.102';

# necessary options
my $SAMPLEID        = undef;

#
#  Parse command line arguments. Overide global values 
#
parseCommandLineArguments();

#
#  Do more stuff ..
#
execute();

#
#  All done
#
exit;

# functions

=head2 parseCommandLineArguments

  Parse the arguments specified upon the command line.

=cut

sub parseCommandLineArguments
{
    my $HELP        = 0;   # Show help overview.
    my $MANUAL      = 0;   # Show manual
    my $VERSION     = 0;   # Show version number and exit.

    #  Parse options.
    #
    my $result = GetOptions(
                            "help",                    => \$HELP,
                            "manual",                  => \$MANUAL,
                            "version",                 => \$VERSION,
                            'directory|dir=s'          => \$DIR,
                            'user|u=s'                 => \$USER,
                            'password|p=s'             => \$PASS,
                            'database|db=s'            => \$DB,
                            'sampleID|sid=s'           => \$SAMPLEID,
                            'transform|trans=s'        => \$TRANSFORMATIONS,
                            'dataType|dt:s'            => \$DATATYPE,
                            'overwrite'                => \$OVERWRITE,
                           ) or pod2usage(1);

    pod2usage(1) if $HELP;
    pod2usage(-verbose => 2 ) if $MANUAL;

    if (! defined $SAMPLEID)
    {
       print STDERR "Error: need a sampleID (ex: -sid 153931 or -sid 159698)\n"; 
       pod2usage(1);
    }

    if ( defined $TRANSFORMATIONS)
    {
       #print "Transformation $TRANSFORMATIONS\n";
       %TRANSHASH = parse_transformations($TRANSFORMATIONS);
    }

    if ( $VERSION )
    {
    my $REVISION      = '$Id: main,v0.5 2008/02/07 10:00:00 guillaume Exp $';
    $VERSION = join (' ', (split (' ', $REVISION))[2]);
    $VERSION =~ s/,v\b//;
    $VERSION =~ s/(\S+)$/$1/;

    print "main release $RELEASE - CVS: $VERSION\n";
    exit;
    }
}

sub parse_transformations
{
  my ($transformations,@rest) = @_;

  my @directives = split(/,/, $transformations);
  my %trans = ();

  my $nb_directives = scalar(@directives);
  print "Found  $nb_directives directives for transformation\n";
  
  # Error message
  my $ErrText = "\nIt should follow TABLE.COLUMN:regexp.\nFor example FILEPRODUCT.DIR:s{/home/misc/rmsops}{/home/aubert}g\n";

  # cpt for the directives
  my $cpt = 0;

  foreach (@directives) 
  {
     print "Process directive: $directives[$cpt]\n";

     my ($key,$val) = split(/:/,$_);

     die "Error: Bad transformation directive syntax.".$ErrText unless (defined $val);

     my ($table,$col) = split(/\./,$key);

     die "No table name defined in $directives[$cpt].".$ErrText unless (defined $table);

     die "No column name defined in $directives[$cpt].".$ErrText unless (defined $col);

     if (defined $trans{$table})
     {
        # add col in table
        $trans{$table}{$col} = $val;
     }
     else
     {
       #not yet defined create internal hash
       $trans{$table} = {$col => $val}; 
     }

     $cpt++;
  } 

  #print "In parse_transformation\n";
  #print Dumper(%trans);
  #print "EOF parse_transformation\n";

  return %trans;
}


# functions

=head2 execute

  extract all the necessary data to create a sample environement for autosaint

=cut

sub execute
{

my $ex = Extractor->new($DB,$USER,$PASS,"$DIR/$SAMPLEID");

$ex->connect();
   
print "------------------ Get Static Data ------------------\n\n";

print "extract IDCX.FPDESCRIPTION\n";

$ex->extract('IDCX.FPDESCRIPTION','FPDESCRIPTION',\%TRANSHASH);

print "extract RMSMAN.GARDS_DETECTORS\n";

$ex->extract('RMSMAN.GARDS_DETECTORS','GARDS_DETECTORS',\%TRANSHASH);

print "extract RMSMAN.GARDS_NUCL_LIB\n";

$ex->extract('RMSMAN.GARDS_NUCL_LIB','GARDS_NUCL_LIB',\%TRANSHASH);

print "extract RMSMAN.GARDS_NUCL_LINES_LIB\n";

$ex->extract('RMSMAN.GARDS_NUCL_LINES_LIB','GARDS_NUCL_LINES_LIB',\%TRANSHASH);

print "extract RMSMAN.GARDS_PRODUCT_TYPE\n";

$ex->extract('RMSMAN.GARDS_PRODUCT_TYPE','GARDS_PRODUCT_TYPE',\%TRANSHASH);

print "extract RMSMAN.GARDS_FLAGS\n";

$ex->extract('RMSMAN.GARDS_FLAGS','GARDS_FLAGS',\%TRANSHASH);

print "extract RMSMAN.GARDS_RELEVANT_NUCLIDES\n";

$ex->extract('RMSMAN.GARDS_RELEVANT_NUCLIDES','GARDS_RELEVANT_NUCLIDES',\%TRANSHASH);

print "extract RMSMAN.GARDS_STATIONS\n";

$ex->extract('RMSMAN.GARDS_STATIONS','GARDS_STATIONS',\%TRANSHASH);

print "extract RMSMAN.GARDS_CAT_TEMPLATE\n";

$ex->extract('RMSMAN.GARDS_CAT_TEMPLATE','GARDS_CAT_TEMPLATE',\%TRANSHASH);

print "extract RMSMAN.GARDS_PRODUCT\n";

$ex->extract('RMSMAN.GARDS_PRODUCT','GARDS_PRODUCT',\%TRANSHASH);

print "\n\n------------------ Get Dynamic Data ------------------\n\n";

print "extract part of IDCX.FILEPRODUCT\n";

# get data for TYPEID=29 and TYPEID=36 (SPECTRUM and B_SPECTRUM)
#$ex->extract('IDCX.FILEPRODUCT','FILEPRODUCT','select DIR, DFILE, FOFF, DSIZE from IDCX.FIlEPRODUCT fprod, IDCX.FPDESCRIPTION fpdesc where fpdesc.PRODTYPE=\'SPECTRUM\' or fpdesc.PRODTYPE=\'B_SPECTRUM\'');

# just get SPECTRUM data
#$ex->extract('IDCX.FILEPRODUCT','FILEPRODUCT',\%TRANSHASH,'select fprod.* from IDCX.FIlEPRODUCT fprod, IDCX.FPDESCRIPTION fpdesc where fpdesc.typeid=fprod.typeid and CHAN=? and fpdesc.PRODTYPE=?',$SAMPLEID,$DATATYPE);
$ex->extract('IDCX.FILEPRODUCT','FILEPRODUCT',\%TRANSHASH,'select fprod.* from IDCX.FIlEPRODUCT fprod where CHAN=?',$SAMPLEID);

print "extract RMSMAN.GARDS_SAMPLE_DATA \n";
$ex->extract('RMSMAN.GARDS_SAMPLE_DATA','GARDS_SAMPLE_DATA',\%TRANSHASH,'select * from RMSMAN.GARDS_SAMPLE_DATA GSD where DETECTOR_ID = (select DETECTOR_ID from RMSMAN.GARDS_SAMPLE_DATA where SAMPLE_ID=?)',$SAMPLEID);

print "extract RMSMAN.GARDS_SAMPLE_FLAGS \n";
$ex->extract('RMSMAN.GARDS_SAMPLE_FLAGS','GARDS_SAMPLE_FLAGS',\%TRANSHASH,'select * from RMSMAN.GARDS_SAMPLE_FLAGS where SAMPLE_ID=?',$SAMPLEID);

print "extract RMSMAN.GARDS_SAMPLE_STATUS \n";
#original request
$ex->extract('RMSMAN.GARDS_SAMPLE_STATUS','GARDS_SAMPLE_STATUS',\%TRANSHASH,'select GSS.* from RMSMAN.GARDS_SAMPLE_DATA GSD, RMSMAN.GARDS_SAMPLE_STATUS GSS where GSD.SAMPLE_ID=GSS.SAMPLE_ID AND DETECTOR_ID = (select DETECTOR_ID from RMSMAN.GARDS_SAMPLE_DATA where SAMPLE_ID=?)',$SAMPLEID);

print "extract RMSMAN.GARDS_SPECTRUM\n";
$ex->extract('RMSMAN.GARDS_SPECTRUM','GARDS_SPECTRUM',\%TRANSHASH,'select GSS.* from RMSMAN.GARDS_SAMPLE_DATA GSD, RMSMAN.GARDS_SPECTRUM GSS where GSD.SAMPLE_ID=GSS.SAMPLE_ID AND DETECTOR_ID = (select DETECTOR_ID from RMSMAN.GARDS_SAMPLE_DATA where SAMPLE_ID=?)',$SAMPLEID);

print "extract RMSMAN.GARDS_SAMPLE_AUX \n";
$ex->extract('RMSMAN.GARDS_SAMPLE_AUX','GARDS_SAMPLE_AUX',\%TRANSHASH,'select GSS.* from RMSMAN.GARDS_SAMPLE_DATA GSD, RMSMAN.GARDS_SAMPLE_AUX GSS where GSD.SAMPLE_ID=GSS.SAMPLE_ID AND DETECTOR_ID = (select DETECTOR_ID from RMSMAN.GARDS_SAMPLE_DATA where SAMPLE_ID=?)',$SAMPLEID);

print "extract RMSMAN.gards_sample_cat \n";
$ex->extract('RMSMAN.GARDS_SAMPLE_CAT','GARDS_SAMPLE_CAT',\%TRANSHASH,'select GSS.* from RMSMAN.GARDS_SAMPLE_DATA GSD, RMSMAN.GARDS_SAMPLE_CAT GSS where GSD.SAMPLE_ID=GSS.SAMPLE_ID AND DETECTOR_ID = (select DETECTOR_ID from RMSMAN.GARDS_SAMPLE_DATA where SAMPLE_ID=?)',$SAMPLEID);

print "extract Calibration Info \n";

print "extract RMSMAN.GARDS_ENERGY_CAL \n";
$ex->extract('RMSMAN.GARDS_ENERGY_CAL','GARDS_ENERGY_CAL',\%TRANSHASH,'select GES.* from RMSMAN.GARDS_ENERGY_CAL GES, RMSMAN.GARDS_SAMPLE_DATA GSD where GES.sample_id = GSD.sample_id AND GSD.DETECTOR_ID = (select DETECTOR_ID from RMSMAN.GARDS_SAMPLE_DATA where SAMPLE_ID=?)',$SAMPLEID);

print "extract RMSMAN.GARDS_RESOLUTION_CAL \n";
$ex->extract('RMSMAN.GARDS_RESOLUTION_CAL','GARDS_RESOLUTION_CAL',\%TRANSHASH,'select * from RMSMAN.GARDS_RESOLUTION_CAL where SAMPLE_ID=?',$SAMPLEID);

print "extract RMSMAN.GARDS_EFFICIENCY_CAL \n";
$ex->extract('RMSMAN.GARDS_EFFICIENCY_CAL','GARDS_EFFICIENCY_CAL',\%TRANSHASH,'select * from RMSMAN.GARDS_EFFICIENCY_CAL where SAMPLE_ID=?',$SAMPLEID);

print "extract RMSMAN.GARDS_EFFICIENCY_PAIRS \n";
$ex->extract('RMSMAN.GARDS_EFFICIENCY_PAIRS','GARDS_EFFICIENCY_PAIRS',\%TRANSHASH,'select * from RMSMAN.GARDS_EFFICIENCY_PAIRS where SAMPLE_ID=?',$SAMPLEID);

print "extract RMSMAN.GARDS_ENERGY_PAIRS \n";
$ex->extract('RMSMAN.GARDS_ENERGY_PAIRS','GARDS_ENERGY_PAIRS',\%TRANSHASH,'select * from RMSMAN.GARDS_ENERGY_PAIRS where SAMPLE_ID=?',$SAMPLEID);

print "extract RMSMAN.GARDS_ENERGY_PAIRS_ORIG \n";
$ex->extract('RMSMAN.GARDS_ENERGY_PAIRS_ORIG','GARDS_ENERGY_PAIRS_ORIG',\%TRANSHASH,'select * from RMSMAN.GARDS_ENERGY_PAIRS_ORIG where SAMPLE_ID=?',$SAMPLEID);

print "extract RMSMAN.GARDS_NUCL_IDED \n";
$ex->extract('RMSMAN.GARDS_NUCL_IDED','GARDS_NUCL_IDED',\%TRANSHASH,'select * from RMSMAN.GARDS_NUCL_IDED where SAMPLE_ID=?',$SAMPLEID);

print "extract RMSMAN.GARDS_NUCL_LINES_IDED \n";
$ex->extract('RMSMAN.GARDS_NUCL_LINES_IDED','GARDS_NUCL_LINES_IDED',\%TRANSHASH,'select * from RMSMAN.GARDS_NUCL_LINES_IDED where SAMPLE_ID=?',$SAMPLEID);

print "extract RMSMAN.GARDS_PEAKS \n";
$ex->extract('RMSMAN.GARDS_PEAKS','GARDS_PEAKS',\%TRANSHASH,'select * from RMSMAN.GARDS_PEAKS where SAMPLE_ID=?',$SAMPLEID);

#print "extract RMSMAN.GARDS_RESOLUTION_CAL_COV \n";
#$ex->extract('RMSMAN.GARDS_RESOLUTION_CAL_COV','GARDS_RESOLUTION_CAL_COV',\%TRANSHASH,'select * from RMSMAN.GARDS_RESOLUTION_CAL_COV where SAMPLE_ID=153931');

#print "extract RMSMAN.GARDS_RESOLUTION_PAIRS \n";
#$ex->extract('RMSMAN.GARDS_RESOLUTION_PAIRS','GARDS_RESOLUTION_PAIRS',\%TRANSHASH,'select * from RMSMAN.GARDS_RESOLUTION_PAIRS where SAMPLE_ID=?',$SAMPLEID);

#print "extract RMSMAN.GARDS_RESOLUTION_PAIRS_ORIG \n";
#$ex->extract('RMSMAN.GARDS_RESOLUTION_PAIRS_ORIG','GARDS_RESOLUTION_PAIRS_ORIG',\%TRANSHASH,'select * from RMSMAN.GARDS_RESOLUTION_PAIRS_ORIG where SAMPLE_ID=?',$SAMPLEID);

# get state of health value 
#print "extract RMSMAN.GARDS_SOH_NUM_DATA \n";
#$ex->extract('RMSMAN.GARDS_SOH_NUM_DATA','GARDS_SOH_NUM_DATA',\%TRANSHASH,'select gsoh.* from RMSMAN.gards_soh_num_data gsoh , RMSMAN.gards_sample_data gsdata where gsdata.station_id=gsoh.station_id and gsdata.SAMPLE_ID=?',$SAMPLEID);

#print "extract RMSMAN.GARDS_SOH_CHAR_DATA \n";
#$ex->extract('RMSMAN.GARDS_SOH_CHAR_DATA','GARDS_SOH_CHAR_DATA',\%TRANSHASH,'select gsoh.* from RMSMAN.gards_soh_char_data gsoh , RMSMAN.gards_sample_data gsdata where gsdata.station_id=gsoh.station_id and gsdata.SAMPLE_ID=?',$SAMPLEID);

$ex->disconnect();
}

__END__

=head1 NAME

generate_sample_data - extract from the database all the necessary data to have a working test sample for autosaint

=head1 SYNOPSIS

  generate_sample_data.pl [options]

  Options:
  --sampleID  (-sid)     Sample ID ex -sid 159698   (no default) 
  --database  (-db)      Database name to access    (default=idcdev.ctbto.org)
  --user      (-u)       Database user              (default=centre)
  --password  (-p)       Database password          (default= password of the centre user)
  --directory (-dir)     Home Directory where the generated insertion files will be stored
                         Sample data are always stored under $HOME/SampleID
                                                    (default=/tmp/autosaintTests/SampleID)
  --transform (-trans)   List of Transformations directives (regexpr) to be applied to designated Table columns.
                         Transformation Directives syntax: TABLENAME.COLUMN:Regexp,TABLENAME.COLUMN:Regexp
                         For example -trans "FILEPRODUCT.DIR:s{/home/misc}{/tmp/data}g,..."
  --dataType  (-dt)      Data Type used in some SQL request (default=SPECTRUM) 
  --overwrite            Overwrite all generated files if they already exist (default= overwrite is true) 

  Help Options:
   --help     Show this scripts help information.
   --manual   Read this scripts manual.
   --version  Show the version number and exit.

=cut

=head1 EXAMPLES

  The following is an example of this script:

  generate_sample_data.pl --help

=cut


=head1 DESCRIPTION


  This is a simple demonstration program for Pod::Usage, this text
 will be displayed if the script is invoked with '--manual'.

=cut


=head1 AUTHOR


 Guillaume Aubert
 --
 guillaume.aubert@ctbto.org

 $Id: generate_sample_data.pl,v0.5 2008/02/05 10:00:00 guillaume Exp $

=cut

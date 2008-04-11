package HtmlRenderer;

use strict;
use Common::Util;
use Data::Dumper;

# Class Members

################# HTML TEMPLATES  #################


################# For index #################

my $INDEX_HTML='<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html; charset=ISO-8859-1"
 http-equiv="content-type">
  <title>AutoSaint Test Campaign</title>
</head>
<body>
<h1 style="text-align: center;">Summary of the Test done ##DATE##</h1>

<h2 style="font-weight: bold;">A) Total number of runs : ##TOTALINDEX##</h2>

##IMGTOTAL##

<h2 style="font-weight: bold;">B) Runs with Anomalies</h2>
##ANOMALIES##
<h2 style="font-weight: bold;">C) Successful Runs</h2>
##GOODRUNS##
</body>';




################# For individual reference ID files #################

my $DEFAULTCOLORSTYLE  ='color: black; background:white;';
my $FLAGCOLORSTYLE     ='color: white; background:#FF4500 ;';

my $TABLESTYLE='"text-align: center; width: 1250px; height: 86px; border: 1px solid black; border-spacing: 0px"';
my $MEDIUMTABLESTYLE='"text-align: center; width: 600px; height: 86px; border: 1px solid black; border-spacing: 0px"';

my $SMALLTABLESTYLE='"text-align: center; width: 300px; height: 86px; border: 1px solid black; border-spacing: 0px"';

my $TABLETDHEADSTYLE='"vertical-align: top; font-weight: bold; border: 1px solid black; border-spacing: 0px"';

my $TABLETDSTYLE='"'.$DEFAULTCOLORSTYLE.' vertical-align: top; font-weight: normal; border: 1px solid black; border-spacing: 0px"';


my $TRANSPARENTTABLESTYLE='"text-align: left; width: 1250px; height: 0px; border: 0px solid black; border-spacing: 0px"';
my $TABLETRANSPARENTTDSTYLE='"vertical-align: top; font-weight: normal; border: 0px solid black; border-spacing: 0px"';

my $HTML = '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html; charset=ISO-8859-1"
 http-equiv="content-type">
  <title>AutoSaint Test Campaign</title>
</head>
<body>
<h1 style="text-align: center;">Test Report for Sample Reference Id ##REFID##</h1>
<br>
<br>
<p style="font-weight: bold;">Sample ID from A : ##SIDA##, Sample ID from B :  ##SIDB##</p>
<p style="font-weight: bold;">A = idcdev.ctbto.org, B = maui.ctbto.org</p>
<p>Deviation values are all percentages.</p>
<p>Deviation formula: ((val_B - val_A) / val_A)*100).</p>
<h2 style="font-weight: bold;">A) Calibrations</h2>
##CAL##
<h2 style="font-weight: bold;">B) Peaks<br></h2>
<p> formula used to find matching peaks: matches if abs(energy_B - energy_A) < ((abs(energy_err_A)+abs(energy_err_B))*peaks_coeff</p>
<h3 style="font-weight: bold;">B.1) Matching Peaks <br></h2>
##PEAKS##
<h3 style="font-weight: bold;">B.2) Non Matched Peaks from A<br></h2>
##NMPEAKSA##
<h3 style="font-weight: bold;">B.3) Non Matched Peaks from B<br></h2>
##NMPEAKSB##
<h2 style="font-weight: bold;">C) Nuclide Line Ided</h2>
<h3 style="font-weight: bold;">C.1) Matching Nuclide Line Ided</h3>
<table style='.$TABLESTYLE.'>
  <tbody>
    <tr>
      <td style='.$TABLETDHEADSTYLE.'>Nuclide ided</td>
      <td style='.$TABLETDHEADSTYLE.'>Matched Energy</td>
      <td style='.$TABLETDHEADSTYLE.'>Matching Energy</td>
      <td style='.$TABLETDHEADSTYLE.'>Activity Dev</td>
      <td style='.$TABLETDHEADSTYLE.'>Activity Err Dev</td>
    </tr>
##MNUCLIDELINEIDED##
  </tbody>
</table>
<h3 style="font-weight: bold;">C.2) Non Matched from B</h3>
##NONMATCHEDNUCLIDEIDLINEFROMB##
<h3 style="font-weight: bold;">C.3) Non Matched from A</h3>
##NONMATCHEDNUCLIDEIDLINEFROMA##
<h2 style="font-weight: bold;">D) Nuclide Ided</h2>
<h3 style="font-weight: bold;">D.1) Matching Nuclide Ided</h3>
<table style='.$TABLESTYLE.'>
  <tbody>
    <tr>
      <td style='.$TABLETDHEADSTYLE.'>Nuclide ided</td>
      <td style='.$TABLETDHEADSTYLE.'>Ave Activity Dev</td>
      <td style='.$TABLETDHEADSTYLE.'>Ave Activity Err Dev</td>
      <td style='.$TABLETDHEADSTYLE.'>Key Activity Dev </td>
      <td style='.$TABLETDHEADSTYLE.'>Key Activity Err Dev</td>
    </tr>
##MNUCLIDEIDED##
  </tbody>
</table>
<h3 style="font-weight: bold;">D.2) Non Matched from B</h3>
##NONMATCHEDNUCLIDEIDFROMB##
<h3 style="font-weight: bold;">D.3) Non Matched from A</h3>
##NONMATCHEDNUCLIDEIDFROMA##
<h2 style="font-weight: bold;">E) Total Number of Peaks Found</h2>
<table style='.$TABLESTYLE.'>
  <tbody>
    <tr>
      <td style='.$TABLETDHEADSTYLE.'>Total peaks found from A</td>
      <td style='.$TABLETDHEADSTYLE.'>Total peaks found from B</td>
      <td style='.$TABLETDHEADSTYLE.'>Unknown peaks from A</td>
      <td style='.$TABLETDHEADSTYLE.'>Percentage of Unknown Peaks from A</td>
      <td style='.$TABLETDHEADSTYLE.'>Unknown peaks from B</td>
      <td style='.$TABLETDHEADSTYLE.'>Percentage of Unknown Peaks from B</td>
      <td style='.$TABLETDHEADSTYLE.'>Devation of Unknown in Percents </td>
    </tr>
    <tr style="'.$DEFAULTCOLORSTYLE.'"> 
      <td style='.$TABLETDSTYLE.'>##TOTALPEAKSA##</td>
      <td style='.$TABLETDSTYLE.'>##TOTALPEAKSB##</td>
      <td style='.$TABLETDSTYLE.'>##UNKNOWNPEAKSA##</td>
      <td style='.$TABLETDSTYLE.'>##PERCENTUNKNOWNPEAKSA##</td>
      <td style='.$TABLETDSTYLE.'>##UNKNOWNPEAKSB##</td>
      <td style='.$TABLETDSTYLE.'>##PERCENTUNKNOWNPEAKSB##</td>
      <td style='.$TABLETDSTYLE.'>##UNKNOWNPEAKSDEV##</td>
    </tr>
  </tbody>
</table>
<h2 style="font-weight: bold;">F) Categories</h2>
<table style='.$TABLESTYLE.'>
  <tbody>
    <tr>
      <td style='.$TABLETDHEADSTYLE.'>Auto Category from A</td>
      <td style='.$TABLETDHEADSTYLE.'>Rev Category from A</td>
      <td style='.$TABLETDHEADSTYLE.'>Auto Category from B</td>
      <td style='.$TABLETDHEADSTYLE.'>Rev Category from B</td>
      <td style='.$TABLETDHEADSTYLE.'>Auto Category dev</td>
      <td style='.$TABLETDHEADSTYLE.'>Rev Category dev</td>
    </tr>
    <tr style="'.$DEFAULTCOLORSTYLE.'">
      <td style='.$TABLETDSTYLE.'>##AUTOA##</td>
      <td style='.$TABLETDSTYLE.'>##REVA##</td>
      <td style='.$TABLETDSTYLE.'>##AUTOB##</td>
      <td style='.$TABLETDSTYLE.'>##REVB##</td>
      <td style='.$TABLETDSTYLE.'>##AUTODEV##</td>
      <td style='.$TABLETDSTYLE.'>##REVDEV##</td>
    </tr>
  </tbody>
</table>
</body>
</html>';


my $CAL_VALS = '
         <tr style="'.$DEFAULTCOLORSTYLE.'">
           <td style='.$TABLETDSTYLE.'>##CALUNIT##</td>
           <td style='.$TABLETDSTYLE.'>##COEFF1##</td>
           <td style='.$TABLETDSTYLE.'>##COEFF2##</td>
           <td style='.$TABLETDSTYLE.'>##COEFF3##</td>
           <td style='.$TABLETDSTYLE.'>##COEFF4##</td>
           <td style='.$TABLETDSTYLE.'>##COEFF5##</td>
           <td style='.$TABLETDSTYLE.'>##COEFF6##</td>
           <td style='.$TABLETDSTYLE.'>##COEFF7##</td>
           <td style='.$TABLETDSTYLE.'>##COEFF8##</td>
         </tr>';

my $CALS_HTML ='
   <table style='.$TABLESTYLE.'>
     <tbody>
       <tr>
         <td style='.$TABLETDHEADSTYLE.'>Calibrations</td>
         <td style='.$TABLETDHEADSTYLE.'>Coeff1 Dev</td>
         <td style='.$TABLETDHEADSTYLE.'>Coeff2 Dev</td>
         <td style='.$TABLETDHEADSTYLE.'>Coeff3 Dev</td>
         <td style='.$TABLETDHEADSTYLE.'>Coeff4 Dev</td>
         <td style='.$TABLETDHEADSTYLE.'>Coeff5 Dev</td>
         <td style='.$TABLETDHEADSTYLE.'>Coeff6 Dev</td>
         <td style='.$TABLETDHEADSTYLE.'>Coeff7 Dev</td>
         <td style='.$TABLETDHEADSTYLE.'>Coeff8 Dev</td>
       </tr>
       ##CAL_VALUES##
     </tbody>
   </table>
   <br>';

my $PEAKS_VALS = '
<table style='.$TABLESTYLE.'>
  <tbody>
    <tr>
      <td style='.$TABLETDHEADSTYLE.'>Energy from A</span>
      <br>
      <td style='.$TABLETDHEADSTYLE.'>Matching Energy from B</span><br>
      </td>
      <td style='.$TABLETDHEADSTYLE.'>Energy Dev</span><br>
      </td>
      <td style='.$TABLETDHEADSTYLE.'>Energy_Err Dev</span><br>
      </td>
      <td style='.$TABLETDHEADSTYLE.'>Centroid Dev</span><br>
      </td>
      <td style='.$TABLETDHEADSTYLE.'>Centroid_Err Dev</span><br>
      </td>
      <td style='.$TABLETDHEADSTYLE.'>Area Dev</span><br>
      </td>
      <td style='.$TABLETDHEADSTYLE.'>Area_Err Dev</span><br>
      </td>
    </tr>
     ##VALS##
  </tbody>
</table>';

my $NUCLIDE_IDED ='<tr style="'.$DEFAULTCOLORSTYLE.'">
      <td style='.$TABLETDSTYLE.'>##NUCL##<br>
      </td>
      <td style='.$TABLETDSTYLE.'>##AVEACTIVITY##</td>
      <td style='.$TABLETDSTYLE.'>##AVEACTIVITYERR##</td>
      <td style='.$TABLETDSTYLE.'>##KEYACTIVITY##</td>
      <td style='.$TABLETDSTYLE.'>##KEYACTIVITYERR##</td>
    </tr>
';

my $PEAKS_NON_MATCHED_HEADER ='<table style='.$SMALLTABLESTYLE.'>
  <tbody>
    <tr>
      <td style='.$TABLETDHEADSTYLE.'>Energy</td>
    </tr>
##NONMATCHEDPEAKS##
  </tbody>
</table>';

my $PEAKS_NON_MATCHED_VAL='
<tr style='.$DEFAULTCOLORSTYLE.'>
<td style='.$TABLETDSTYLE.'>##NONMATCHEDPEAKSVAL##</td>
</tr>';

my $NL_NON_MATCHED_FROM_HEADER ='
<table style='.$MEDIUMTABLESTYLE.'>
  <tbody>
    <tr>
      <td style='.$TABLETDHEADSTYLE.'>Nuclide Line Ided</td>
      <td style='.$TABLETDHEADSTYLE.'>Energy</td>
    </tr>
##NONMATCHEDNUCLIDEIDLINEFROM##
  </tbody>
</table>';

my $NL_NON_MATCHED_VAL ='
<tr style='.$DEFAULTCOLORSTYLE.'>
<td style='.$TABLETDSTYLE.'>##NLIDED##</td>
<td style='.$TABLETDSTYLE.'>##NLENERGY##</td>
</tr>
';

my $N_NON_MATCHED_FROM_HEADER ='
<table style='.$TRANSPARENTTABLESTYLE.'>
  <tbody>
##NONMATCHEDNUCLIDEIDFROM##
  </tbody>
</table>';

my $N_NON_MATCHED_VAL ='
<tr>
<td style='.$TABLETRANSPARENTTDSTYLE.'>##NIDED##</td> </tr>';

# Class Methods

# Constructor
sub new 
{
  my ($class,$dir,$anomaly_percentage,$has_index) = @_;


  my $self  = {
      dir                   => (defined $dir) ? $dir : '.',
      has_index             => (defined $has_index) ? $has_index : 1,
      index_anomalies       => "",
      index_goodruns        => "",
      nb_goodruns           => 0,
      nb_anomalies          => 0,
      has_anomaly           => 0,
      index_filename        => "index.html",
      # flag as anomaly if err > anomaly_percentage, default = 10 %
      anomaly_percentage    => (defined $anomaly_percentage) ? $anomaly_percentage : 10,
  };

  # Blessing
  my $tempo = bless ($self,$class);

  $tempo->_init();

  return $tempo;
}

# Destructor
sub DESTROY 
{
  my ($self,$args) = @_;

} 

#Part of the interface: use to finalize the rendering. In the case of the html renderer, it is used to generate the
# index.html
sub finalize
{
   my ($self,$args) = @_;

   #write index 
   $self->_write_index();

}

sub _init
{
   my ($self,$args) = @_;
   # clean and create index.html, create dir and so on

   #get absolute path for dir
   $self->{dir} = Util::get_absolute_path($self->{dir});

   #print "DIR = $self->{dir}\n";

   #create and check dir
   Util::del_dir($self->{dir});

   Util::create_dir($self->{dir});

   # clean index.html file if it exists
   my $index_handle;

   my $filename = "".$self->{dir}.'/'.$self->{index_filename};

   open($index_handle,">$filename") || die("Could not open file $filename");

   print $index_handle "";

   close($index_handle);
}

# Reset members values from one rendering to another one
sub _reset
{
   my ($self,$args) = @_;

   #$self->{index_anomalies} = "";
   #$self->{index_goodruns}  = "";

}



# Accessors
sub dir
{
   my ($self,$args) = @_;
   $args ? $self->{data_hash} = $args  #modify
         : $self->{data_hash};         # access
} 

# returned a flagged line if one of the values is over the thesold (10 %)
# otherwise return the original $line
sub _flag_table_line
{
   my ($self,$line,@values) = @_;

   for my $val (@values)
   {
      if ($val ne '-' && $val >= $self->{anomaly_percentage})
      {
         $line =~ s/$DEFAULTCOLORSTYLE/$FLAGCOLORSTYLE/g;
         last;
      }
   }

   return $line;
}

# get TD and flag it if necessary
sub _get_TD
{
  my ($self,$value,$check_flag,@more) = @_;

  $check_flag = 0 unless (defined $check_flag);

  my $TD = '<td style='.$TABLETDSTYLE.'>'.$value.'</td>';   

  if ($check_flag) 
  {
    #print "value = $value , anomaly = $self->{anomaly_percentage}\n";
    if ($value ne '-' && $value >= $self->{anomaly_percentage})
    {
      $TD =~ s/$DEFAULTCOLORSTYLE/$FLAGCOLORSTYLE/g;

      # flag anomaly
      $self->{has_anomaly} = 1;
    }
  }

  return $TD;
}

# get TR 
sub _get_TR
{
  my ($self,$tds,@more) = @_;

  return '<tr>'.$tds.'</tr>';
}

# render in a file  
sub render
{
   my ($self,$ref_data,$filename,@args) = @_;

   #reset renderer
   $self->_reset();

   $self->{has_anomaly} = 0;

   my %data = %{$ref_data}; 

   $filename = "$data{'sample_ref_id'}.html" unless (defined $filename);

   ######
   # Work on Calibration Rendering
   ######

   my %e_cal = %{$data{'energy_cal_dev'}};
   my $energy_html = $CAL_VALS;

   $energy_html =~ s/##CALUNIT##/Energy/g;
   $energy_html =~ s/##COEFF1##/$e_cal{'COEFF1'}/g;
   $energy_html =~ s/##COEFF2##/$e_cal{'COEFF2'}/g;
   $energy_html =~ s/##COEFF3##/$e_cal{'COEFF3'}/g;
   $energy_html =~ s/##COEFF4##/$e_cal{'COEFF4'}/g;
   $energy_html =~ s/##COEFF5##/$e_cal{'COEFF5'}/g;
   $energy_html =~ s/##COEFF6##/$e_cal{'COEFF6'}/g;
   $energy_html =~ s/##COEFF7##/$e_cal{'COEFF7'}/g;
   $energy_html =~ s/##COEFF8##/$e_cal{'COEFF8'}/g;

   #print "$energy_html\n";

   %e_cal = %{$data{'efficiency_cal_dev'}};
   my $eff_html = $CAL_VALS;

   $eff_html =~ s/##CALUNIT##/Efficiency/g;
   $eff_html =~ s/##COEFF1##/$e_cal{'COEFF1'}/g;
   $eff_html =~ s/##COEFF2##/$e_cal{'COEFF2'}/g;
   $eff_html =~ s/##COEFF3##/$e_cal{'COEFF3'}/g;
   $eff_html =~ s/##COEFF4##/$e_cal{'COEFF4'}/g;
   $eff_html =~ s/##COEFF5##/$e_cal{'COEFF5'}/g;
   $eff_html =~ s/##COEFF6##/$e_cal{'COEFF6'}/g;
   $eff_html =~ s/##COEFF7##/$e_cal{'COEFF7'}/g;
   $eff_html =~ s/##COEFF8##/$e_cal{'COEFF8'}/g;

   #print "$eff_html\n";

   %e_cal = %{$data{'resolution_cal_dev'}};
   my $res_html = $CAL_VALS;

   $res_html =~ s/##CALUNIT##/Resolution/g;
   $res_html =~ s/##COEFF1##/$e_cal{'COEFF1'}/g;
   $res_html =~ s/##COEFF2##/$e_cal{'COEFF2'}/g;
   $res_html =~ s/##COEFF3##/$e_cal{'COEFF3'}/g;
   $res_html =~ s/##COEFF4##/$e_cal{'COEFF4'}/g;
   $res_html =~ s/##COEFF5##/$e_cal{'COEFF5'}/g;
   $res_html =~ s/##COEFF6##/$e_cal{'COEFF6'}/g;
   $res_html =~ s/##COEFF7##/$e_cal{'COEFF7'}/g;
   $res_html =~ s/##COEFF8##/$e_cal{'COEFF8'}/g;

   $CALS_HTML =~ s/##CAL_VALUES##/$energy_html$eff_html$res_html/g;

   ##############
   # PEAKS VALUES
   ##############

    my %m_peaks  = %{$data{'peaks'}{'matching_peaks'}};
    my $p_values = "";
    my $check_flag = 1;
   
    foreach my $val (sort { $a <=> $b } keys %m_peaks) 
    {
       my $peaks_values = "";
       my %i_hash = %{$m_peaks{$val}};

       foreach my $vals (sort keys %i_hash)
       {
         my $lpeak_val = $self->_get_TD($val);
         $lpeak_val .= $self->_get_TD($i_hash{$vals}{matching_energy});
         $lpeak_val .= $self->_get_TD($i_hash{$vals}{energy_dev},$check_flag);
         $lpeak_val .= $self->_get_TD($i_hash{$vals}{energy_err_dev});
         $lpeak_val .= $self->_get_TD($i_hash{$vals}{centroid_dev},$check_flag);
         $lpeak_val .= $self->_get_TD($i_hash{$vals}{centroid_err_dev});
         $lpeak_val .= $self->_get_TD($i_hash{$vals}{area_dev},$check_flag);
         $lpeak_val .= $self->_get_TD($i_hash{$vals}{area_err_dev});

         $peaks_values .= $self->_get_TR($lpeak_val);
       }

       #accumulate values (one row each time)
       $p_values .= $peaks_values;
    }

    # copy match for energy
    my $peaks_matched_html = $PEAKS_VALS;

    # replace ##VALS## with the values
    $peaks_matched_html =~ s/##VALS##/$p_values/g;

    # non matching peaks from A
    my $peaks_non_match_A_html = $PEAKS_NON_MATCHED_HEADER;
    my $nm_peak_A_vals = "";

    foreach my $peak_en (@{$data{'peaks'}{'non_matching_from_A'}})
    {
      my $nm_peak_A_val = $PEAKS_NON_MATCHED_VAL;
      $nm_peak_A_val =~ s/##NONMATCHEDPEAKSVAL##/$peak_en/g;
      $nm_peak_A_vals .= $nm_peak_A_val;
    }

    # add values in header
    $peaks_non_match_A_html =~ s/##NONMATCHEDPEAKS##/$nm_peak_A_vals/g;

    # non matching peaks from B
    my $peaks_non_match_B_html = $PEAKS_NON_MATCHED_HEADER;
    my $nm_peak_B_vals = "";

    foreach my $peak_en (@{$data{'peaks'}{'non_matching_from_B'}})
    {
      my $nm_peak_B_val = $PEAKS_NON_MATCHED_VAL;
      $nm_peak_B_val =~ s/##NONMATCHEDPEAKSVAL##/$peak_en/g;
      $nm_peak_B_vals .= $nm_peak_B_val;
    }

    # add values in header
    $peaks_non_match_B_html =~ s/##NONMATCHEDPEAKS##/$nm_peak_B_vals/g;


   ##############
   # NUCL LINEIDED VALUES
   ##############

   my $nls_html = "";
   my $nl_nmatched_from_A_html = ""; 
   my $nl_nmatched_from_B_html = ""; 

   if (defined $data{'matching_line_ided'} && defined $data{'matching_line_ided'}{'matching_lined_id'})
   {
      my %nl = %{$data{'matching_line_ided'}{'matching_lined_id'}};

      my $nl_dummy ="";

      # get all matchers
      foreach my $val (sort { $a cmp $b } keys %nl)
      {
         my @infos = split(/:/,$val);

         $nl_dummy = $self->_get_TD($infos[0]);

         $nl_dummy .= $self->_get_TD($infos[1]);
         $nl_dummy .= $self->_get_TD($infos[2]);

         my $t     = (defined $nl{$val}{'activity_dev'}) ? $nl{$val}{'activity_dev'} : '-';
         my $t_err = (defined $nl{$val}{'activity_err_dev'}) ? $nl{$val}{'activity_err_dev'} : '-';

         $nl_dummy .= $self->_get_TD($t,1);
         $nl_dummy .= $self->_get_TD($t_err);

         $nls_html .= $self->_get_TR($nl_dummy);
      }

      $nl_nmatched_from_B_html = $NL_NON_MATCHED_FROM_HEADER; 

      # non matching from B
      if (defined $data{'matching_line_ided'}{'non_matched_from_B'})
      {
        my @nl_b = @{$data{'matching_line_ided'}{'non_matched_from_B'}};

        my $nl_nmatched_from_B = "";

        foreach my $val (@nl_b)
        {
          my $nl_val = $NL_NON_MATCHED_VAL;
          my ($nl_name,$nl_en) = split(/:/,$val);
          $nl_val =~ s/##NLIDED##/$nl_name/g;   
          $nl_val =~ s/##NLENERGY##/$nl_en/g;   

          $nl_nmatched_from_B .= $nl_val; 
        }

        $nl_nmatched_from_B_html =~ s/##NONMATCHEDNUCLIDEIDLINEFROM##/$nl_nmatched_from_B/g;
      } 
      else
      {
        $nl_nmatched_from_B_html = '<span style="font-weight: bold;">None</span>'; 
      }

      # non matching from A

      $nl_nmatched_from_A_html = $NL_NON_MATCHED_FROM_HEADER;

      if (defined $data{'matching_line_ided'}{'non_matched_from_A'})
      {
         my @nl_a = @{$data{'matching_line_ided'}{'non_matched_from_A'}};

         my $nl_val = "";

         my $nl_nmatched_from_A = "";
        foreach my $val (@nl_a)
        {
          $nl_val = $NL_NON_MATCHED_VAL; 
          my ($nl_name,$nl_en) = split(/:/,$val);
          $nl_val =~ s/##NLIDED##/$nl_name/g;
          $nl_val =~ s/##NLENERGY##/$nl_en/g;

          $nl_nmatched_from_A .= $nl_val; 
        }

        $nl_nmatched_from_A_html =~ s/##NONMATCHEDNUCLIDEIDLINEFROM##/$nl_nmatched_from_A/g;
      } 
      else
      {
        $nl_nmatched_from_A_html = '<span style="font-weight: bold;">None</span>'; 
      }
  }
      #########
      # Matching Nuclide ided
      ##########

   my $nucls_html = "";
   my $nucls_nmatched_from_A_html = "";
   my $nucls_nmatched_from_B_html = "";

   if (defined $data{'matching_nuclide_ided'} && defined $data{'matching_nuclide_ided'}{'matching_nucl_id'})
   {
   my %nuclideds = %{$data{'matching_nuclide_ided'}{'matching_nucl_id'}};

   my $nucls_dummy = "";

   # get all matchers
   foreach my $val (sort keys %nuclideds)
   {
      my $ave_acti     =  (defined $nuclideds{$val}{'ave_activity_dev'}) ? $nuclideds{$val}{'ave_activity_dev'} : '-';
      my $ave_acti_err =  (defined $nuclideds{$val}{'ave_activity_err_dev'}) ? $nuclideds{$val}{'ave_activity_err_dev'} : '-';
      my $key_acti     =  (defined $nuclideds{$val}{'key_activity_dev'}) ? $nuclideds{$val}{'key_activity_dev'} : '-';
      my $key_acti_err =  (defined $nuclideds{$val}{'key_activity_err_dev'}) ? $nuclideds{$val}{'key_activity_err_dev'} : '-';

      $nucls_dummy  = $self->_get_TD($val);
      $nucls_dummy  .= $self->_get_TD($ave_acti,1);
      $nucls_dummy  .= $self->_get_TD($ave_acti_err);
      $nucls_dummy  .= $self->_get_TD($key_acti,1);
      $nucls_dummy  .= $self->_get_TD($key_acti_err);

      $nucls_html .=$self->_get_TR($nucls_dummy);
   }

   $nucls_nmatched_from_B_html = $N_NON_MATCHED_FROM_HEADER; 

   # non matching from B
   if (defined $data{'matching_nuclide_ided'}{'non_matched_from_B'})
   {
      my @nl_b = @{$data{'matching_nuclide_ided'}{'non_matched_from_B'}};

      if (@nl_b > 0)
      {
         my $nl_val = "";

         my $nl_nmatched_from_B = "";

         my $nl_size = @nl_b;

         for (my $i=0;$i<$nl_size;$i=$i+15)
         {
            $nl_val = $N_NON_MATCHED_VAL;
            
            #do not go other lize length
            my $end = (($i+14) >= $nl_size) ? ($nl_size-1) : ($i+14); 

            my @l = @nl_b[$i..$end];

            my $val_str = join(", ",@l);

            $nl_val =~ s/##NIDED##/$val_str/g;

            $nl_nmatched_from_B .= $nl_val;
         }
          
         $nucls_nmatched_from_B_html =~ s/##NONMATCHEDNUCLIDEIDFROM##/$nl_nmatched_from_B/g;
      }
      else
      {
          $nucls_nmatched_from_B_html = '<span style="font-weight: bold;">None</span>';
      }
   } 
   else
   {
     $nucls_nmatched_from_B_html = '<span style="font-weight: bold;">None</span>'; 
   }

   # non matching from A

   $nucls_nmatched_from_A_html = $N_NON_MATCHED_FROM_HEADER;

   if (defined $data{'matching_nuclide_ided'}{'non_matched_from_A'})
   {
      my @nl_a = @{$data{'matching_nuclide_ided'}{'non_matched_from_A'}};

      if (@nl_a > 0)
      {
         my $nl_val = "";

         my $nl_nmatched_from_A = "";

         my $nl_size = @nl_a;

         for (my $i=0;$i<$nl_size;$i=$i+15)
         {
            $nl_val = $N_NON_MATCHED_VAL;
            
            #do not go other lize length
            my $end = (($i+14) >= $nl_size) ? ($nl_size-1) : ($i+14); 

            my @l = @nl_a[$i..$end];

            my $val_str = join(", ",@l);

            $nl_val =~ s/##NIDED##/$val_str/g;

            $nl_nmatched_from_A .= $nl_val;
         }

         $nucls_nmatched_from_A_html =~ s/##NONMATCHEDNUCLIDEIDFROM##/$nl_nmatched_from_A/g;
      }
      else
      {
          $nucls_nmatched_from_A_html = '<span style="font-weight: bold;">None</span>';
      }
   } 
   else
   {
     $nucls_nmatched_from_A_html = '<span style="font-weight: bold;">None</span>'; 
   }
  }

   #########
   # Total Peaks Info
   #########
   
   my $tpeaksA       = $data{'peaks_found_from_A'};  
   my $tpeaksB       = $data{'peaks_found_from_B'};  
   my $upeaksA       = $data{'peaks_unknown_from_A'};  
   my $percupeaksA   = (defined $data{'percentage_of_unknown_from_A'}) ? $data{'percentage_of_unknown_from_A'}: '-';  
   my $upeaksB       = $data{'peaks_unknown_from_B'};  
   my $percupeaksB   = $data{'percentage_of_unknown_from_B'};  
   my $upeaksdev     = (defined $data{'peaks_unknown_dev'}) ? $data{'peaks_unknown_dev'} : '-';  

   #########
   # Categories
   ##########

   my $auto_cat_A   = (defined $data{'categories'}{'auto_cat_A'}) ? $data{'categories'}{'auto_cat_A'}   : '-';
   my $rev_cat_A    = (defined $data{'categories'}{'rev_cat_A'}) ? $data{'categories'}{'rev_cat_A'}    : '-';
   my $auto_cat_B   = (defined $data{'categories'}{'rev_cat_A'}) ? $data{'categories'}{'auto_cat_B'}   : '-';
   my $rev_cat_B    = (defined $data{'categories'}{'rev_cat_B'}) ? $data{'categories'}{'rev_cat_B'}    : '-';
   my $auto_cat_dev = (defined $data{'categories'}{'auto_cat_dev'}) ? $data{'categories'}{'auto_cat_dev'} : '-';
   my $rev_cat_dev  = (defined $data{'categories'}{'rev_cat_dev'}) ? $data{'categories'}{'rev_cat_dev'}  : '-';

   #########
   # Assemble Html pieces
   #########
   #copy the HTML template
   my $results_HTML = $HTML;

   $results_HTML =~ s/##CAL##/$CALS_HTML/g;
   $results_HTML =~ s/##PEAKS##/$peaks_matched_html/g;
   $results_HTML =~ s/##NMPEAKSA##/$peaks_non_match_A_html/g;
   $results_HTML =~ s/##NMPEAKSB##/$peaks_non_match_B_html/g;
   $results_HTML =~ s/##MNUCLIDELINEIDED##/$nls_html/g;
   $results_HTML =~ s/##NONMATCHEDNUCLIDEIDLINEFROMB##/$nl_nmatched_from_B_html/g;
   $results_HTML =~ s/##NONMATCHEDNUCLIDEIDLINEFROMA##/$nl_nmatched_from_A_html/g;
   $results_HTML =~ s/##MNUCLIDEIDED##/$nucls_html/g;
   $results_HTML =~ s/##NONMATCHEDNUCLIDEIDFROMB##/$nucls_nmatched_from_B_html/g;
   $results_HTML =~ s/##NONMATCHEDNUCLIDEIDFROMA##/$nucls_nmatched_from_A_html/g;

   $results_HTML =~ s/##TOTALPEAKSA##/$tpeaksA/g;
   $results_HTML =~ s/##TOTALPEAKSB##/$tpeaksB/g;
   $results_HTML =~ s/##UNKNOWNPEAKSA##/$upeaksA/g;
   $results_HTML =~ s/##UNKNOWNPEAKSB##/$upeaksB/g;
   $results_HTML =~ s/##PERCENTUNKNOWNPEAKSA##/$percupeaksA/g;
   $results_HTML =~ s/##PERCENTUNKNOWNPEAKSB##/$percupeaksB/g;
   $results_HTML =~ s/##UNKNOWNPEAKSDEV##/$upeaksdev/g;
   $results_HTML =~ s/##AUTOA##/$auto_cat_A/g;
   $results_HTML =~ s/##REVA##/$rev_cat_A/g;
   $results_HTML =~ s/##AUTOB##/$auto_cat_B/g;
   $results_HTML =~ s/##REVB##/$rev_cat_B/g;
   $results_HTML =~ s/##AUTODEV##/$auto_cat_dev/g;
   $results_HTML =~ s/##REVDEV##/$rev_cat_dev/g;
   $results_HTML =~ s/##REFID##/$data{'sample_ref_id'}/g;
   $results_HTML =~ s/##SIDA##/$data{'sample_id_from_A'}/g;
   $results_HTML =~ s/##SIDB##/$data{'sample_id_from_B'}/g;

   my $file_handle;
   open($file_handle,">$self->{dir}/$filename") || die("Could not open file $self->{dir}/$filename"); 

   print "Store Html report for $data{'sample_ref_id'} in $self->{dir}/$filename\n";

   # create file check dir and print in it
   print $file_handle "$results_HTML";

   # add in index
   $self->_add_in_index($data{'sample_ref_id'},"$self->{dir}/$filename");
}

sub _add_in_index
{
   my ($self,$ref_id,$link_file_path,@args) = @_;

   if ($self->{has_anomaly})
   {
     $self->{index_anomalies} .= "<a href=\"file:///$link_file_path\">reference ID $ref_id</a><br>";
     $self->{nb_anomalies}++;
   }
   else
   {
     $self->{index_goodruns} .= "<a href=\"file:///$link_file_path\">reference ID $ref_id</a><br>";
     $self->{nb_goodruns}++;
   }
}

sub _write_index
{

   my ($self,@args) = @_;  

   my $index = "".$self->{dir}.'/'.$self->{index_filename};
   my $index_handle;

   open($index_handle,">$index") || die("Could not open file $index");


   my $str = $INDEX_HTML;

   my $nb_runs   = ($self->{nb_anomalies}+$self->{nb_goodruns});
   my $perc_pb   = Util::round(($self->{nb_anomalies}/$nb_runs)*100,0);
   my $perc_good = Util::round(($self->{nb_goodruns}/$nb_runs)*100,0);
   my $img ="<img src=\"http://chart.apis.google.com/chart?cht=p&chd=t:$perc_pb,$perc_good&chs=300x150&chl=NonOK-$perc_pb%|OK-$perc_good%&chco=ff0000,00ff00\">"; 

   my $loctime = Util::localtime_as_string();
   
   $str =~ s/##DATE##/$loctime/g;
   $str =~ s/##TOTALINDEX##/$nb_runs/g;
   $str =~ s/##IMGTOTAL##/$img/g;
   $str =~ s/##ANOMALIES##/$self->{index_anomalies}/g;
   $str =~ s/##GOODRUNS##/$self->{index_goodruns}/g;

   print $index_handle $str;

   print "Index Summary stored in $index\n";

   close($index_handle);
}

1;
__END__

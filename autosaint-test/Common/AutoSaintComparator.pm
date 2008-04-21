package AutoSaintComparator;

use strict;
use Data::Dumper;
use Common::Util;
use File::Basename;

# Class Members
my $COMP_DEBUG=0;

# Class Methods

# Constructor
sub new 
{
  my ($class,$dirA,$dirB,$out_dir,$renderer,$p_coeff,$limit,@args) = @_;


  my $self  = {
      dirA           => $dirA,
      dirB           => $dirB,
      out_dir        => (defined $out_dir) ? $out_dir : '.',
      limit          => (defined $limit) ? $limit : undef,
      renderer       => (defined $renderer) ? $renderer : undef,
      peaks_coeff    => (defined $p_coeff) ? $p_coeff : 10,
  };

  # Blessing
  return bless ($self,$class);
}

#sub hash_new
#{
#  my ($class,$args) = @_;
#
#  print "ARGS = ". Dumper($args);
#
#  my $self = bless({},$class);
#  my %p = (
#                #%{$self->defaults},
#                %{$args},
#            );
#  map { $self->{$_} = $p{$_} } keys %p;
#
#  print "SELF = ".Dumper($self);
#
#}

# Accessors
sub dirA 
{
   my ($self,$args) = @_;
   $args ? $self->{dirA} = $args  #modify
         : $self->{dirA};         # access
} 

sub renderer
{
   my ($self,$args) = @_;
   $args ? $self->{renderer} = $args  #modify
         : $self->{renderer};         # access
} 

sub limit
{
   my ($self,$args) = @_;
   $args ? $self->{limit} = $args  #modify
         : $self->{limit};         # access
} 

sub dirB 
{
   my ($self,$args) = @_;
   $args ? $self->{dirB} = $args  #modify
         : $self->{dirB};         # access
} 

sub _list_dir_and_order
{
   my ($self,$dir,$args) = @_;

   # list directory content
   my @not_sorted = <$dir/*.yaml>;

   @not_sorted = map { basename($_) } @not_sorted;
  
   my @sorted = sort { lc($a) cmp lc($b) } @not_sorted;

   return \@sorted;
}

sub revive_data
{
  my ($self,$file) = @_;

  my $fh;

  use YAML;

  my %h = %{YAML::LoadFile($file)};

  return %h;
}

# main method to start the comparison
sub compare
{
   my ($self,$args) = @_;

   # get files from first dir ordered
   my @sorted_fileA = @{$self->_list_dir_and_order($self->{dirA})};

   my $limit = $self->{limit};
   my $nb_files = (! defined $limit) ? @sorted_fileA : $limit;
   print "$nb_files files to process from $self->{dirA} \n";

   my $file;
   foreach $file (@sorted_fileA) 
   {
      print "\nProcess for $file in $self->{dirB}\n";

      die "Cannot find $self->{dirB}/$file" if (! -f "$self->{dirB}/$file");

      # read data from dirA/file & dirB/file
      my %dataA = $self->revive_data("$self->{dirA}/$file");

      my %dataB = $self->revive_data("$self->{dirB}/$file");

      $self->_internal_comparison(\%dataA,\%dataB,$file);
      
      if (defined $limit)
      {
         last if --$limit == 0;
      }

      --$nb_files;
      print "$nb_files files left to be processed\n";
   }

   #finalize rendering if necessary
   $self->{renderer}->finalize() if (defined $self->{renderer});
}

# create intermediate data structure speeding-up the sorting
sub _build_internal_index_for_nuclided
{
   my ($self,$ref_dataA,$ref_dataB,@more) = @_;

   # hash where key is nuclide name and value is an array containing;
   my %compA = ();
   my %compB = ();

   # ref_data is an array
   my @arrA = @{$ref_dataA};
   my @arrB = @{$ref_dataB};

   for (my $i=1;$i<@arrA;$i++)
   {
     $compA{$arrA[$i][0]} = $i;
   }

   for (my $i=1;$i<@arrB;$i++)
   {
     $compB{$arrB[$i][0]} = $i;
   }

   return (\%compA,\%compB);
}

# nuclided comparison
sub _nuclided_comparison
{
   my ($self,$ref_idedA,$ref_idedB,@more) = @_;

   # build structures for comparison
   my $ref_compA;
   my $ref_compB;

   my %results = ();

   my $posA = 0;
   my $posB = 0;

   $results{'matching_nucl_id'}          = (); 

   ($ref_compA,$ref_compB) = $self->_build_internal_index_for_nuclided($ref_idedA,$ref_idedB); 

   my %compB = %{$ref_compB};
   my %compA = %{$ref_compA};

   foreach my $nucl (sort keys %compA) 
   {
      # if other structure contains the same ided nucl
      if (exists $compB{$nucl})
      {
         $posA = $compA{$nucl}; 
         $posB = $compB{$nucl};

         my $arrA = @$ref_idedA[$posA]; 
         my $arrB = @$ref_idedB[$posB]; 

         my %m = ();

         $m{'ave_activity_dev'}         = Util::round((@$arrA[1] == 0 ) ? undef : ((@$arrB[1] - @$arrA[1]) / @$arrA[1])*100);
         $m{'ave_activity_err_dev'}     = Util::round((@$arrA[2] == 0 ) ? undef : ((@$arrB[2] - @$arrA[2]) / @$arrA[2])*100);
         $m{'key_activity_dev'}         = Util::round((@$arrA[3] == 0 ) ? undef : ((@$arrB[3] - @$arrA[3]) / @$arrA[3])*100);
         $m{'key_activity_err_dev'}     = Util::round((@$arrA[4] == 0 ) ? undef : ((@$arrB[4] - @$arrA[4]) / @$arrA[4])*100);

         $results{'matching_nucl_id'}{$nucl} = \%m;         

         # remove from A and B        
         delete $compA{$nucl};
         delete $compB{$nucl};
      }
   }

   my @non_matched_from_A = ();
   # everything left in A is non-matched in B
   foreach my $nucl (sort keys %compA)
   { 
      push(@non_matched_from_A , $nucl);
   }

   $results{'non_matched_from_A'} = (@non_matched_from_A == 0) ? undef : \@non_matched_from_A;

   # everything left in B in non-matched in A
   my @non_matched_from_B = ();
   # everything left in B is non-matched in A
   foreach my $nucl (sort keys %compB)
   { 
      push(@non_matched_from_B , $nucl);
   }

   $results{'non_matched_from_B'} = (@non_matched_from_B == 0) ? undef: \@non_matched_from_B;

   return \%results;
}

# create intermediate data structure speeding-up the sorting
sub _build_internal_index_for_lineided
{
   my ($self,$ref_dataA,$ref_dataB,@more) = @_;

   # hash where key is nuclide name and value is an array containing en +- abs(err);
   my %compA = ();
   my %compB = ();

   # ref_data is an array
   my @arrA = @{$ref_dataA};
   my @arrB = @{$ref_dataB};

   my $min = 0;
   my $max = 0;

   for (my $i=1;$i<@arrA;$i++)
   {
     $min = $arrA[$i][1] - abs($arrA[$i][2]);
     $max = $arrA[$i][1] + abs($arrA[$i][2]);
    
     my @arr = ($min,$max,$arrA[$i][1],$arrA[$i][3],$arrA[$i][4]);

     $compA{"$arrA[$i][0]"} = () unless (defined $compA{"$arrA[$i][0]"});

     push(@{$compA{"$arrA[$i][0]"}},\@arr);
   }

   my $name = undef;
   for (my $j=1;$j<@arrB;$j++)
   {
     $name = $arrB[$j][0]; 

     $compB{$name} = () unless (exists $compB{$name}); 

     my @arr= ($arrB[$j][1],$j,$arrB[$j][3],$arrB[$j][4],0);
 
     push(@{$compB{$name}},\@arr);   
   }

   return (\%compA,\%compB);
}

# lineided comparison
sub _lineided_comparison
{
   # references on peaksA and peaksB arrs
   my ($self,$ref_linesA,$ref_linesB,@more) = @_;

   # build structures for comparison
   my $ref_compA;
   my $ref_compB;

   my %results = ();

   $results{'matching_lined_id'}          = (); 
   $results{'non_matched_from_A'} = ();
   $results{'non_matched_from_B'}         = ();

   ($ref_compA,$ref_compB) = $self->_build_internal_index_for_lineided($ref_linesA,$ref_linesB);

   #print "Print ref_compA \n".Dumper($ref_compA);
   #print "Print ref_compB \n".Dumper($ref_compB);

   my %compB = %{$ref_compB};
   my %compA = %{$ref_compA};

   my $val_B;
   my $val_A;
   my $has_matched = 0;

   # algorithm: For each lineid nuclide in indexed set A
   # check if it exists in B 
   foreach my $nucl (sort keys %$ref_compA) 
   {
      # if other structure contains the same ided nucl
      if (exists $compB{$nucl})
      {
         foreach $val_A (@{$compA{$nucl}}) 
         {

           my $min = @$val_A[0];
           my $max = @$val_A[1];

           print "min = $min, max = $max\n" if $COMP_DEBUG ;

           my @tempo = @{$compB{$nucl}}; 

           foreach $val_B (@tempo)
           {
              if ($min<= @$val_B[0] && @$val_B[0] <= $max)
              {
                print "matched $nucl energy val in A = @$val_A[2], energy val in B = @$val_B[0]\n" if ($COMP_DEBUG);

                my %m = ();

                $m{'activity_dev'}     = Util::round((@$val_A[3] == 0 ) ? undef : ((@$val_B[2] - @$val_A[3]) / @$val_A[3])*100);
                $m{'activity_err_dev'} = Util::round((@$val_A[4] == 0 ) ? undef : ((@$val_B[3] - @$val_A[4]) / @$val_A[4])*100);

                $results{'matching_lined_id'}{"$nucl:".Util::round(@$val_A[2]).":".Util::round(@$val_B[0])} = \%m;

                # flag matched values for A and B
                $has_matched = 1;

                # B is matched
                @$val_B[4] = 1;
              }
           }

           if ($has_matched == 0)
           {
              print "non matched $nucl energy val in A = @$val_A[2] \n" if ($COMP_DEBUG);  
              push(@{$results{'non_matched_from_A'} }, "$nucl:".Util::round(@$val_A[2]));
           }
           
           $has_matched = 0;
         }
      }
   }

   # get non matched values from B
   foreach my $nucl (sort keys %compB) 
   {
     my @tempo = @{$compB{$nucl}}; 

     foreach my $val_B (@tempo)
     {
        # non matched if it has been flagged as matched previously
        #$results{'non_matched_from_B'} = "$nucl:@$val_B[0]" unless (@$val_B[4]); 
        push(@{$results{'non_matched_from_B'}}, "$nucl:@$val_B[0]") unless (@$val_B[4]);

     }
   }

   return \%results;
}

sub _build_internal_peaks_index
{
   my ($self,$ref_data,@more) = @_;

   # hash where key is energy value and content is position is array
   my %index = ();

   # ref_data is an array
   my @arr = @{$ref_data};

   print "Array = ".Dumper($ref_data) if $COMP_DEBUG;

   my $position = 1;
   my $value = undef;
   for (my $cpt=1;$cpt < @arr; $cpt++)
   {
     $value = $arr[$cpt]; 

     # value is an array where index=2 is energy and index=3 is energy_err
     $index{@$value[2]}= $position;

     $position++;
   } 

   return %index;
}

sub _peaks_comparison
{
   # references on peaksA and peaksB arrs
   my ($self,$ref_peaksA,$ref_peaksB,@more) = @_;

   #hash of results which contains matching peaks (A inter B)
   #non matched in A and B => A - (A inter B) and B - (A inter B)
   my %results = ();

   #-----------------------
   # peaks COMPARISON
   #-----------------------
   # peaks
   # get one peak energy value and find all peaks +- (en+abs(en_err))

   my @peaksA = @{$ref_peaksA};
   my @peaksB = @{$ref_peaksB};

   # create index on B energy's
   my %index = $self->_build_internal_peaks_index(\@peaksB);

   # copy index as non matched from B and use it to create the non matched ensemble from B
   my %non_matched_ens_B = %index;

   my %non_matched_ens_A = $self->_build_internal_peaks_index(\@peaksA);

   my $en_max = 0;
   my $en_min = 0;
   my $cpt    = 0;
      
   my %matching_peaks = ();
   my @matched_peaks = ();

   # start at j=1 to pass line 0 which contains the description of the info
   for(my $j=1; $j<@peaksA;$j++)
   {
     my @info_A = @{$peaksA[$j]};

     print "\n ********* Looking for a match for $info_A[2]\n" if $COMP_DEBUG;
     
     # get energy do not look for energy value superior to en_A +2
     $en_max = $info_A[2] + 6; 

     my $info_B; 
     my %matching_data = ();

     # start from i=1 because line 0 contains info description
     for (my $i = 1; $i < @peaksB; $i++)
     {
       # get array of B vals
       $info_B = $peaksB[$i];

       # this is an order array so quit if we superior to en_max
       if (@$info_B[2] > $en_max)
       {
         print "quit because values are too big to ever match \n" if $COMP_DEBUG; 
         last;
       } 
 
       #print "EneA = $info_A[2], EnB= @$info_B[2]. (abs(ene_B-ene_A) =".abs(@$info_B[2] - $info_A[2])."(ene_errA+ene_err_B)=".abs($info_A[3]+@$info_B[3])."\n";

       # we found a match
       if ( abs(@$info_B[2] - $info_A[2]) < ((abs($info_A[3])+abs(@$info_B[3]))*$self->{peaks_coeff}) )
       {
          print "Matching energy A = $info_A[2] with energy B = @$info_B[2] \n" if $COMP_DEBUG;

          %matching_data = ();

          #retrieve from the index the position of the peak in @peaksB in order to compute the deviation
          my @val_B = @{@peaksB[$index{@$info_B[2]}]};

          $matching_data{'matching_energy'}     = Util::round($val_B[2],4);
          $matching_data{'matched_energy'}      = Util::round($info_A[2],4);
          $matching_data{'centroid_dev'}        = (defined $info_A[0] && $info_A[0] != 0) ? Util::round((($val_B[0] - $info_A[0]) / $info_A[0])*100) : undef;
          $matching_data{'centroid_err_dev'}    = (defined $info_A[1] && $info_A[1] != 0) ? Util::round((($val_B[1] - $info_A[1]) / $info_A[1])*100) : undef;
          $matching_data{'energy_dev'}          = (defined $info_A[2] && $info_A[2] != 0) ? Util::round((($val_B[2] - $info_A[2]) / $info_A[2])*100) : undef;
          $matching_data{'energy_err_dev'}      = (defined $info_A[3] && $info_A[3] != 0) ? Util::round((($val_B[3] - $info_A[3]) / $info_A[3])*100) : undef;
          $matching_data{'area_dev'}            = (defined $info_A[8] && $info_A[8] != 0) ? Util::round((($val_B[8] - $info_A[8]) / $info_A[8])*100) : undef;
          $matching_data{'area_err_dev'}        = (defined $info_A[9] && $info_A[9] != 0) ? Util::round((($val_B[9] - $info_A[9]) / $info_A[9])*100) : undef ;

          # if $matching_peaks{$info_A[2]} doesn't exist then create hash and add matched value in it.
          if (! exists $matching_peaks{Util::round($info_A[2],4)})
          {
             #reference on internal hash
             $matching_peaks{Util::round($info_A[2],4)} ={};
          }

          # do need to make a copy don't know why otherwise ref changed
          my %copy = %matching_data;

          $matching_peaks{Util::round($info_A[2],4)}{$matching_data{'matching_energy'}} = \%copy;
          #print "Matching_peaks = ".Dumper(\%matching_peaks);

          # remove value from non_matching_A and B
          delete $non_matched_ens_B{$val_B[2]} if (exists $non_matched_ens_B{$val_B[2]});
          delete $non_matched_ens_A{$info_A[2]} if (exists $non_matched_ens_A{$info_A[2]});
       } 
     }
   }

   #print "Matching_peaks = ".Dumper(\%matching_peaks);

   $results{'matching_peaks'} = \%matching_peaks;
 
   my @ens_A = map { Util::round($_) } (sort { $a <=> $b } keys %non_matched_ens_A);
   my @ens_B = map { Util::round($_) } (sort { $a <=> $b } keys %non_matched_ens_B);

   $results{'non_matching_from_A'} = \@ens_A ;

   $results{'non_matching_from_B'} = \@ens_B ;

   #print "Results = ".Dumper(\%results);

   return \%results;
}

sub _calibration_comparison
{
   my ($self,$ref_dataA,$ref_dataB,$ref_results,@more) = @_;

   my %dataA = %{$ref_dataA};
   my %dataB = %{$ref_dataB};

   # Calibration comparison
   # get each coeff and do deviation

   my %calAH = %{$dataA{'energy_cal'}};
   my %calBH = %{$dataB{'energy_cal'}};

   my $dev = 0;

   my %int_res = ();


   #-----------------------
   # CALIBRATION COMPARISON
   #-----------------------

   # sorted keys
   foreach my $key (sort keys %calAH) 
   {
     # get same key on calBH
     # if value not null on A and exists in B compute deviation
     if ( ($calAH{$key} != 0) &&  (exists $calBH{$key}) )
     {
       $dev = Util::round((($calBH{$key} - $calAH{$key}) / $calAH{$key})*100);       

       #print "deviation for $key: $dev \n";

       $int_res{$key}=$dev; 
     }
     else
     {
       $int_res{$key} = '-';
     }
   }

   $ref_results->{'energy_cal_dev'} = \%int_res;

   %calAH = %{$dataA{'efficiency_cal'}};
   %calBH = %{$dataB{'efficiency_cal'}};

   $dev = 0;

   my %eff_res = ();

   # sorted keys
   foreach my $key (sort keys %calAH) 
   {
     # get same key on calBH
     # if value not null on A and exists in B compute deviation
     if ( ($calAH{$key} != 0) &&  (exists $calBH{$key}) )
     {
       $dev = Util::round((($calBH{$key} - $calAH{$key}) / $calAH{$key})*100);       

       #print "deviation for $key: $dev \n";

       $eff_res{$key}=$dev; 
     }
     else
     {
       $eff_res{$key} = '-';
     }
   }

   $ref_results->{'efficiency_cal_dev'} = \%eff_res;

   %calAH = %{$dataA{'resolution_cal'}};
   %calBH = %{$dataB{'resolution_cal'}};

   $dev = 0;

   my %res_res = ();

   # sorted keys
   foreach my $key (sort keys %calAH) 
   {
     # get same key on calBH
     # if value not null on A and exists in B compute deviation
     if ( ($calAH{$key} != 0) &&  (exists $calBH{$key}) )
     {
       $dev = Util::round((($calBH{$key} - $calAH{$key}) / $calAH{$key})*100);       

       #print "deviation for $key: $dev \n";

       $res_res{$key}=$dev; 
     }
     else
     {
       $res_res{$key} = '-';
     }
   }

   $ref_results->{'resolution_cal_dev'}    = \%res_res;
}

# compare each necessary part (calibration, peaks, nuclide line id, ...)
sub _internal_comparison
{
   my ($self,$ref_dataA,$ref_dataB,$ref_id,@more) = @_;

   my %results = ();

   my %dataA = %{$ref_dataA};
   my %dataB = %{$ref_dataB};

   #add ref_id 
   $results{'sample_ref_id'} = $dataA{'sample_ref_id'};

   #-----------------------
   # Calibration Comparison
   #-----------------------
   # pass as ref the result Hash
   $self->_calibration_comparison($ref_dataA,$ref_dataB,\%results);

   #-----------------------
   # Matching Peaks
   #-----------------------
   $results{'peaks'}        = $self->_peaks_comparison($dataA{'peaks_data'},$dataB{'peaks_data'});
  
   #-----------------------
   # LineIded Comparison
   #-----------------------
   $results{'matching_line_ided'}    = $self->_lineided_comparison($dataA{'nucl_line_ided_data'},$dataB{'nucl_line_ided_data'});

   #-----------------------
   # nuclided Comparison
   #-----------------------
   $results{'matching_nuclide_ided'} = $self->_nuclided_comparison($dataA{'nucl_ided_data'},$dataB{'nucl_ided_data'});

   #-----------------------
   # CATEGORY COMPARISON
   #-----------------------
   my $auto_A = $dataA{'categories_sample_status'}{'AUTO_CATEGORY'};
   my $auto_B = $dataB{'categories_sample_status'}{'AUTO_CATEGORY'};
   my $rev_A  = $dataA{'categories_sample_status'}{'CATEGORY'};
   my $rev_B  = $dataB{'categories_sample_status'}{'CATEGORY'};

   $results{'categories'}{'auto_cat_A'}   = $auto_A;
   $results{'categories'}{'rev_cat_A'}    = $rev_A;
   $results{'categories'}{'auto_cat_B'}   = $auto_B;
   $results{'categories'}{'rev_cat_B'}    = $rev_B;
   $results{'categories'}{'auto_cat_dev'} = (defined $auto_A && defined $auto_B) ? $auto_A - $auto_B : undef;
   $results{'categories'}{'rev_cat_dev'}  = (defined $rev_A && defined $rev_B) ? $rev_A  - $rev_B : undef;

   #-----------------------------
   # TOTAL PEAKS FOUND COMPARISON
   #-----------------------------

   my $peaks_found_A = $dataA{'peaks_identified_and_found'}{'MAX(PEAK_ID)'};
   my $peaks_found_B = $dataB{'peaks_identified_and_found'}{'MAX(PEAK_ID)'};

   $results{'peaks_found_from_A'}  = $peaks_found_A ;
   $results{'peaks_found_from_B'}  = $peaks_found_B ;

   #unknown peaks in percentage
   # to be replaced with unknown
   my $unknown_A = $dataA{'peaks_identified_and_found'}{'COUNT(DISTINCTGL.PEAK)-MAX(PEAK_ID)'};
   my $unknown_B = $dataB{'peaks_identified_and_found'}{'COUNT(DISTINCTGL.PEAK)-MAX(PEAK_ID)'};

   $results{'peaks_unknown_from_A'}  = $unknown_A ;
   $results{'peaks_unknown_from_B'}  = $unknown_B ;
   
   # compute deviations and ratios 
   $results{'percentage_of_unknown_from_A'}   = (defined $unknown_A && defined $peaks_found_A) ? Util::round(abs($unknown_A/$peaks_found_A)*100): undef;
   $results{'percentage_of_unknown_from_B'}   = (defined $unknown_B && defined $peaks_found_B) ? Util::round(abs($unknown_B/$peaks_found_B)*100): undef;

   $results{'peaks_unknown_dev'} = (defined $results{'percentage_of_unknown_from_A'} && defined $results{'percentage_of_unknown_from_B'} && $results{'percentage_of_unknown_from_A'} != 0) ? Util::round((($results{'percentage_of_unknown_from_B'} - $results{'percentage_of_unknown_from_A'})/$results{'percentage_of_unknown_from_A'})*100) : undef; 

   $results{'sample_id_from_A'} = $dataA{'local_sample_id'};
   $results{'sample_id_from_B'} = $dataB{'local_sample_id'};

   $self->_save_and_render($ref_id,\%results);
}

sub _save_and_render
{
   my ($self,$ref_id,$results,@more) = @_;

   # create output dir if necessary
   Util::create_dir($self->{out_dir});

   #save results in file using YAML
   use YAML;
   my $YAML_HANDLE;
   open($YAML_HANDLE,">$self->{out_dir}/deviation-$ref_id") || die("Could not open file $self->{directory}/deviation-$ref_id");

   print {$YAML_HANDLE} Dump $results;

   # render if renderer defined and finalize 
   $self->{renderer}->render($results) if (defined $self->{renderer});
}

1;
__END__

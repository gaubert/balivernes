package AutoSaintTest; 

use strict;
use File::Path;
use base qw(Test::Unit::TestCase);


sub new 
{
  my($class,@more) = @_;
  my $self     = $class->SUPER::new(@more);

  bless ($self,$class);

  #$self->{directory} = $directory;

  return $self;
}

sub set_up 
{
  my ($self,@more) = @_;
  # provide fixture
  $self->_getEnv();
}

sub tear_down 
{
  my ($self,@more) = @_;
  # clean up after test
}

sub _getEnv
{
  my ($self,@more) = @_;

  # defaults
  $self->{database}        = (defined $ENV{'AS_DATABASE'}) ? $ENV{'AS_DATABASE'} : "127.0.0.1";
  $self->{user}            = (defined $ENV{'AS_USER'}) ? $ENV{'AS_USER'} : "rmsauto";
  $self->{pass}            = (defined $ENV{'AS_PASS'}) ? $ENV{'AS_PASS'} : "rmsauto";
  $self->{dir}             = (defined $ENV{'AS_SAMPLEDIR'}) ? $ENV{'AS_SAMPLEDIR'} : "./samples";
  $self->{logsdir}         = (defined $ENV{'AS_LOGSDIR'}) ? $ENV{'AS_LOGSDIR'} : "/tmp";
  $self->{autosaint_home}  = (defined $ENV{'AS_AUTOSAINTHOME'}) ? $ENV{'AS_AUTOSAINTHOME'} : ".";

  $self->assert_not_null($self->{database},"Need to have a database name");
  $self->assert_not_null($self->{user},"Need to have a user");
  $self->assert_not_null($self->{pass},"Need to have a password");
  $self->assert_not_null($self->{dir},"Need to have a sample directory");
  $self->assert_not_null($self->{logsdir},"Need to have a log directory");
  $self->assert_not_null($self->{autosaint_home},"Need to have autoSaint home directory");

  # create dir if necessary
  $self->_check_and_create_dir($self->{logsdir});
}

sub _add_sample
{
  my ($self,@more) = @_;

  print "\nAdd data for sample $self->{sampleid}\n";

  # use a SampleInsertor
  my $obj = SampleInsertor->new($self->{database},$self->{user},$self->{pass},$self->{dir});

  $obj->verbose(0);

  $obj->insert($self->{sampleid});

  print "\nSample $self->{sampleid} sucessfully added \n";

}

sub _empty_db
{
  my ($self,@more) = @_;

  print "\nclean database \n";

  # use a SampleInsertor
  my $obj = SampleInsertor->new($self->{database},$self->{user},$self->{pass},$self->{dir});

  $obj->verbose(0);

  $obj->empty_db();

  print "\nDatabase $self->{database} successfully emptied \n";

}

sub _check_and_create_dir
{
 my ($self,$directory,@more) = @_;

 die "need a directoy value" unless (defined $directory);

 mkpath(($directory), {verbose => 1, mode => 0750, error => \my $err},);

 for my $diag (@$err) {
    my ($file, $message) = each %$diag;
    print "problem unlinking $file: $message\n";
  }
}

sub _run_for_sample
{
  my ($self,$test_name,@more) = @_;

  my $command = "$self->{autosaint_home}/autoSaint DBServer=local_dev DBUser=rmsauto DBPassword=rmsauto SampleID=$self->{sampleid} IntermediateResultFile=/tmp/$self->{sampleid} Overwrite=YES RiskLevelIndex=3 LogLevel=9 RmsHome=/home/aubert/dev/c/autoSaint/Bin/results/ BaselineDir=base ScacDir=scac > $self->{logsdir}/$test_name.log";

  print "run autosaint command : $command\n";

  system($command);

  if ( $? == -1)
  {
    print "clean command failed: $!\n";
  }
  elsif ($? > 0)
  {
    printf "\nError: Sql error code %d. See logs in %s\n", $command, $? >> 8,"$self->{logsdir}/$test_name.log";
  }
  else
  {
    printf "\nsql autosaint run successful\n";
  }

  return $?;
}

# Assert that a file contains the following lines
sub assert_file_line_matches
{
  my ($self,$value,$filename,$linenb) = @_;

  $self->assert_not_null($value,"assert_file_contains: Need a value to match against a file content");
  $self->assert_not_null($filename,"assert_file_contains: Need a file to search in");

  # line to zero if undefined 
  $linenb = -1 unless (defined $linenb);

  my $file_handle = undef;

  open($file_handle,$filename) || die("Could not open file $filename"); 

  my $line   = undef;
  my $linereadnb = 0;

  if ($linenb != -1)
  {

     do
     {
       $line = <$file_handle>;
       $linereadnb++; 
     }
     until ($linereadnb == $linenb || eof); 

     #print "line read $line.linenb = $linenb\n";

     $self->assert(0,"Error: Cannot find $value in line $linenb of file $filename.\n Line Read:\n$line\n") if ($line !~ m{$value}g);
  }
  else
  {
    # check for each line
    my %results = ();
    do
    {
       $line = <$file_handle>;
       # linereadnb starts at 1 so increment linereadnb first
       $linereadnb++;

       $results{$linereadnb} = $line if ($line =~ m{$value}g);
    }
    until (eof); 

    my $results_nb = keys %results; 

    $self->assert(($results_nb > 0),"Error: Cannot find $value in file $filename\n");

    # print where the match has been done
    for my $key ( keys %results ) 
    {
        my $val = $results{$key};
        print "\nFound $value on line $key. Read Line $val\n";
    }
  }
}

# Assert that valueA(+-approximation) = valueB
# err coefficient in % (percents)
sub assert_values_with_approximation_equals
{
  my ($self,$valueA,$valueB,$errA) = @_;

  $self->assert_not_null($valueA,"assert_values_with_approximation_equals: Need a valueA to match against another value");
  $self->assert_not_null($valueB,"assert_values_with_approximation_equals: Need a valueB to match against another value");

  $errA = 0 unless (defined $errA);

  # get min and max of valueA
  my $dummy = ($valueA - ($valueA * $errA));

  my $minA = ($dummy > 0) ? $dummy : $valueA;

  dummy = ($valueA + ($valueA * $errA));

  my $maxA = ($dummy > 0) ? $dummy : $valueA;

  my $is_correct = ( ($minA <= $valueB) and ($valueB >= $maxA) );

  return $is_correct;
}

#################### The Tests ######################################


sub test_105229 
{
   my ($self,@more) = @_;

   $self->{sampleid} = 105229;

   print "\n********* Start test_105229 *********\n";
   $self->_add_sample();

   my $result = $self->_run_for_sample("test_105229"); 
  
   $self->assert_num_equals($result,0,"Error: Test for sample $self->{sampleid} failed. Err Code $result. See logs in $self->{logsdir}/test_105229.log");

   print "\n********* End of test_105229 *********\n";

   #$self->assert_file_line_matches("TYPEID from FPDESCRIPTION|Main threshold:               5000.000000","$self->{logsdir}/test_$self->{sampleid}.log");
   $self->assert_file_line_matches("MRP A energy: degree: 2, coeffs: 8.740076e-02 1.710559e-01 -7.556653e-09","$self->{logsdir}/test_105229.log",115);

   return 0;
}

sub test_153716
{
   my ($self,@more) = @_;

   $self->{sampleid} = 153716;

   print "\n********* Start test_153716 *********\n";
   $self->_add_sample();

   my $result = $self->_run_for_sample("test_153716"); 
  
   $self->assert_num_equals($result,0,"Error: Test for sample $self->{sampleid} failed. Err Code $result. See logs in $self->{logsdir}/test_153716.log");

   print "\n********* End of test_153716 *********\n";

   $self->assert_file_line_matches("MRP A energy: degree: 2, coeffs: -1.492070e-01 3.293181e-01 -4.644419e-08","$self->{logsdir}/test_153716.log",119);

   return 0;
}

sub test_105229_with_emptydb
{
   my ($self,@more) = @_;

   $self->{sampleid} = 105229;

   print "\n********* Start test 105229_with_emptydb *********\n";
   $self->_empty_db();

   my $result = $self->_run_for_sample("test_105229_with_emptydb"); 

   print "Result code = $result\n";

   $self->assert_num_not_equals($result,0,"Error: Test for sample $self->{sampleid} failed. Err Code $result. See logs in $self->{logsdir}/test_105229_with_emptydb.log");
   $self->assert_file_line_matches("Error getting STATUS from GARDS_SAMPLE_STATUS ()","$self->{logsdir}/test_105229_with_emptydb.log",14);

   print "\n********* End of test 105229_with_emptydb *********\n";

   return 0;
}

1;

__END__

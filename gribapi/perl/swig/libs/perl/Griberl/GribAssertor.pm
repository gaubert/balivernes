package GribAssertor;

use strict;
use File::Path;
use File::Basename;
use Data::Dumper;
use Common::Conf;
use Griberl::GribMsgIterator;
use Griberl::GribMsg;

# Class Members

#debuging
my $COMP_DEBUG=0;

# Class Methods

# Constructor
sub new 
{
  my ($class,$conf_file,$file_l_ref,@more) = @_;

  #print "Conf_file = $conf_file, files=$file_l_ref\n";

  #my $files = (defined $file_l_ref) ? $file_l_ref : ();

  

  my $self  = {
      conf_file         => $conf_file,
      conf_read         => 0,
      file_l_ref        => (defined $file_l_ref) ? $file_l_ref : (),
      conf              => {},
      exist_rule        => undef,
      levels_rule       => {},
      nb_of_levels_rule => {},
      ignore_rule       => {},
      date_rule         => 0,
      use_shortname     => 0,
      date_format_rule  => "iiyymmddhh",
      ignored_actions   => {},
  };

  # Blessing
  bless ($self,$class);

  $self->_init();

  print "After initialization:".Dumper($self) if $COMP_DEBUG; 

  return $self;
}

# Accessors
sub conf_file 
{
   my ($self,$args) = @_;
   $args ? $self->{conf_file} = $args  #modify
         : $self->{conf_file};         # access
} 

sub file_list
{
   my ($self,$args) = @_;
   $args ? $self->{file_l_ref} = $args  #modify
         : $self->{file_l_ref};         # access
} 

sub _read_conf
{
  my ($self,$args) = @_;
  $self->{conf} = new Conf();

  # read dies if error
  $self->{conf}->read($self->{conf_file});

  $self->{conf_read} = 1;
}

sub _init
{
  my ($self,$args) = @_;

  $self->_read_conf() unless $self->{conf_read};

  # create exist structure => list containing the parameter to check
  my @vals = $self->{conf}->get("General","param_exists"); 

  $self->{exist_rule} = \@vals;
  
  # create levels structures => hash containing parameters
  my %levels = $self->{conf}->get_group("Levels");

  for my $key ( keys %levels ) 
  {
    print "Levels key = $key\n";
    my @t_vals = $self->{conf}->get("Levels",$key);

    $self->{levels_rule}{$key} = \@t_vals;
  }

  # create levels Nb structures 
  my %nbOfLevels = $self->{conf}->get_group("NbOfLevels");

  for my $key ( keys %nbOfLevels ) 
  {
    my @t_vals = $self->{conf}->get("NbOfLevels",$key);

    #add the number of found levels. 0 at the moment.
    $t_vals[1] = '0';

    $self->{nb_of_levels_rule}{$key} = \@t_vals;
  }

  # read checkdate and date format
  if ($self->{conf}->is_true("General","check_date"))
  {
    if ($self->{conf}->exists_in_group("General","date_format"))
    {
       $self->{date_format_rule} = $self->{conf}->get("General","date_format");
       $self->{date_rule}        = 1;
    }
  }

  if ($self->{conf}->is_true("General","use_shortname"))
  {
    $self->{use_shortname} = 1;
  }

  # store the regular expr describing which files have to be ignored
  my %ignored = $self->{conf}->get_group("Ignore");

  for my $key ( keys %ignored ) 
  {
    my @t_vals = $self->{conf}->get("Ignore",$key);

    $self->{ignore_rule}{$key} = \@t_vals;
  }
}

sub check
{
  my ($self,$args) = @_;

  my $ref = $self->{file_l_ref};

  my $grib_file = undef;

  foreach $grib_file (@$ref)
  {
     print STDOUT "Check $grib_file \n";

     my $gIter = new GribFileIterator($grib_file);  
     
     my $nbIter = 0;
     while ( (defined (my $gribMsg = $gIter->next_grib())) )
     {
       # assert that the date is the same in the header and in the filename
       $self->_assert_date($gribMsg,$grib_file) unless ($self->_is_ignored("date",$grib_file));

       # check that the parameter indicated in the conf exist
       $self->_check_exists($gribMsg) unless ($self->_is_ignored("exist",$grib_file));

       $self->_check_levels($gribMsg) unless ($self->_is_ignored("levels",$grib_file));

       $self->_check_nb_levels($gribMsg) unless ($self->_is_ignored("nb_of_levels",$grib_file));

       $nbIter++;

     }

     print STDOUT "After Checking ".Dumper($self) if $COMP_DEBUG; 
 
     #post conditions, assert that everything has been found
     $self->_assert_all($grib_file);

     # reset values for each new file
     $self->_init();
  }
}

#check if the current filename must be ignored
sub _is_ignored
{
  my ($self,$action,$filename,$args) = @_;

  #print "action $action, filename $filename. $self->{ignore_rule}->{$action}[0]\n";

  # if defined key for action in ignore then get list of regular exprs and try to match filename
  # if it matches ignore

  if (defined $self->{ignore_rule}->{$action}) 
  {
    my $l = $self->{ignore_rule}->{$action};

    foreach my $regex (@$l)
    {
      if ($filename =~ m/$regex/)
      {
        $self->{ignored_actions}->{"$filename:$action"} = 1;
        return 1;
      }
    }

    return 0;
  }
}

sub _error_and_quit
{
  my ($self,$errorMsg,$args) = @_;

  my $msg = "";
  for my $key ( keys %{$self->{ignored_actions}} )
  {
    my ($fname,$action) = split(/:/,$key);
    #print "key = $key\n";
    $msg .= "ignored $action checking in $fname \n"; 
  }

  print STDOUT $msg;

  print STDERR $errorMsg;

  exit 2;
}

sub _check_exists
{
  my ($self,$gribMsg,$args) = @_;

  my $param = ($self->{use_shortname}) ? $gribMsg->get("short_name") : $gribMsg->get("param");

  if ( defined $param )
  {
    my $size = @{$self->{exist_rule}};

    # if found in grib remove it
    for (my $i = 0; $i < $size; $i++)
    {
      #print "i=$i, val = @{$self->{exist_rule}}[$i], param = $param\n";
      if ( (defined @{$self->{exist_rule}}[$i]) && (@{$self->{exist_rule}}[$i] eq $param) )
      {
         #print "found $param. Delete $param\n";
         delete @{$self->{exist_rule}}[$i];

         #leave loop now 
         return; 
      }
    }
  }
}

sub _check_nb_levels
{
  my ($self,$gribMsg,$args) = @_;

  my $param = ($self->{use_shortname}) ? $gribMsg->get("short_name") : $gribMsg->get("param");

  #print "check_nb_levels. Look for param = ".$gribMsg->get("short_name").", level = ".$gribMsg->get("lev")."\n";

  if ( defined $param )
  {
    if (defined $self->{nb_of_levels_rule}{$param})
    {
       #print "Found nb of levels ". $self->{nb_of_levels_rule}{$param}[1]."increment it \n";
       ($self->{nb_of_levels_rule}{$param}[1])++;
    }
  }
}

sub _assert_date
{
  my ($self,$gribMsg,$filename,$args) = @_;

  # for the moment it is the only support format
  # i for ignore, y for year, m for month, d for day, h for hour
  if ($self->{date_format_rule} eq 'iiyymmddhh')
  {
    #get date from filename 
    my $basename = basename($filename);

    my $date = substr($basename,2,6);

    # remove the first two characters which are 20 for 2008
    my $grib_date = substr($gribMsg->get("date"),2);

    $self->_error_and_quit("Error in grib file $filename: The filename date ($date) and the grib date ($grib_date) are different\n") unless ($grib_date eq $date);
  }
  else
  {
    $self->_error_and_quit("Error : Do not support the following date format $self->{date_format_rule}. only iiyymmddhh is supported at the moment\n");
  }
}

sub _assert_exists
{
  my ($self,$filename,$args) = @_;

  # check that the exist_rule is empty (empty arr) otherwise error
  my $msgPart = ($self->{use_shortname}) ? " short_name " : " parameters ";

  $self->_error_and_quit("Error in grib file $filename: the following $msgPart @{$self->{exist_rule}} could not be found.\n") if (@{$self->{exist_rule}} != 0);
}

sub _assert_nb_levels
{
  my ($self,$filename,$args) = @_;

  #print "In assert_nb_levels\n";

  my $foundError = 0;
  my $msg = "Error in $filename:\n";

  while (my ($key, $value) = each(%{$self->{nb_of_levels_rule}}))
  {
    # check that the number of levels counted is eq to the number of expected levels
    if (@$value[0] ne @$value[1])
    {
       $msg .= "Error in grib file $filename: Expected to find @$value[0] levels for param $key but found @$value[1]\n";       
       $foundError = 1;
    }
  }
  
  $self->_error_and_quit($msg) if ($foundError == 1);
}

sub _assert_levels
{
  my ($self,$filename,$args) = @_;

  # if no more elements left in level rules OK otherwise error
  my $size = keys( %{$self->{levels_rule}} );

  if ($size > 0)
  {
    my $msg ="Error in $filename:\n";
    while (my ($key, $value) = each(%{$self->{levels_rule}}))
    {
      $msg = $msg."Error in grib file $filename: Could not find ". join(",",@$value)." for parameters $key\n";
    }
    $self->_error_and_quit($msg);
  }
}

sub _check_levels
{
  my ($self,$gribMsg,$args) = @_;

  my $param = $gribMsg->get("param");

  if ( defined $param )
  {
     if (defined $self->{levels_rule}{$param})
     {
        my $size = @{$self->{levels_rule}{$param}};
 
        for (my $i; $i < $size; $i++)
        {
           if ( @{$self->{levels_rule}{$param}}[$i] eq $gribMsg->get("lev") )
           {
              #print "Found level ". $gribMsg->get("lev")." for param $param. Delete this level \n";
              splice(@{$self->{levels_rule}{$param}}, $i, 1);
              
              # check if array is empty. If yes then remove hash entry
              delete $self->{levels_rule}{$param} unless @{$self->{levels_rule}{$param}};
           }
        }
     }
  }
}

# die if the conditions have not been fullfiled
sub _assert_all
{
  my ($self,$filename,$args) = @_;

  $self->_assert_exists($filename) unless ($self->_is_ignored("exist",$filename));

  $self->_assert_levels($filename) unless ($self->_is_ignored("levels",$filename));

  $self->_assert_nb_levels($filename) unless ($self->_is_ignored("nb_of_levels",$filename));
}


# Destructor
sub DESTROY 
{

} 


1;
__END__

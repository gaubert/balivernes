package Util;

use strict;
use File::Path;
use Data::Dumper;

## GLOBALS
my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
my @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);

#######################
# return localtime as a
# readable string
#######################
sub localtime_as_string
{
    my (@args) = @_;

    my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
    my $year = 1900 + $yearOffset;
    my $theTime = "$weekDays[$dayOfWeek] $months[$month] $dayOfMonth $year, $hour:$minute:$second";

    return $theTime; 
}

##############################
# round numerical value
# params= value to round
# and number of decimal digits
##############################
sub round
{
  my ($val,@args) = @_;

  ## default 3 digits after .
  my $round_str = "%.3f";

  #one argument then X digits (the first argument is the number of digits)
  if (@args == 1)
  {
    $round_str = "%.$args[0]f";
  }
  
  if (defined $val) 
  {
    return sprintf($round_str, $val);
  }
  else
  {
    return $val;
  } 

}

#############################
# create a directories in the 
# path if they do not already
# exist
#############################
sub create_dir
{
 my ($directory,$verbose,@more) = @_;

 die "need a directoy value" unless (defined $directory);

 $verbose = 0 unless (defined $verbose);

 mkpath(($directory), {verbose => $verbose, mode => 0750, error => \my $err},);

 for my $diag (@$err) 
 {
    my ($file, $message) = each %$diag;
    print "problem unlinking $file: $message\n";
 }
}

sub del_dir
{
  my ($directory,$verbose,@more) = @_;

  die "need a directoy value" unless (defined $directory);

  $verbose = 0 unless (defined $verbose);

  rmtree(($directory), $verbose,1);
}

sub get_absolute_path
{
  my ($path,@more) = @_;

  use Cwd 'abs_path';

  return abs_path($path);
}


1;
__END__

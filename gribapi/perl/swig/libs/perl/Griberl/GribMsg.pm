package GribMsg;

use strict;
use File::Path;
use Data::Dumper;
use Common::Conf;
use grib4perl;

# Class Members

# Class Methods

# Constructor
sub new 
{
  my ($class,$grib_handle,@more) = @_;

  my $self  = {
      grib_handle      => $grib_handle,
  };

  die "grib_handle undefined" unless (defined $grib_handle);

  # Blessing
  return bless ($self,$class);
}

# Accessors
sub _grib_handle
{
   my ($self,$args) = @_;
   $args ? $self->{grib_handle} = $args  #modify
         : $self->{grib_handle};         # access
} 

sub key_exits
{
  my ($self,$key,$args) = @_;

  my ($res,$value) = grib4perl::grib_get_string($self->{grib_handle},$key);

  return ($res == 0) ? 1 : 0;


}

# if undef returned it means that there are no key with this name
# by default return a string
sub get
{
  my ($self,$key,$args) = @_;
   
  my ($res,$value) = grib4perl::grib_get_string($self->{grib_handle},$key);

  return ($res == 0) ? $value : undef;
}

sub get_as_long
{
  my ($self,$key,$args) = @_;
   
  my ($res,$value) = grib4perl::grib_get_long($self->{grib_handle},$key);

  return ($res == 0) ? $value : undef;

}

# Destructor
sub DESTROY 
{
  my ($self,$args) = @_;

  #print "Destroy grib handle\n";
   
  # delete grib_handle
  my $delret = grib4perl::grib_handle_delete($self->{grib_handle}) if (defined $self->{grib_handle});
} 


1;
__END__

package GribFileIterator;

use strict;
use grib4perl;
use Griberl::GribMsg;


# Class Members

# Class Methods

# Constructor
sub new 
{
  my ($class,$grib_file,@more) = @_;

  my $self  = {
      grib_file        => $grib_file,
      file_handle      => undef,
      curr_grib_handle => undef,
  };

  # Blessing
  my $tempo = bless ($self,$class);

  $self->_check_file_exists();

  return $self;
}

sub _check_file_exists
{
  my ($self,$args) = @_;

  die "Error: no grib_file $self->{grib_file}" if (! defined $self->{grib_file});

  die "Error: $self->{grib_file} doesn't exist" if (! -f "$self->{grib_file}");

  my $fh = undef;

  #print "Grib_file = $self->{grib_file}\n";

  open($self->{file_handle},$self->{grib_file}) || die "Error: Cannot open grib file $self->{grib_file}";

  return;
}

# return grib handle internally
sub _get_grib_handle
{
  my ($self,$args) = @_;

  (my $tempo_handle,my $err) = grib4perl::grib_handle_new_from_file(undef,$self->{file_handle});

  die "err $err when trying to get a hanlde on the next grib" if ($err != 0);

  if (defined $tempo_handle) 
  {
    $self->{curr_grib_handle} = $tempo_handle;
    # return grib_handle by default
    return $tempo_handle;
  }
  else
  {
    return undef;
  }
}

# Accessors
sub grib_file 
{
   my ($self,$args) = @_;
   $args ? $self->{grib_file} = $args  #modify
         : $self->{grib_file};         # access
} 

sub file_handle 
{
   my ($self,$args) = @_;
   $args ? $self->{file_handle} = $args  #modify
         : $self->{file_handle};         # access
} 

sub next_grib
{
  my ($self,$args) = @_;

  # give the ownership to the grib_handle to the GribMsg object
  my $nGH = $self->_get_grib_handle();

  return (defined $nGH ) ? new GribMsg($nGH) : undef;
}

sub current_grib
{
  my ($self,$args) = @_;

  return $self->{curr_grib_handle};
}

# Destructor
sub DESTROY 
{
} 


1;
__END__

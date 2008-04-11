#!/usr/bin/perl
# Perl5 script for testing simple grib4perl

use strict;
use grib4perl;

print "Hello\n";

my $err = 0;
my $fh;
#open($fh,"regular_latlon_surface.grib1") || die "error!\n";
open($fh,"GD08012300.grib1") || die "cannot read file error!\n";

#my $gh = grib4perl::grib_handle_new_from_file(undef,*OUT,\$err);

my ($gh,$err) = grib4perl::grib_handle_new_from_file(undef,$fh);
my $nbgribs =1;
while ( defined $gh && $err == 0)
{
  $nbgribs++; 
  ($gh,$err) = grib4perl::grib_handle_new_from_file(undef,$fh);

  if ($err == 0) 
  {
    my $ret = grib4perl::grib_handle_delete($gh);
  }
}

print "There was $nbgribs-1 in $fh\n";

#my $valuelen = -1; 

#my $res      = -1;

#($res,$valuelen) = grib4perl::grib_get_size($gh,"values");
#print "res = $res. value len =$valuelen\n";

#my $editionNumber = -1;
#($res,$editionNumber) = grib4perl::grib_get_long($gh,"editionNumber");
#print "res = $res. value editionNumber =$editionNumber\n";

#($res,my $gribTablesVersionNo) = grib4perl::grib_get_long($gh,"gribTablesVersionNo");
#print "res = $res. value grid table version number = $gribTablesVersionNo\n";

#($res,my $value) = grib4perl::grib_get_double_element($gh,"values",4);
#print "res = $res. Third value in data array= $value\n";

# get values
#my $values = grib4perl::new_doubleArray($valuelen);
#grib4perl::delete_doubleArray($values);
#$res = grib4perl::grib_get_double_array($gh,"values",$values,$valuelen);
#print "valuelen = $valuelen\n";
#grib4perl::print_doubleArray($values,$valuelen);

## iterate on keys
#my $key_iterator_filter_flags = $grib4perl::GRIB_KEYS_ITERATOR_ALL_KEYS;

#print "Define from .h file=$grib4perl::GRIB_KEYS_ITERATOR_ALL_KEYS\n";

#my $name_space = undef;

#my $kiter = grib4perl::grib_keys_iterator_new($gh,$key_iterator_filter_flags,$name_space);

#my $vlen  = $grib4perl::MAX_VAL_LEN;
#my $value = "hello";
#($res,$value) = grib4perl::grib_get_string($gh,"editionNumber");
#printf("res=%d.%s = %s\n",$res,"editionNumber",$value);
#($res,$value) = grib4perl::grib_get_string($gh,"date");
#printf("res=%d. %s = %s\n",$res,"date",$value);

#while(grib4perl::grib_keys_iterator_next($kiter))
#{
#  my $name   = grib4perl::grib_keys_iterator_get_name($kiter);
#  my $value  = "";
#  ($res,$value)  = grib4perl::grib_get_string($gh,$name);
#  printf("leng(string)=%d. res=%d. %s = %s\n",length($value),$res,$name,$value);
#}

#grib4perl::grib_keys_iterator_delete($kiter);

#my $ret = grib4perl::grib_handle_delete($gh);

#print "can delete grib_handle ret=$ret\n";

# Manipulate the Foo global variable

# Output its current value
#print "Foo = $grib4perl::Foo\n";

# Change its value
#$grib4perl::Foo = 3.1415926;

# See if the change took effect
#print "Foo = $grib4perl::Foo\n";


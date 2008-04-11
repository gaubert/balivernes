#!/usr/bin/perl
# Perl5 script for testing simple grib4perl

use strict;
use GribMsgIterator;

#my $GribSet = new GribFileIterator("./regular_latlon_surface.grib1");
my $GribSet = new GribFileIterator("./GD08012300.grib1");

my $fh = $GribSet->file_handle();

#print "file handle = $fh\n";



my $GribMsg = undef;

while ( (defined ($GribMsg = $GribSet->next_grib())) )
{

   my $val = $GribMsg->get("date");

   print "Value = $val\n";
}

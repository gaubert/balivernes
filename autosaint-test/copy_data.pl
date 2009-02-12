#!/usr/bin/perl -w

use strict;
#use POSIX;

#my $d = POSIX::strptime("2008-10-01", "%Y-%m-%d");

my $result = (localtime)[7];

print "day of the year = $result\n";







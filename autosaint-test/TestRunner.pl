#!/usr/bin/perl

use Test::Unit::TestRunner;
use SampleInsertor;

$ENV{'AS_DATABASE'}             = '127.0.0.1';
$ENV{'AS_USER'}                 = 'rmsauto';
$ENV{'AS_PASS'}                 = 'rmsauto';
$ENV{'AS_SAMPLEDIR'}            = './samples';
$ENV{'AS_LOGSDIR'}              = './logs';
$ENV{'AS_AUTOSAINTHOME'}        = '/home/aubert/dev/c/autoSaint1.2/Bin';

#print "AS_DB=$ENV{'AS_DB'}\n";

my $testrunner = Test::Unit::TestRunner->new();

$testrunner->start(AutoSaintTest);

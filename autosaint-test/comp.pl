#!/usr/bin/perl -w 

use strict;
use AutoSaintComparator;
use HtmlRenderer;

use Cwd 'abs_path';

my $path = abs_path('./html-report');

print "path=$path\n";

my @l = ('AUP08','CAP16','DEP33','FRP27','SEP63');

my $str = join(',',@l);

print "STR=$str\n";

my $renderer = HtmlRenderer->new('/home/aubert/autoSaintWork/autosaint-test-v0.6/html-report');

#my $comp = AutoSaintComparator->new("./unique-ref-data","./unique-comp-data","./unique-comp-data",$renderer,5);
my $comp = AutoSaintComparator->new("./ref-data","./ref-data","./comp-data",$renderer,7);

$comp->compare();




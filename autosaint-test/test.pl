#!/usr/bin/perl -w 

use strict;
use AutoSaintCompExtractor;
use AutoSaintComparator;
use HtmlRenderer;

#my $ex = AutoSaintCompExtractor->new("maui","rmsuser","rmsuser","/tmp/test-db");
print "Create \n";
#my $ex = AutoSaintCompExtractor->new("idcdev","centre","data","/tmp/ref-data");

#$ex->connect();

my $clean_cache = 1;

#my @list = ('\'AUP08\'','\'CAP16\'','\'DEP33\'','\'FRP27\'','\'SEP63\'');
#my @list = ('\'AUP08\'');
#$ex->get_autosaint_data_to_compare_from_stations_ids("maui","rmsuser","rmsuser",\@list,0);

#my @sids_list = (152396,152397);
#$ex->get_autosaint_data_to_compare_from_sample_ids(\@sids_list,$clean_cache);

#my @sids_list = (664563,664564,664565,664566,664567);
#$ex->get_autosaint_data_to_compare_from_sample_ids(\@sids_list,$clean_cache);

#print "before get_autosaint_reference_data \n";
#$ex->get_autosaint_reference_data($clean_cache);
#print "after get_autosaint_reference_data \n";


### FULL PROCESS ###
my $ex = AutoSaintCompExtractor->new("idcdev","centre","data","./to-compare-data");
$ex->connect();

my @sids_list = (152396,115606,101011);
$ex->get_autosaint_data_to_compare_from_sample_ids(\@sids_list,$clean_cache);

# renderer to prduce report
my $renderer = HtmlRenderer->new('/home/aubert/autoSaintWork/autosaint-test-v0.6/html-report');

#dirA,dirB,outputDir
my $comp = AutoSaintComparator->new("./to-compare-data","./new-ref-data","./deviation",$renderer,5);

$comp->compare();

$ex->disconnect();






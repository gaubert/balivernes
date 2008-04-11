#!/usr/bin/perl -w 

use strict;
use AutoSaintCompExtractor;
use HtmlRenderer;

#my $ex = AutoSaintCompExtractor->new("maui","rmsuser","rmsuser","/tmp/test-db");
my $ex = AutoSaintCompExtractor->new("idcdev","centre","data","/tmp/test-db");

$ex->connect();

my $clean_cache = 1;

#my @list = ('\'AUP08\'','\'CAP16\'','\'DEP33\'','\'FRP27\'','\'SEP63\'');
#my @list = ('\'AUP08\'');
#$ex->get_autosaint_data_to_compare_from_stations_ids("maui","rmsuser","rmsuser",\@list,0);

my @sids_list = (152396,152397);
$ex->get_autosaint_data_to_compare_from_sample_ids(\@sids_list,$clean_cache);

#my @sids_list = (664563,664564,664565,664566,664567);
#$ex->get_autosaint_data_to_compare_from_sample_ids(\@sids_list,$clean_cache);

$ex->disconnect();






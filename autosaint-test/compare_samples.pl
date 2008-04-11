#!/usr/bin/perl -w

#use lib 'libs/ext';
#use lib 'libs/local';

use strict;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
use Common::AutoSaintCompExtractor;
use Common::AutoSaintComparator;
use Common::HtmlRenderer;

#
# Release number.
#
my $RELEASE         = '1.0';

# Default Values
my $USER            = 'centre';
my $PASS            = 'data';
my $DB              = 'idcdev.ctbto.org';
my $ACTION          = 'compare';
my $CACHE           = 1;
my $DEVIATIONDIR    = "/tmp/deviations";
my $REPORTDIR       = "./html-report";
my $PCOEFF          = 10;
my $APERC           = 10;
my $RDIR            = "./etc/data/ref-data";

# necessary options
my $SDIR             = undef;
my $SIDS_STR         = undef;


#
#  Parse command line arguments. Overide global values 
#
parseCommandLineArguments();

#
#  Do more stuff ..
#
execute();

#
#  All done
#
exit;

# functions

=head2 parseCommandLineArguments

  Parse the arguments specified upon the command line.

=cut

sub parseCommandLineArguments
{
    my $HELP        = 0;   # Show help overview.
    my $MANUAL      = 0;   # Show manual
    my $VERSION     = 0;   # Show version number and exit.

    #  Parse options.
    #
    my $result = GetOptions(
                            "help",                    => \$HELP,
                            "manual",                  => \$MANUAL,
                            "version",                 => \$VERSION,
                            'reference_dir|rdir=s'     => \$RDIR,
                            'samples_dir|sdir=s'       => \$SDIR,
                            'deviation_dir|ddir=s'     => \$DEVIATIONDIR,
                            'reports_dir|repdir=s'     => \$REPORTDIR,
                            'cache!'                   => \$CACHE,
                            'user|u=s'                 => \$USER,
                            'password|p=s'             => \$PASS,
                            'database|db=s'            => \$DB,
                            'action|act'               => \$ACTION,
                            'peaks_coeff|pcoeff=s'     => \$PCOEFF,
                            'anomaly_perc|aperc=s'     => \$APERC,
                           ) or pod2usage(1);

    pod2usage(1) if $HELP;
    pod2usage(-verbose => 2 ) if $MANUAL;

    if ( $VERSION )
    {
      print "version $RELEASE\n";
      exit;
    }

    if (! defined $RDIR)
    {
       print STDERR "Error: need a directory containing the reference data\n"; 
       pod2usage(1);
    }

    if (! defined $SDIR)
    {
       print STDERR "Error: need a directory where to generate the produced data\n"; 
       pod2usage(1);
    }

}

# functions

=head2 execute

  extract all the necessary data to create a sample environement for autosaint

=cut

sub execute
{
  if ($ACTION eq 'compare')
  {
    compare();
  }
  elsif ($ACTION eq 'generate_ref')
  {
    print "generate references";
  }
  else
  {
    die "Error unknown action $ACTION\n";
  }
}

sub compare
{

my @sids_list = @ARGV;

die "\nError: need a list of sample IDS as arguments\n" if (@sids_list == 0);

#print "ARGV @sids_list\n, CACHE=$CACHE";

my $nocache = !$CACHE;

my $ex = AutoSaintCompExtractor->new($DB,$USER,$PASS,$SDIR);
$ex->connect();

#my @sids_list = (152396,115606,101011);
$ex->get_autosaint_data_to_compare_from_sample_ids(\@sids_list,$nocache);

# renderer to prduce report
my $renderer = HtmlRenderer->new($REPORTDIR,$APERC);

#dirA,dirB,outputDir
my $comp = AutoSaintComparator->new($SDIR,$RDIR,$DEVIATIONDIR,$renderer,$PCOEFF);

$comp->compare();

$ex->disconnect();

}

__END__

=head1 NAME

compare_samples.pl - compare a list of sample_ids data against reference data

=head1 SYNOPSIS

  compare_samples.pl [options] sample_ids

  Mandatory Options:
  --samples_dir   (-sdir)  Directory where the sample data is going to be stored 

  Extra Options:
  --reference_dir (-rdir)  Directory containing the reference data                 (default= ./etc/data/ref-data)
  --action       (-act)     Command line action [compare|generate_ref]             (default= compare) 
  --peaks_coeff  (-pcoeff)  Peaks coefficient used in the peaks matching formula   (default= 10) 
  --anomaly_perc (-aperc)   All computed deviations will be flagged as anomalies   (default= 10)
                            if superior or equal to this value
  --nocache                 To not use the cached information and regenerate a new dataset 
  --database     (-db)      Database name to access                      (default= idcdev.ctbto.org)
  --user         (-u)       Database user                                (default= centre)
  --password     (-p)       Database password                            (default= password of the centre user)

  Help Options:
   --help     Show this scripts help information.
   --manual   Read this scripts manual.
   --version  Show the version number and exit.

  Examples:
  ./compare_samples.pl -sdir ~/sample-dir 123456 345677 889909

  or using xargs in order to read a file containing the list of sample ids:
  cat ./etc/sample_ids_example | xargs ./compare_samples.pl -sdir ~/sample-dir -nocache

=cut

=head1 EXAMPLES

  The following is an example of this script:
   
  ./compare_samples.pl -rdir -sdir ./sample-dir 123456 345677 889909

  or using xargs in order to read a file containing the list of sample ids:
  cat ./etc/sample_ids_example | xargs ./compare_samples.pl -sdir ~/sample-dir -nocache
  

=cut


=head1 DESCRIPTION

  Perform AutoSaint Comparison in order to assess AutoSaint

=cut


=head1 AUTHOR


 Guillaume Aubert
 --
 guillaume.aubert@ctbto.org

=cut

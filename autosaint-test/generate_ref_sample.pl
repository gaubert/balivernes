#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use Pod::Usage;
use File::Path;
use Data::Dumper;
#use Extractor;
use AutoSaintCompExtractor;

#
# Release number.
#
my $RELEASE         = '0.5';

# Default Values
my $USER            = 'rmsuser';
my $PASS            = 'rmsuser';
#my $DB              = 'idcdev.ctbto.org';
my $DB              = 'maui';

# necessary options
my $SAMPLEID        = undef;
my $DIR             = undef;

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
                            'directory|dir=s'          => \$DIR,
                            'user|u=s'                 => \$USER,
                            'password|p=s'             => \$PASS,
                            'database|db=s'            => \$DB,
                           ) or pod2usage(1);

    pod2usage(1) if $HELP;
    pod2usage(-verbose => 2 ) if $MANUAL;

    if (! defined $DIR)
    {
       print STDERR "Error: need a directory to store the produced data\n"; 
       pod2usage(1);
    }

    if ( $VERSION )
    {
    my $REVISION      = '$Id: main,v0.5 2008/02/07 10:00:00 guillaume Exp $';
    $VERSION = join (' ', (split (' ', $REVISION))[2]);
    $VERSION =~ s/,v\b//;
    $VERSION =~ s/(\S+)$/$1/;

    print "main release $RELEASE - CVS: $VERSION\n";
    exit;
    }
}

# functions

=head2 execute

  extract all the necessary data to create a sample environement for autosaint

=cut

sub execute
{

my $ex = AutoSaintCompExtractor->new($DB,$USER,$PASS,"$DIR");

$ex->connect();

$ex->get_autosaint_reference_data();

$ex->disconnect();

}

__END__

=head1 NAME

generate_sample_data - extract from the database all the necessary data to have a working test sample for autosaint

=head1 SYNOPSIS

  generate_sample_data.pl [options]

  Options:
  --database  (-db)      Database name to access    (default=idcdev.ctbto.org)
  --user      (-u)       Database user              (default=centre)
  --password  (-p)       Database password          (default= password of the centre user)
  --directory (-dir)     Home Directory where the data for comparison will be stored 

  Help Options:
   --help     Show this scripts help information.
   --manual   Read this scripts manual.
   --version  Show the version number and exit.

=cut

=head1 EXAMPLES

  The following is an example of this script:

  generate_sample_data.pl --help

=cut


=head1 DESCRIPTION


  This is a simple demonstration program for Pod::Usage, this text
 will be displayed if the script is invoked with '--manual'.

=cut


=head1 AUTHOR


 Guillaume Aubert
 --
 guillaume.aubert@ctbto.org

 $Id: generate_sample_data.pl,v0.5 2008/02/05 10:00:00 guillaume Exp $

=cut

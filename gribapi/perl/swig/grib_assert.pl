#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use Pod::Usage;
use Griberl::GribAssertor;

#
# Release number.
#
my $RELEASE         = '0.9';

# Default Values
#my $CONF            = './conf/ecmwf_checker.conf';
my $CONF            = undef;

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
                            'configuration|conf=s'     => \$CONF,
                           ) or pod2usage(1);

    pod2usage(1) if $HELP;
    pod2usage(-verbose => 2 ) if $MANUAL;

    if (! defined $CONF)
    {
       print STDERR "Error: need a configuration file\n"; 
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

#print "ARGV= @ARGV\n";

#my @fileList = ("/tmp/gribs/ecmwf/EN08030803");
#my $conf = $ARGV[0];
#print "Conf= $conf\n";
#shift(@ARGV);

my @fileList = @ARGV;

#my $gA = new GribAssertor($CONF,\@fileList);
my $gA = new GribAssertor($CONF,\@fileList);

$gA->check();

}

__END__

=head1 NAME

grib_assert.pl - check that the grib files are well formed according to a configuration file

=head1 SYNOPSIS

  grib_assert.pl [options] grib_files

  Mandatory Options:
  --configuration  (-conf)  path to the configuration file used by grib_assert   (no default) 

  Help Options:
  --help     Show this scripts help information.
  --manual   Read this scripts manual.
  --version  Show the version number and exit.

  Examples:
  >./grib_assert.pl -conf ./ecmwf_checker.conf *.grib 

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

#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use Pod::Usage;
use SampleInsertor;

my $HOME='.';

#
# Release number.
#
my $RELEASE         = '0.5';

# Default Values
my $CLEAN           = 1;
my $FORCECLEAN      = 0;
my $LOGDIR          = undef;
my $SAMPLEDIR       = undef;
my $SAMPLEID        = undef;
my $USER            = 'rmsauto';
my $PASS            = 'rmsauto';
my $DB              = '127.0.0.1';

#
#  Parse command line arguments. Overide global values 
#
parseCommandLineArguments();

#
#  Do more stuff ..
#
execute();


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
                            "help"                   => \$HELP,
                            "manual"                 => \$MANUAL,
                            "version"                => \$VERSION,
                            'directory|dir=s'        => \$SAMPLEDIR,
                            'sampleID|sid=s'         => \$SAMPLEID,
                            'user|u=s'               => \$USER,
                            'password|p=s'           => \$PASS,
                            'database|db=s'          => \$DB,
                            'logDir|ldir=s'          => \$LOGDIR,
                            'clean!'                 => \$CLEAN,
                            'forceclean'             => \$FORCECLEAN,
                           ) or pod2usage(1);

    pod2usage(1) if $HELP;
    pod2usage(-verbose => 2 ) if $MANUAL;

    if (! defined $SAMPLEDIR)
    {
       print STDERR "Error: need a sample directory (ex: /tmp/autoSaintTests)\n"; 
       pod2usage(1);
    }

    if (! defined $SAMPLEID)
    {
       print STDERR "Error: need a sample_id (ex: )\n"; 
       pod2usage(1);
    }

    if (! defined $LOGDIR)
    {
       $LOGDIR = $SAMPLEDIR;
    }

    printf STDOUT "Logging directory %s\n",$LOGDIR;

    if ( $VERSION )
    {
    my $REVISION      = '$Id: main,v0.5 2008/02/05 10:00:00 guillaume Exp $';
    $VERSION = join (' ', (split (' ', $REVISION))[2]);
    $VERSION =~ s/,v\b//;
    $VERSION =~ s/(\S+)$/$1/;

    print "main release $RELEASE - CVS: $VERSION\n";
    exit;
    }
}

=head2 execute

  extract all the necessary data to create a sample environement for autosaint

=cut

sub execute
{

my $obj = SampleInsertor->new($DB,$USER,$PASS,$SAMPLEDIR);

# set attributes
$obj->home($HOME);

$obj->clean_data($CLEAN);

$obj->gentle_clean($FORCECLEAN);

$obj->insert($SAMPLEID);

}

__END__

=head1 NAME

insert_sample_data - insert in the database all the necessary data to have a working test sample for autosaint 

=head1 SYNOPSIS

  insert_sample_data [options]

  Options:
  --sampleID  (-sid)     Id of the sample to insert in the database (no default)
                         ex: -sid 105229
  --directory (-dir)     directory containing the sample data as sql scripts   (no default) 
  --database  (-db)      Database name to access    (default=127.0.0.1)
  --user      (-u)       Database user              (default=rmsauto)
  --password  (-p)       Database password          (default= password of the centre user)
  --logDir    (-ldir)    Directoy where the outputs of each sql scripts are stored (default=sampleDir) 
  --noclean              Do not clean the database
  --forceclean           Clean the database

  Help Options:
   --help     Show this scripts help information.
   --manual   Read this scripts manual.
   --version  Show the version number and exit.

=cut

=head1 EXAMPLES

  The following is an example of this script:

 insert_sample_data.pl --help

=cut


=head1 DESCRIPTION


=cut


=head1 AUTHOR


 Guillaume Aubert
 --
 guillaume.aubert@ctbto.org

 $Id: main,v0.5 2008/02/05 10:00:00 guillaume Exp $

=cut

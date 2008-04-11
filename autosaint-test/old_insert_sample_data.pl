#!/usr/bin/perl -w

use strict;
use strict;
use Getopt::Long;
use Pod::Usage;

my $HOME='.';

#
# Release number.
#
my $RELEASE         = '0.4';

# Default Values
my $CLEAN           = 1;
my $FORCECLEAN      = 0;
my $LOGDIR          = undef;
my $SAMPLEDIR       = undef;
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
                            'sampleDir|sdir=s'       => \$SAMPLEDIR,
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
       print STDERR "Error: need a sample directory (ex: /tmp/autoSaintTests/159698)\n"; 
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

sub _cleanDB
{
    print "try to clean database $DB \n";

    my $script;

    if ($FORCECLEAN)
    {
      $script = "$HOME/sqls/delete_all_tables_nofailures.sql";
    }
    else
    {
      $script = "$HOME/sqls/delete_all_tables.sql";
    }
    
    my $cleancommand = "sqlplus $USER/$PASS\@$DB < $script > $HOME/delete_all_tables.log";
    system($cleancommand);

    if ( $? == -1)
    {
      print "clean command failed: $!\n";
      exit 1;
    }
    elsif ($? > 0)
    {
      printf "\nError: Cannot run script %s. Sql error code %d. See logs in %s\n", $script, $? >> 8,"$HOME/delete_all_tables.log";
      exit 1;
    }
    else
    {
      printf "sql script $script successfully run\n";
    }

    print "database $DB emptied \n";
}


=head2 execute

  extract all the necessary data to create a sample environement for autosaint

=cut

sub execute
{

  # list directory content
  my @not_sorted = <$SAMPLEDIR/*.sql>;

  my @sorted = sort { lc($a) cmp lc($b) } @not_sorted;

  my $arrsize = @sorted;

  if ($arrsize <=0)
  {
    printf "No sql files found into %s\n",$SAMPLEDIR; 
    exit 1;
  }

  print "clean database \n\n";

  _cleanDB() if ($CLEAN);


  #print "sorted array= @sorted\n";

  foreach my $file (@sorted)
  {

    my $commandToRun = "sqlplus $USER/$PASS < $file > $file.log";

    printf "execute sql script $file \n";

    system($commandToRun);

    if ( $? == -1)
    {
      print "command failed: $!\n\n";
      exit 1;
    }
    elsif ($? > 0)
    {
      printf "\nError: Cannot run script %s. Exit with value %d. See logs in %s\n\n", $file, $? >> 8, "$file.log";
      exit 1;
    }
    else
    {
      printf "sql script $file successfully executed\n\n";
    }
  }
}

__END__

=head1 NAME

insert_sample_data - insert in the database all the necessary data to have a working test sample for autosaint 

=head1 SYNOPSIS

  insert_sample_data [options]

  Options:
  --sampleDir (-sdir)    directory containing the sample data as sql scripts   (no default) 
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

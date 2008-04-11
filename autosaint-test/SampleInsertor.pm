package SampleInsertor;

use strict;
use File::Path;
use DBI;
use Data::Dumper;
use Carp;
use Encode;

# Class Members

# Class Methods

# Constructor
sub new 
{
  my ($class,$database_name,$user,$password,$directory) = @_;

  my $self  = {
      database_name  => $database_name,
      user           => $user,
      password       => $password,
      directory      => $directory,
      clean_data     => 1,
      verbose        => 1,
      gentle_clean   => 0,
      home           => '.',
  };

  # Blessing
  return bless ($self,$class);
}



# Accessors
sub database_name 
{
   my ($self,$args) = @_;
   $args ? $self->{database_name} = $args  #modify
         : $self->{database_name};         # access
} 

sub home 
{
   my ($self,$args) = @_;
   $args ? $self->{home} = $args  #modify
         : $self->{home};         # access
} 

sub verbose 
{
   my ($self,$args) = @_;
   (defined $args) ? $self->{verbose} = $args  #modify
         : $self->{verbose};         # access
} 

sub clean_data 
{
   my ($self,$args) = @_;
   (defined $args) ? $self->{clean_data} = $args  #modify
         : $self->{clean_data};         # access
} 

sub gentle_clean 
{
   my ($self,$args) = @_;
   (defined $args) ? $self->{gentle_clean} = $args  #modify
         : $self->{gentle_clean};         # access
} 

sub user 
{
   my ($self,$args) = @_;
   (defined $args) ? $self->{user} = $args  #modify
         : $self->{user};         # access
} 

sub password 
{
   my ($self,$args) = @_;
   (defined $args) ? $self->{password} = $args  #modify
         : $self->{password};         # access
} 

sub directory 
{
   my ($self,$args) = @_;
   (defined $args) ? $self->{directory} = $args  #modify
         : $self->{directory};         # access
} 

sub sample_dir 
{
   my ($self,$args) = @_;
   (defined $args) ? $self->{sample_dir} = $args  #modify
         : $self->{sample_dir};         # access
} 

sub _cleanDB
{
    my ($self,$args) = @_;

    print "\ntry to clean database $self->{database_name} \n";

    my $script;

    if ($self->{gentle_clean})
    {
      $script = "$self->{home}/sqls/delete_all_tables_nofailures.sql";
    }
    else
    {
      $script = "$self->{home}/sqls/delete_all_tables.sql";
    }
    
    my $cleancommand = "sqlplus $self->{user}/$self->{password}\@$self->{database_name} < $script > $self->{home}/delete_all_tables.log";

    system($cleancommand);

    if ( $? == -1)
    {
      print "clean command failed: $!\n";
      exit 1;
    }
    elsif ($? > 0)
    {
      printf "\nError: Cannot run script %s. Sql error code %d. See logs in %s\n", $script, $? >> 8,"$self->{home}/delete_all_tables.log";
      exit 1;
    }
    else
    {
      printf "sql script $script successfully run\n" if ($self->{verbose});
    }

    print "\ndatabase $self->{database_name} emptied \n";
}

sub empty_db
{
  my ($self,@more) = @_;
  
  $self->_cleanDB(); 
}

sub insert
{
  my ($self,$sample_id,@more) = @_;

  die "need to define a directory where to find sample_ids" unless (defined $self->{directory});

  die "need a sample_id" unless (defined $sample_id);

  die "need a user" unless (defined $self->{user});
  die "need a password" unless (defined $self->{password});

  # list directory content
  my $dir = "$self->{directory}/$sample_id";

  my @not_sorted = <$dir/*.sql>;

  my @sorted = sort { lc($a) cmp lc($b) } @not_sorted;

  my $arrsize = @sorted;

  if ($arrsize <=0)
  {
    printf "No sql files found into %s\n",$dir; 
    exit 1;
  }

  print "clean_data $self->{clean_data}\n" if ($self->{verbose});

  $self->_cleanDB() if ($self->{clean_data});

  print "\nStart insertion of data related to sample id $sample_id\n";

  foreach my $file (@sorted)
  {

    my $commandToRun = "sqlplus $self->{user}/$self->{password} < $file > $file.log";

    printf "execute sql script $file \n" if ($self->{verbose});

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
      printf "sql script $file successfully executed\n\n" if ($self->{verbose});
    }
  }

  print "\nInsertion of data related to sample id $sample_id successful\n";

} 


1;
__END__

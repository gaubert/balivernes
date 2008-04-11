package Extractor;

use strict;
use Common::Util;
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
      user => $user,
      password => $password,
      directory => $directory,
      dbh => undef,
      dbi_type => "DBI:Oracle",
      connected => 0,
      overwrite => 1,
      append  => 0,
      cpt => 10000,
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

sub connected 
{
   my ($self,$args) = @_;
   $args ? $self->{connected} = $args  #modify
         : $self->{connected};         # access
} 

sub overwrite 
{
   my ($self,$args) = @_;
   $args ? $self->{overwrite} = $args  #modify
         : $self->{overwrite};         # access
} 

#sub _dbh 
#{
#   my ($self,$args) = @_;
#   $args ? $self->{dbh} = $args  #modify
#         : $self->{dbh};         # access
#} 

sub user 
{
   my ($self,$args) = @_;
   $args ? $self->{user} = $args  #modify
         : $self->{user};         # access
} 

sub password 
{
   my ($self,$args) = @_;
   $args ? $self->{password} = $args  #modify
         : $self->{password};         # access
} 

sub cpt 
{
   my ($self,$args) = @_;
   $args ? $self->{cpt} = $args  #modify
         : $self->{cpt};         # access
} 

sub directory 
{
   my ($self,$args) = @_;
   $args ? $self->{directory} = $args  #modify
         : $self->{directory};         # access
} 

# connect to db
sub connect {
 my ($self,$args) = @_; 

 # return if already connected
 if ($self->connected())
 {
   return;
 }

 my $dbcon = "";
 $dbcon = $dbcon . $self->{dbi_type} . ":" . $self->{database_name};

 $self->{dbh} = DBI->connect($dbcon, $self->{user},$self->{password}) 
                or die "Failed: " . DBI->errstr();

 $self->{connected} = 1;
}

# close connection to DB
sub disconnect {
 my ($self,$args) = @_;

 # disconnect if connected
 if ($self->connected())
 {
    print "disconnect \n";
    $self->{dbh}->disconnect();
 }
}

sub _get_connection_on_db
{
  my ($self,$database_name,$user,$password) = @_;

  my $dbcon = "";
  $dbcon = $dbcon . $self->{dbi_type} . ":" . $database_name;

  my $dbh = DBI->connect($dbcon, $user,$password) or die "Failed: " . DBI->errstr();

  return $dbh;
}

sub _create_file
{
 my ($self,$orig_table,@more) = @_;

 #print "params orig=$orig_table\n";
 die "need an original table name" unless (defined $orig_table);

 my $file_handle    = undef;
 my $run_extraction = 0;

 my $selector = ">";

 # if overwrite anyway open file otherwise if it exists do nothing
 if ($self->{overwrite})
 {
   #open($file_handle,">:utf8","$self->{directory}/$self->{cpt}-insert_$orig_table.sql");
   open($file_handle,"$selector$self->{directory}/$self->{cpt}-insert_$orig_table.sql");

   # put it to true
   $run_extraction = 1;

   $self->{cpt} = $self->{cpt} + 1;
 }
 elsif (! -f "$self->{directory}/$self->{cpt}-insert_$orig_table.sql")
 {
   #open($file_handle,">:utf8","$self->{directory}/$self->{cpt}-insert_$orig_table.sql");
   open($file_handle,"$selector$self->{directory}/$self->{cpt}-insert_$orig_table.sql");

   # put it to true
   $run_extraction = 1; 

   $self->{cpt} = $self->{cpt} + 1;

 }

 # add quit on ERROR
 print $file_handle "WHENEVER SQLERROR EXIT SQL.SQLCODE;\n\n" if (defined $file_handle && ! $self->{append} );

 # change date format
 print $file_handle "alter session set NLS_DATE_FORMAT=\'DD-MON-YYYY HH:MI:SS\';\n\n";

 # return a list containing two values
 return ($run_extraction,$file_handle);
}

# Destructor
sub DESTROY 
{

} 

# Object methods
sub insert_data
{
  my ($self,@more) = @_;
  # get directory content
  
  my @not_sorted;
  my $file_handle = undef;

  my $hash_ref = $self->{dbh}->ora_nls_parameters();
  my $database_charset = $hash_ref->{NLS_CHARACTERSET};
  my $national_charset = $hash_ref->{NLS_NCHAR_CHARACTERSET};

  print "db_charset = $database_charset\n";
  print "national_charset = $national_charset\n";

  # list directory content
  @not_sorted = </tmp/autosaintTests/159698/*.sql>;

  my @sorted = sort { lc($a) cmp lc($b) } @not_sorted;

  print "sorted array= @sorted\n";

  foreach my $file (@sorted) 
  {
    open($file_handle,"$file") || die("Could not open file $self->{directory}/$file");

    binmode( $file_handle, ':utf8' );

    while (defined (my $line = <$file_handle>)) 
    {
       chomp $line;
       
       if (length $line != 0)
       {
         print "Do something with $line \n";

         my $sth = $self->{dbh}->prepare($line);

         $sth->execute();
       } 
       
       my $size = length $line;
       print "$size\n";                # output size of line

       exit 1;
    }

    #print $file_handle "\@$file\n" unless ($file =~ /insert_all.sql/);

    close($file_handle) if (defined $file_handle);
  }
}

# create an insertion script embedding all internal scripts
sub generate_insertion_script
{
  my ($self,@more) = @_;
  # get directory content
  
  my @not_sorted;
  my $file_handle = undef;

  # list directory content
  @not_sorted = </tmp/autosaintTests/159698/*.sql>;

  my @sorted = sort { lc($a) cmp lc($b) } @not_sorted;

  print "sorted array= @sorted\n";

  open($file_handle,">$self->{directory}/insert_all.sql");

  foreach my $file (@sorted) 
  {
    print "\@$file\n" unless ($file =~ /insert_all.sql/);
    print $file_handle "\@$file\n" unless ($file =~ /insert_all.sql/);
  }
  
  close($file_handle) if (defined $file_handle);
}

# extract and apply transformation to the necessary columns contents
# modifier is a hash containing a column name and how to tweak the content
# ex {'DIR' => 's/\/home\/misc\/rmsops/\/home\/aubert/g'}
sub extract
{
  my ($self,$orig_table,$dest_table,$transformations,$request,@params) = @_;

  die "undefined transformation hash" unless defined $transformations;
  die "need an orig_table" unless defined $orig_table;
  die "need an dest_table" unless defined $dest_table;
  die "not connected to the database" unless $self->connected();

  # create dir if necessary
  Util::create_dir($self->{directory});

  # prepare request
  my $sql;

  my $sth =  $self->{dbh}->prepare("alter session set NLS_DATE_FORMAT=\'DD-MON-YYYY HH:MI:SS\'");
  $sth->execute();

  if (defined $request)
  {
     $sql = $request;
  }
  else
  {
     $sql = "SELECT * FROM $orig_table";
  }

  $sth = $self->{dbh}->prepare($sql);

  # retrieve dynamically the column names from the table
  my @fields = @{$sth->{NAME_uc}};

  if (@params > 0)
  {
     #execute the request with params
     $sth->execute(@params); 
  }
  else
  {
     #execute the request
     $sth->execute();
  }

  my $file_handle    = undef;
  my $run_extraction = 0;
  my $data;


  my @splitted = split(/\./,$orig_table);
  my $spsize = @splitted;
  
  # check if there is a table name given
  my $table = undef;
  if ($spsize == 2)
  {
    $table = $splitted[1]; 
  }
  else
  {
    $table = $splitted[0];
  }

  # dumper modifier_hash

  #print "In Extract \n";
  #print Dumper($modifier_hash);
  #print "hash->table = $modifier_hash->{$table}\n";
  #print "EOF Extract \n";

  #fetch row by row
  while( $data = $sth->fetchrow_hashref())
  {
    if ($transformations->{$table})
    {
       while ((my $key, my $value) = each(%{$transformations->{$table}}))
       { 
          #print $key.", ".$value."\n";
          #print "data{key} = $data->{$key}\n";

          if (defined $data->{$key})
          { 
             my $expr = '$data->{$key}'."=~  $value";
             #print "Expr = $expr \n";
             eval $expr;
             printf "After modification $table.$key = %s\n",$data->{$key};
          } 
       }
    }

    # create filehandle if undef 
    if (! defined $file_handle)
    {
       ($run_extraction,$file_handle) = $self->_create_file($orig_table);
    }

   # run extraction if boolean ok => otherwise quit
   last unless ($run_extraction);

   # add comma between each of the field name
   my $fields = join(', ', @fields);
   # quote accordingly with the database rule each of the retrieved value
   my $values = join(', ', map { $self->{dbh}->quote($_) } @$data{@fields});

   #create insert request
   $sql = "INSERT into $dest_table ($fields) values ($values);";
   #if (Encode::is_utf8($sql))
   #{
   #   $sql = decode_utf8($sql);
   #}
   print $file_handle "$sql\n\n";
  }

  if (defined $file_handle)
  {
    # add a commit
    print $file_handle "commit;\n\n";
    close($file_handle);
  }

  $sth->finish();
}

sub revive_ref_data
{
  my ($self,$file) = @_;

  my $fh;

  open($fh,"<$file") or die "Can't open $file: $!";

  my $results;
  {
    no strict 'vars';
    # slurp in the whole file, rather than
    # a line at a time
    local $/; 
    
    # load all the data
    my $data = <$fh>;

    #print "data = $data\n";
  
    $results =  eval $data ;

    print "Dump = ".Dumper($results);

  }
}

sub yamlvive_ref_data
{
  my ($self,$file) = @_;

  my $fh;

  #open($fh,"<$file") or die "Can't open $file: $!";

  use YAML;

  my %h = %{YAML::LoadFile($file)};

  while ( my ($key, $value) = each(%h) ) 
  {
        print "H:$key => $value\n";
  }
  print "H{categories_sample_status}=$h{'categories_sample_status'}\n";

  my %iH = %{$h{'categories_sample_status'}};

  while ( my ($key, $value) = each(%iH) )
  {
        print "iH:$key => $value\n";
  }


}

1;
__END__

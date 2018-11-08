use strict;
use warnings;

if (!$ARGV[0]) {
  print_help();
} 

my $infile = $ARGV[0];

open(IN, "<$infile") || die($!);

my %data;

while (my $line = <IN>) {
  chomp $line;   
  my @aux = split(/\t/, $line);
  my $feat_name = shift @aux;
  my $GOs = pop @aux;
  if ($GOs !~ /GO:/) {
    next;
  }
  if (defined $data{$feat_name}) {
    $data{$feat_name} = $data{$feat_name} = join("|", $data{$feat_name}, $GOs);
  }
  else {
    $data{$feat_name} = $GOs;
  }
}

close IN;

my $GO_count = 0;

foreach my $key (keys %data) {
  my $GOs = remove_redundancy($data{$key});
  my @GOs = split(/,/, $GOs);
  $GO_count = $GO_count + ($#GOs + 1);
#  print "$key\t$GOs\n";
}

#generating a pretty name for printing
my @tmp = "";
@tmp = split(/\//, $infile);
my $last = pop @tmp;
@tmp = "";
@tmp = split(/_/, $last);
my $final_name = join("_", $tmp[0], $tmp[1]);
$final_name =~ s/\./_/;

print ("$final_name\t$GO_count\n");

sub remove_redundancy {
  my $tmp = $_[0];
  my %tmp_data;
  my @aux = split(/\|/, $tmp);
  foreach my $element (@aux) {
    $tmp_data{$element} = 1;
  }
  my @keys = keys %tmp_data;
  my $keys_merged = join(",", @keys);
  return($keys_merged);
}

sub print_help {
  die("Use this program like: perl parse_interproscan_tabular.pl <path to interproscan output file> <column to summarize> <Feature name to be used as header>\n");
}


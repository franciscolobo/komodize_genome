use strict;
use warnings;

my $infile = $ARGV[0];

chomp $infile;

open(IN,"<$infile");

my @queries;

my $i = 0;

while (my $line = <IN>) {
  chomp $line;
  $queries[$i] = $line;
  $i++;
}

foreach my $query (@queries) {
  my $tmp = $query;
  $tmp =~ s/\s+/_/g;
  print "./esearch -db nucleotide -query \"$query\[orgn\] AND biomol_mrna\[PROP\] AND complete CDS\[title\] NOT mitochondrial\[title]\" | ./efetch -format gb > $tmp.gb\n";
  system "./esearch -db nucleotide -query \"$query\[orgn\] AND biomol_mrna\[PROP\] AND complete CDS\[title\] NOT mitochondrial\[title]\" | ./efetch -format gb > $tmp.gb\n";
}


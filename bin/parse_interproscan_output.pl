use strict;
use warnings;

if (!$ARGV[2]) {
  print_help();
} 

#my @path = split(/\//, $ARGV[0]);

#my $file_name = pop @path;

#my @tmp_name = split(/_/, $file_name);

#my $final_name = join("_", $tmp_name[0], $tmp_name[1]);

#$final_name =~ s/\./_/g;

my $infile = $ARGV[0];

my $column_number = $ARGV[1];

my $feature_name = $ARGV[2];

chomp $feature_name;

open(IN, "<$infile") || die($!);

#my $header = <IN>;

#my @col_names = split(/\t/, $header);

print("Feature\t$feature_name\n");

#my %data;

#my $total = 0;

my $i = 0;

while (my $line = <IN>) {
  chomp $line;   
  my @aux = split(/\t/, $line);
  my $actual_feature = $aux[$column_number-1];
  if (defined $actual_feature) {
    print("$i\t$actual_feature\n");
    $i++;
#    if (defined $data{$actual_feature}) {
#      $data{$actual_feature}++;
#      $total++;
#    } else {
#      $data{$actual_feature} = 1;
#      $total++;
#    }
#  print "$actual_feature\n";
  }
}

close IN;

#my $sum = 0;

#foreach my $key (keys %data) {
#  my $ratio = $data{$key} / $total;
#  $sum = $sum + $ratio;
#  print "$key\t$ratio\n";
#}

#print ("$sum\n");

sub print_help {
  die("Use this program like: perl parse_interproscan_tabular.pl <path to interproscan output file> <column to summarize> <Feature name to be used as header>\n");
}


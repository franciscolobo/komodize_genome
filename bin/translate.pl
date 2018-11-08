use strict;
use warnings;
use Bio::SeqIO;

my $infile = $ARGV[0];

chomp $infile;

my $in  = Bio::SeqIO->new(-file => $infile ,
                       -format => 'Fasta');
my $out = Bio::SeqIO->new(-file => ">$infile.aa.fasta" ,
                       -format => 'Fasta');

while ( my $seq = $in->next_seq() ) {
  my $prot_obj = $seq->translate(-codontable_id => 1);
  $out->write_seq($prot_obj);
}

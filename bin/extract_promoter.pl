#!/usr/bin/perl

################################################################################
##                                                                            ##
## Copyright 2018 Universidade Federal de Minas Gerais                        ##
## Author: Francisco Pereira Lobo                                             ##
## this program is free software: you can redistribute it and/or modify       ##
## it under the terms of the GNU General Public License as published by the   ##
## Free Software Foundation, version 3 of the License.                        ##
##                                                                            ##
## extract_promoter.pl is distributed in the hope that it will be useful,     ##
## but WITHOUT ANY WARRANTY; without even the implied warranty of             ##
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                       ##
## See the GNU General Public License for more details.                       ##
##                                                                            ##
## You should have received a copy of the GNU General Public License          ##
## along with rscu.pl (file: COPYING).                                        ##
##                                                                            ##
## If not, see <http://www.gnu.org/licenses/>.                                ##
##                                                                            ##
################################################################################


# Takes as input a genbank file and calculates RSCU for all genes
# after filtering putative error sources. 


use strict;
use warnings;
use Bio::SeqIO;
use Bio::DB::Fasta;

my $dir_path = shift; #directory containing gff files

my $output_dir = shift; #output directory

my $tmp_dir = $output_dir."/tmp/";

if (-d $tmp_dir) {
} else { 
  system ("mkdir $tmp_dir");# || die();
}

my $UTR_length = shift; #length to be considered as 5' UTR (this region will not be considered as a promoter)

my $promoter_length = shift; #length of sequence to be retrieve as a promoter

my $flags = shift;

if (! defined $UTR_length) {
  $UTR_length = 200;
}

if (! defined $flags) {
  $flags = "all";
}

opendir(DIR,$dir_path);

my @files = readdir(DIR);

foreach my $file (@files) {
  if (($file eq ".") || ($file eq "..")) {
    next;
  }
  if ($file !~ /.gbff$/) {
    next;
  }
  print ("Building fasta index for fast access to $file sequence (this may take a while...)\n");
  
  my $path_2_file = "$dir_path$file";

  print("Extracting fasta files from genbank $file");
  
  my %fasta_file_data; #stores sequence IDs

  my $seq_in = Bio::SeqIO->new( -file   => "$path_2_file",
                              -format => "genbank",
                              );
  my $outfile_path = $tmp_dir.$file.".fasta";
  
  if (-e $outfile_path) {
    print("Here!\n");
  } else {
    my $seq_out = Bio::SeqIO->new( -file   => ">$outfile_path",
                                 -format => "fasta",
                                 );

  # write each entry in the input file to the output file
    while (my $inseq = $seq_in->next_seq) {
      my $id = $inseq->display_id();
      print ("$id\n");
      $fasta_file_data{$id} = 1;
      $seq_out->write_seq($inseq);
    }
  }
  print("Done\n");

  my $db       = Bio::DB::Fasta->new($outfile_path);
  my @ids      = $db->get_all_primary_ids;

  print ("IDS:\t@ids\n");

  my $in = new Bio::SeqIO(-format => 'genbank',
                           -file => $path_2_file);
  my $seq;

  my $name = $file;
  my $i = 1;

  $outfile_path = "$output_dir/$file\_nt_promoter.fasta";
  next if (-e $outfile_path);
  while($seq = $in->next_seq()){
    my $id = $seq->display_id();
    my $seq;
    $seq = $db->get_Seq_by_id($id);
#    my $sequence = $seq->seq();
    my $start;
    my $end;
    my $organism;
    my $source;
    my $cds;
    my $flag = 0;
    for my $feat_object ($seq->get_all_SeqFeatures) {
#      print "primary tag: ", $feat_object->primary_tag, "\n";
      for my $tag ($feat_object->get_all_tags) {
        for my $value ($feat_object->get_tag_values($tag)) {
          if ($tag eq "pseudo") { #remove pseudogenes
            $flag = 1;
            next;
          }
        }
      if ($feat_object->primary_tag eq "source") {
        $source = $file;
	$source =~s/\.gb.*$//g;
        $source =~ s/\s+/_/g;
        for my $tag ($feat_object->get_all_tags) {
          if ($tag eq "organism") {
            for my $value ($feat_object->get_tag_values($tag)) {
              $organism = $value;
            }
          }
        }
      $organism =~ s/\s+/_/g;
      $organism =~ s/\-/_/g;
      }
    }
      if ($feat_object->primary_tag eq "CDS") {
        $start = $feat_object->start;
        $end = $feat_object->end;
               
        my $prom_start;
        my $prom_end;
        my $strand = $feat_object->strand;
        if ($strand == 1) {
          $prom_start = $start - ($UTR_length + $promoter_length);
          $prom_end = $prom_start + $promoter_length;
        } elsif ($strand == -1) {
          $prom_start = $end + ($UTR_length + $promoter_length);
          $prom_end = $prom_start - $promoter_length;
        } else {
          next;
        }
        for my $tag ($feat_object->get_all_tags) {
          if ($tag eq "protein_id") {
            for my $value ($feat_object->get_tag_values($tag)) {
              print ("\tprotein_id:$value");
              $i++;
            }
          }
#          if ($tag eq "organism") {
#            for my $value ($feat_object->get_tag_values($tag)) {
#              print ("\torganism:$value");
#            }
#          }
          if ($tag eq "locus_tag") {
            for my $value ($feat_object->get_tag_values($tag)) {
              print ("\tlocus_tag:$value");
            }
          }
          if ($tag eq "gene") {
            for my $value ($feat_object->get_tag_values($tag)) {
              print ("\tgene:$value");
            }
          }
        my $promoter_seq;
        $promoter_seq = $seq->subseq($prom_start => $prom_end);
        print ("\t$source\_$i\tCDS_start:$start\tCDS_end:$end\tprom_start:$prom_start\tprom_end:$prom_end\tstrand:$strand\tseq:$promoter_seq\n");
        }
#        my $promoter_seq = $
#        print OUT ("\n$cds\n");
      }
    }
    $i++;
  }
}

sub check_cds {
  my $tmp_seq = $_[0];
  my $start_codon = substr($tmp_seq, 0, 3);
  my $stop_codon = substr($tmp_seq, -3);
  if ($start_codon !~ /ATG|GTG/i) {
    print "Not valid start codon\t$tmp_seq\n";
    return (1);
  }
  if ($stop_codon !~ /TAA|TAG|TGA/i) {
    print "Not valid stop codon\t$tmp_seq\n";
    return (1);
  }
  if (length($tmp_seq) % 3 == 0) {
  } else {
    print "length not multiple of three\t$tmp_seq\n";
    return (1);
  }
  if ($tmp_seq =~ /[^ACGT]/i) {
    print "non-standard nucleotides\t$tmp_seq\n";
    return (1);
  }
#  if (length($tmp_seq) < $len_cutoff) {
#    print "length smaller than cutoff\n";
#    return (1);
#  }
  return (0);
}


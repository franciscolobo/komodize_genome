use strict;
use warnings;
use Getopt::Long;

my $infile   = "";
my $verbose;
my $log;
my $root_outdir;

#Getting options from command line

GetOptions ("in|infile=s" => \$infile, # file containing species names or taxonomy IDs 
            "log=s" => \$log, #log file
            "verbose"  => \$verbose   # 
            "outdir|out=s" => \$root_outdir)
or die("Error in command line arguments\n");



##tasks to implement

#open LOG outfile

open(LOG, ">$log") ||
  die();




#create directory structure 

create_directory_structure($root_outdir);




#open and parse infile

my @species = parse_infile($infile);



#Checking if species names or taxonomy IDs are valid

my @failed_names; #species names that do not correspond to anything

@failed_names = check_names(\@species);

if (@failed_names) {
  print LOG ("ISSUE\tSPECIES_NAMES_WRONG:@failed_names\n";
  if ($verbose) {
  
  }
}




#remove @failed_names from @species

filter_species(\@species, \@failed_names);





# Download genome data from NCBI if not already downloaded

print("Downloading genomes\n");

foreach my $specie (@species) {
  my @downloaded_genomes = get_downloaded_genomes($root_dir);
  foreach my $genome (@downloaded_genomes) {
    if ($genome eq $specie) {
      print ("$specie was downloaded already!\n";
      next;
    }
  }
  my $log = get_genome($species, $root_outdir);
  if ($verbose) {
    print "  -> Downloading genome $specie\n";
  }
  if ($log) {
    print LOG("$log\n");
  }
}



# Extract ORFs from genomes

foreach my $specie (@species) {
  my $log = get_ORF($species, $root_outdir);
  if ($verbose) {
    print "  -> Extracting ORF from genome $specie\n";
  }
  if ($log) {
    print LOG("$log\n");
  }
}


#get longest ORF for each locus to summarize per locus

foreach my $specie (@species) {
  my $log = get_longest_ORF($species, $root_outdir);
  if ($verbose) {
    print "  -> Summarizing genome $specie per locus\n";
  }
  if ($log) {
    print LOG("$log\n");
  }
}


#translating

foreach my $specie (@species) {
  my $log = translate($species, $root_outdir);
  if ($verbose) {
    print "  -> Translating ORFs for genome $specie\n";
  }
  if ($log) {
    print LOG("$log\n");
  }
}




#checking for BUSCO completeness

foreach my $specie (@species) {
  my $log = check_completeness($species, $root_outdir);
  if ($verbose) {
    print "  -> Checking genome $specie for completeness\n";
  }
  if ($log) {
    print LOG("$log\n");
  }
}



#annotating genomes using InterproScan

foreach my $specie (@species) {
  my $log = annotate_genome($species, $root_outdir);
  if ($verbose) {
    print "  -> Annotating genome $specie\n";
  }
  if ($log) {
    print LOG("$log\n");
  }
}



#creating KOMODO2-compatible output files
#

foreach my $specie (@species) {
  my $log = create_KOMODO2_files($species, $root_outdir);
  if ($verbose) {
    print "  -> Annotating genome $specie\n";
  }
  if ($log) {
    print LOG("$log\n");
  }
}


#extracting promoters

foreach my $specie (@species) {
  my $log = extract_promoter($species, $root_outdir);
  if ($verbose) {
    print "  -> Downloading genome $specie\n";
  }
  if ($log) {
    print LOG("$log\n");
  }
}




#annotating promoters using MEME and JASPAR

foreach my $specie (@species) {
  my $log = annotate_promoter($species, $root_outdir);
  if ($verbose) {
    print "  -> Downloading genome $specie\n";
  }
  if ($log) {
    print LOG("$log\n");
  }
}



#subroutines


sub create_directory_structure {

}

sub parse_infile {

}

sub check_names {

}

sub filter_species {

}

sub get_genome {

}





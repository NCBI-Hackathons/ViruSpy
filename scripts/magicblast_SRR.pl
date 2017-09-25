#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use File::Basename; # core

my ($srr, $blastdb) = ("", "");
my $threads = 2;
GetOptions ("srr|s=s"  => \$srr,
            "blastdb|b=s" => \$blastdb,
            "threads|t=i" => \$threads,
            );

my $usage = <<USAGE;
$0 [-t THREADS] -s SRR -b BLASTDB

      REQUIRED:
      -s|srr        SRR accession number (can be DRR or ERR)
      -b|blastdb    Blast database name of reference sequences. Can include degenerate nucleotide sequences

      OPTIONAL:
      -t|threads    Number of magicblast threads (2)

DESCRIPTION:
When you create Blast database of your sequences, make sure to use the '-parse_seqids' option to preserve the sequence identifiers (see 'makeblastdb -help')

REQUIREMENTS:
magicblast - NCBI
makeblastdb - NCBI
samtools

USAGE

die $usage if (!$srr || !$blastdb);

my $magicblast = "magicblast";
system ("which $magicblast > /dev/null");
if ($? > 0) {
  print "$magicblast not found...please install magicblast\n\n";
  exit;
}

my $makeblastdb = "makeblastdb";
system ("which $makeblastdb > /dev/null");
if ($? > 0) {
  print "$makeblastdb not found...please install magicblast\n\n";
  exit;
}

system ("which samtools > /dev/null");
if ($? > 0) {
  print "samtools not found...please install samtools\n\n";
  exit;
}

#my $filename = basename($blastdb);
my $bamfile = "$srr.$blastdb.bam";
my $command = "$magicblast -db $blastdb -sra $srr -num_threads $threads | samtools view -bS - | samtools sort -o $bamfile";

print "Running command: $command\n";
`time $command`;

exit 0;

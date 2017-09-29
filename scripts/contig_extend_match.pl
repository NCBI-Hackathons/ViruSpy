#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use Bio::SeqIO;

# To test this Script
# contig_extend_match.pl -q contigs1.fa -c contigs.fa  -> will get one contig (contig1_extended) in the extended.fa file
# contig_extend_match.pl -q contigs1.fa -c contigs.noextend.fa  -> extended.fa is empty

my $query;
my $contigs;
my $dbname = "tempdb";
my $extendedseqfile = "extended.fa";
my $help = 0;
my $evalue = 0;
GetOptions ("q|query=s" => \$query,
            "c|contigs=s" => \$contigs,
            "d|dbname=s" => \$dbname,
            "h|help" => \$help,
            "e|evalue" => \$evalue,
            "x|extendedfile=s" => \$extendedseqfile,
            );

if ($help) {
  my $usage = <<USAGE;
$0 [-e | -x | -h | -d ] -q QUERY -c CONTIGS

      REQUIRED:
      -q|query         Fasta file containing one sequence (your query sequence)
      -c|contigs       Fasta file containing one or more sequences that will be BLASTed against

      OPTIONAL:
      -d|dbname        BLAST database name ("tempdb")
      -x|extendedfile  Extended sequence file ("extended.fa")
      -e|evalue        Evalue cutoff for BLASTN match (0)
      -h               Help

      DESCRIPTION:
      Script writes one file called 'extended.fa' that is either empty or contains
      one fasta sequence. If empty, the script could not find an extended sequence
      in the contigs file. If it contains one sequence, that is the extended
      sequence found in the set of contigs.

      REQUIREMENTS:
      BioPerl

      Memory
      1) Query sequence and each contig are stored in memory as a Bio::Seq object.
      2) The output of 'blastn' is stored in memory as an array of rows.

USAGE
  print $usage;
  exit;
}

die "Please specify query file with one sequence (-q|--query)\n" if (!$query || ! -e $query);
die "Please specify contig fasta file (-c|--contigs)\n" if (!$contigs);

# Read query sequence. If there are more in the file, they are ignored.
my $qin = Bio::SeqIO->new(-file => $query);
my $queryseq;
while ($queryseq = $qin->next_seq) {
  last;
}

# Read contigs into memory
my $in = Bio::SeqIO->new(-file => $contigs);
my %seqs;
while (my $seqobj = $in->next_seq) {
  $seqs{$seqobj->primary_id} = $seqobj;
}

# Make contig blast database
print "Making contig blast database $dbname\n";
`makeblastdb -dbtype nucl -in $contigs -out $dbname`;

# BLASTN query to the contigs
print "BLASTN query to the contigs\n";
my @blastout = `blastn -query $query -db $dbname -outfmt '6 std'`;

my $found = 0;
foreach (@blastout) {
  my @fields = split (/\t/, $_);

  next unless ($queryseq->primary_id eq $fields[0]);  # sanity check in case user supplied more than one query sequence

  if ($fields[10] <= $evalue) {
    # evalue passed now check on subject length
    if ($queryseq->length < $seqs{$fields[1]}->length) {
      # found extended sequence; now output the extended sequence
      my $extend_out = Bio::SeqIO->new(-file => ">" . $extendedseqfile, -format => "fasta");
      $extend_out->write_seq($seqs{$fields[1]});
      $found = 1;
      last;
    }
  }
}

if (!$found) {
  open (my $eout, ">", $extendedseqfile) or die("Can't write to $extendedseqfile: $!\n");
  print $eout "";
  close ($eout)
}

# Delete BLAST DB files
#print "blast db files:\n";
foreach my $file (glob "$dbname.*") {
#  print $file, $/;
  unlink $file;
}



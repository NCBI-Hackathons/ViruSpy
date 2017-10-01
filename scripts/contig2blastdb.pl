#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use Bio::SeqIO;

# Testing
# cd t/
# contig2blastdb.pl -f contigs2.fa -d myblastdb
#	creates 'temp.fa' (3 seqs) and a blast db (myblastdb) of those sequences (only 1 sequence from contig2 since contig2 is only 210bp long)
# contig2blastdb.pl -f contigs2.fa -d blastdb.c2 -l 50
#	creates 'temp.fa' (4 seqs, 50bp each) and a blast db (myblastdb) of those sequences

my $fasta;
my $dbname;
my $length = 500;
my $tempfasta = "temp.fa";
my $help = 0;
GetOptions ("f|fasta=s" => \$fasta,
            "d|dbname=s" => \$dbname,
            "l|length=i" => \$length,
            "t|tempfasta=s" => \$tempfasta,
            "h|help" => \$help,
            );


if ($help) {
  my $usage = <<USAGE;
$0 [-h | -l | -t ] -f FASTA -d DBNAME 

      REQUIRED:
      -f|fasta        Fasta file
      -d|dbname       BLAST database name
      
      OPTIONAL:
      -l|length       Length of sequences to extract from left and right ends (500)
      -t|tempfasta    Name of temporary fasta file containing the extracted sequences (temp.fa)
      -h              Help

      DESCRIPTION:

      REQUIREMENTS:
      BioPerl

USAGE
  print $usage;
  exit;
}

die "Please specify fasta file (-f|--fasta)\n" if (!$fasta || ! -e $fasta);
die "Please specify blast database name (-d|--dbname)\n" if (!$dbname);

my $in = Bio::SeqIO->new (-file => $fasta);
my $out = Bio::SeqIO->new (-file => ">$tempfasta", -format => 'fasta');

while (my $seq = $in->next_seq) {
#  print $/;
  my $local_len = $length;
  my $slen = $seq->length;
#  print "Sequence: ", $seq->primary_id, $/;

  # LEFT sequence
#  print " left\n";
  my $next = 0;
  if ($local_len > $slen) {
    $local_len = $slen;
    $next = 1;
  }
  my $left = $seq->subseq(1, $local_len);
#  print $left, $/; 
  output_seq ($seq->primary_id . "_left", $left, $out);
  
  
  next if ($next);  # don't get the Right hand sequence if length is longer than subject length

  # RIGHT sequence
  my $right = $seq->subseq($slen - $local_len + 1, $slen);
  output_seq($seq->primary_id . "_right", $right, $out);

#  print ">", $seq->primary_id, $/, $seq->seq, $/;
}


print "Making blast database $dbname\n";
`makeblastdb -dbtype nucl -in $tempfasta -out $dbname`;

sub output_seq {
  my ($id, $sequence, $out) = @_;
  
  my $seqobj = Bio::Seq->new(-display_id => $id,
                          -seq => $sequence);                          
  $out->write_seq($seqobj);
}

 
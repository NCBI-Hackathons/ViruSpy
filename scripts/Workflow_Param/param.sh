#!/bin/bash
show_help() {
cat << EOF
Usage: ${0##*/} [-s <SRR ID>] [-d <Path to BLAST Database>] [-c <Custom Parameters>] [-h <help>]…
Do stuff with FILE and write the result to standard output. With no FILE or when FILE is -, read standard input.
	-h          display this help and exit
	-c 	    Custom Parameters for Assembly, filtering, and BLASTing
	-s 	    The ID of an SRR read number is needed to perform BUD
	-d          Path to Viral RefSeq Database needed to pull viral contigs

EOF
}

while getopts “:s:d:” o; do
    case "${o}" in
        s)
            s=${OPTARG}
            ;;
        d)
            d=${OPTARG}
            ;;
        *)
            show_help >&2;
	    exit 1
            ;;
    esac
done

shift "$((OPTIND-1))"

echo “Pulling Viral Reads from Contigs”

magicblast -db $d -sra $s -num_threads 2 | samtools view -bS - | samtools sort -o $s.bam

samtools view $s.bam | awk '{OFS="\t"; print ">"$1"\n"$10}' > $s.fasta

echo “Assembling Reads”

megahit -r $s.fasta -o $s

rm $s.fasta

mv $s/final.contigs.fa zero_$s.fa

rm -r $s

## For Loop Here (i = 1-5)
echo "Trim Ends and Make Database"

./contig2blastdb.pl -f zero_$s.fa -d ends

echo "Second Magic BLAST"

magicblast -db ends -sra $s -num_threads 2 | samtools view -bS - | samtools sort -o $s.bam

samtools view $s.bam | awk '{OFS="\t"; print ">"$1"\n"$10}' > $s.fa 

rm $s.bam

echo "Combine fa files"


## Change the Combination (Remove Contigs from Other Assemblies)
cat *.fa > $s_combined_ends.fasta

echo "Second Megahit Run"

megahit -r $s_combined_ends.fasta -o $s

mv $s/final.contigs.fa one_$s.fa

rm -r $s

mkdir extended_contigs

cd extended_contigs/

echo "Split fasta files"

awk '/^>/ {OUT=substr($0,2) ".fa"}; {print >> OUT; close(OUT)}' ../one_$s.fa

rename 's/\s.*$//' *.fasta

echo "Perform Extend Match"

for f in *
do ../contig_extend_match.pl -q $f -c ../zero_SRR1553459.fa -x ../extended_$f.fasta
done
 
cd ..

mkdir fasta_ext

mv extended_*.fasta fasta_ext/

# End of File

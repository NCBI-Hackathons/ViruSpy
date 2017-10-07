#!/bin/bash
set -euo pipefail  # bash strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
IFS=$'\n\t'

#Magic-BLAST

#module load blast+/2.6.0
#module load samtools/1.5-gcc5.2.0
#module load magic-blast

srr=""
query=""
fasta=""
blastDB=""
out_file=""
while getopts f:b:s:q:o:p: option
do
case "${option}"
	in
	f) fasta=${OPTARG};;
	b) blastDB=${OPTARG};;
	s) srr=${OPTARG};;
	q) query=${OPTARG};;
	o) out_file=${OPTARG};;
	p) paired=$true;;
esac
done

viralDB=./viral.db

if [[ ! -z $fasta && ! -z $blastDB ]]; then
	echo -e "\n$0: BLAST database (-b) and fasta file (-f) options are incompatible with each other.\n"; exit
elif [[ ( ! -z $query && ! -z $srr ) || ( -z $query && -z $srr ) ]]; then
	echo -e "\n$0: please provide either an SRR (-s) or query sequence file (-q).\n"; exit
elif ! [[ -z $fasta ]]; then
	echo -e "\n$0: converting '$fasta' to BlastDB..."
	makeblastdb -dbtype nucl -in $fasta -parse_seqids -out $viralDB
elif ! [[ -z $blastDB ]]; then
	echo -e "\n$0: using '$blastDB' as BlastDB.\n"
	viralDB=$blastDB
else
	echo -e "\n$0: using Viral RefSeq genomic sequences from NCBI as default viral database"
	virussequences=viral.all.1.genomic.fna
	wget.refseq.sh $virussequences
	makeblastdb -dbtype nucl -in $virussequences -parse_seqids -out viral.db
fi

INPUT=""
echo -en "\n$0: running Magic-BLAST on "
if [[ ! -z $srr ]]; then
	echo $srr
elif [[ ! -z $query ]]; then
	echo $query
fi
echo $INPUT

if [[ -z $out_file ]]; then
	out_file="./putative_viral_reads.fastq"
fi
echo -e "$0: saving to '$out_file'\n"

#srr=SRR1161435 west nile viurs
#srr=SRR5675673 #amazon river metagenomics

num_threads=2
out=temp_out
out_format=sam
word_size=20
percent_id_cuttoff=60

##This is for paired end reads
# added '-no_unaligned' since new version of MB 1.3 outputs all reads even if unaligned
if [[ ! -z $srr ]]; then
	magicblast 	-db $viralDB \
			-sra $srr \
			-paired \
			-no_unaligned \
			-num_threads $num_threads \
			-out $out.sam \
			-outfmt $out_format \
			-word_size $word_size \
			-perc_identity $percent_id_cuttoff
else
	magicblast 	-db $viralDB \
			-query $query \
			-paired \
			-no_unaligned \
			-num_threads $num_threads \
			-out $out.sam \
			-outfmt $out_format \
			-word_size $word_size \
			-perc_identity $percent_id_cuttoff
fi

#Samtools
#covert back to fasta format

echo -n "Converting putative viral reads back to FASTQ format..."

samtools view -bS $out.sam > $out.bam
# -v 40 is for character 'I' in the quality string
samtools fastq $out.bam -v 40 > $out_file

rm ./$out.*

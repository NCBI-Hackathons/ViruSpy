#!/bin/bash

module load blast+/2.6.0

while getopts f:o:c: option
do
case "${option}"
	in
	f) fasta=${OPTARG};;
	o) out_file=${OPTARG};;
	c) cdd_prefix=${OPTARG};;
esac
done
out_file=$(readlink -e $out_file)
fasta=$(readlink -e $fasta)
echo -e "Raw fasta:\t$fasta"
echo -e "\n\tRunning RpstBlast"
echo -e "\tContig. Fasta:\t$fasta"
echo -e "\tCdd Prefix:\t$cdd_prefix"
echo -e "\n"

CD=$(pwd)
cd $out_file
rpstblastn 	-db $cdd_prefix \
		-query $fasta \
		-out rpst_out \
		-outfmt "7 qseqid qlen sseqid slen sscinames evalue bitscore score length pident nident mismatch positive gapopen gaps ppos qframe sframe sstrand qcovs qcovhsp qstart qend sstart send qseq sseq"
cd $CD

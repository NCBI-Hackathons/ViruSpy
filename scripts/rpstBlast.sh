#!/bin/bash

module load blast+/2.6.0

while getopts f:o: option
do
case "${option}"
	in
	f) fasta=${OPTARG};;
	o) out_file=${OPTARG};;
esac
done

format_headers="7 qseqid qlen sseqid slen sscinames evalue bitscore score length pident nident mismatch positive gapopen gaps ppos qframe sframe sstrand qcovs qcovhsp qstart qend sstart send qseq sseq"

echo $fasta
echo $out_file
echo $format_headers

exit

CD=$(pwd)
cd $out_file
rpstblastn 	-db Cdd \
		-query $fasta \
		-out $out_file \
		-outfmt $format_headers
cd $CD

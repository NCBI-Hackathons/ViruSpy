#!/bin/bash

#Magic-BLAST

module load blast+/2.6.0
module load samtools/1.5-gcc5.2.0
module load magic-blast

while getopts f:b:s:o:p: option
do
case "${option}"
	in
	f) fasta=${OPTARG};;
	b) blastDB=${OPTARG};;
	s) srr=${OPTARG};;
	o) out_file=${OPTARG};;
	p) paired=$true;;
esac
done

viralDB=./viral.db

if ! [[ -z $fasta ]] && ! [[ -z $blastDB ]]; then
	echo -e "\nMagicBlast: Script can only accept one ViralDB option (fasta or blastDB).\n"; exit
elif ! [[ -z $fasta ]]; then
	echo -e "\nConverting '$fasta' to BlastDB..."
	makeblastdb -dbtype nucl -in $fasta -out $viralDB
elif ! [[ -z $blastDB ]]; then
	echo -e "\nUsing '$blastDB' as BlastDB.\n"
	viralDB=$blastDB
else
	echo -e "\nUsing default '$viralDB' viral database..."
	makeblastdb -dbtype nucl -in viral.all.1.genomic.fna -out viral.db
fi

if [[ -z $srr ]]; then
	echo -e "\nMagic Blast: No SRR value provided; exiting."; exit
else
	echo -e "\nRunning MAGICBLAST on $srr,"
	echo -e "saving to '$out_file'\n"
fi

if [[ -z $out_file ]]; then
	out_file="./putative_viral_reads.fastq"
	echo -e "\nMagicBlast: No output file provided, saving reads to '$out_file.fastq.'\n"
fi

#srr=SRR1161435 west nile viurs
#srr=SRR5675673 #amazon river metagenomics

num_threads=2
#out_file=putative_viral_reads.sam
out_format=sam
word_size=20
percent_id_cuttoff=60

##This is for paired end reads

magicblast 	-db $viralDB \
		-sra $srr \
		-paired \
		-num_threads $num_threads \
		-out temp_out.sam \
		-outfmt $out_format \
		-word_size $word_size \
		-perc_identity $percent_id_cuttoff

#Samtools
#covert back to fasta format

echo -e "Converting putative viral reads back to FASTQ format...\n"

samtools view -bS temp_out.sam > temp_out.bam
# -v 40 is for character 'I' in the quality string
samtools fastq temp_out.bam -v 40 > $out_file

#rm ./temp_out.*

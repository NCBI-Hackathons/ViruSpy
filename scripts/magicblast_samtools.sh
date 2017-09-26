#!/bin/bash

#Magic-BLAST

echo "Running MAGICBLAST"

makeblastdb -dbtype nucl -in viral.all.1.genomic.fna -out viral.db


blastdb=viral.db
#srr=SRR1161435 west nile viurs
#srr=SRR5675673 #amazon river metagenomics


num_threads=2
out_file=putative_viral_reads.sam
out_format=sam
word_size=20
percent_id_cuttoff=60

##This is for paired end reads
echo "Running MAGICBLAST"

magicblast -db $blastdb -sra $srr -paired -num_threads $num_threads -out $out_file -outfmt $out_format -word_size $word_size -perc_identity $percent_id_cuttoff


#Samtools
#covert back to fasta format

echo "Converting putative viral reads back to FASTQ format"

samtools view -bS putative_viral_reads.sam > putative_viral_reads.bam


samtools fastq putative_viral_reads.bam > putative_viral_reads.fastq

rm putative_viral_reads.sam
rm putative_viral_reads.bam
#! /usr/bin/bash

## Gets RefSeq viral sequences from NCBI
## Requires output directory as argument
##
## Output: a combined file containing all Refseq viral genomes
## named viral.all.1.genomic.fna placed in output directory.
##
## Usage: bash get_refseq_viral_seqs.sh OUTPUT_DIR

output_dir=$1

mkdir $output_dir
cd $output_dir
wget ftp://ftp.ncbi.nlm.nih.gov/refseq/release/viral/viral.1.1.genomic.fna.gz
wget ftp://ftp.ncbi.nlm.nih.gov/refseq/release/viral/viral.2.1.genomic.fna.gz
gunzip viral.1.1.genomic.fna.gz
gunzip viral.2.1.genomic.fna.gz
cat viral.1.1.genomic.fna viral.2.1.genomic.fna > viral.all.1.genomic.fna
rm viral.1.1.genomic.fna
rm viral.2.1.genomic.fna

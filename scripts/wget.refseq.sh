#!/bin/bash

echo "Generating Viral RefSeq Database for MAGICBLAST"

output_dir=test
mkdir $output_dir

cd $output_dir
wget ftp://ftp.ncbi.nlm.nih.gov/refseq/release/viral/viral.1.1.genomic.fna.gz
wget ftp://ftp.ncbi.nlm.nih.gov/refseq/release/viral/viral.2.1.genomic.fna.gz
gunzip viral.1.1.genomic.fna.gz
gunzip viral.2.1.genomic.fna.gz
cat viral.1.1.genomic.fna viral.2.1.genomic.fna > viral.all.1.genomic.fna
rm viral.1.1.genomic.fna
rm viral.2.1.genomic.fna


#!/bin/bash
set -euo pipefail  # bash strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
IFS=$'\n\t'

outputfile=$1

echo "Downloading Viral RefSeq genomic sequences from NCBI"
wget -nv ftp://ftp.ncbi.nlm.nih.gov/refseq/release/viral/viral.1.1.genomic.fna.gz
wget -nv ftp://ftp.ncbi.nlm.nih.gov/refseq/release/viral/viral.2.1.genomic.fna.gz
gunzip viral.1.1.genomic.fna.gz
gunzip viral.2.1.genomic.fna.gz
cat viral.1.1.genomic.fna viral.2.1.genomic.fna > $outputfile
rm viral.1.1.genomic.fna
rm viral.2.1.genomic.fna


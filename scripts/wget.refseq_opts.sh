#!/bin/bash
#Download all files supplied to a folder in the current directory called "data_viralDB," cat and gunzip
#all of them into one fasta (.fna), then delete all .gz files in the new folder.

echo "Generating Viral RefSeq Database for MAGICBLAST"

output_dir="./data_viralDB"
mkdir $output_dir
CD=$(pwd)
cd $output_dir

for file in "$@"
do
	echo "\tDownloading $file..."
	wget $file 	
done
cat ./*.gz | gunzip - > ../viralDB.fna
cd $CD
rm -r $output_dir


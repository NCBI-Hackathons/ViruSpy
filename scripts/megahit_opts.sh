#! /bin/bash

#module load megahit
#module load prinseq

while getopts i:o:d: option
do
case "${option}"
	in
	i) input_file=${OPTARG};;
	o) output_file=${OPTARG};;
	d) dir_name=${OPTARG};;
esac
done

if [[ -z $input_file ]]; then
	echo -e "\nMegahit: No input file specified.\n"; exit
elif [[ -z $output_file ]]; then
	echo -e "\nMegahit: No output file specified.\n"; exit
elif [[ -z $dir_name ]]; then
	echo -e "\nMegahit: No megahit directory specified.\n", exit
fi

megahit -r $input_file --out-prefix $output_file --out-dir $dir_name

#Run PrinSeq
echo $dir_name/$output_file"_prinseq.txt"
prinseq-lite.pl -fasta $dir_name/$output_file.contigs.fa -stats_all > $dir_name/$output_file"_PrinSeq.txt"

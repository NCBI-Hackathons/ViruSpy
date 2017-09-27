#!/bin/bash

#This SRR is for an Ebola sample (so should be all virus I think)
#Paired end 
#Illumina HiSeq

paired=$false

while [[ ! $# -eq 0 ]]
do
case "$1" in
	--fasta | -f)
		fasta="$2"
		;;
	--blastDB | -b)
		blastDB="$2"
		;;
	--out_dir | -o)
		out_dir="$2"
		;;
	--paired | -p)
		paired=true
		;;
	--srr | -s)
		srr="$2"
		;;
	--script_dir | -s)
		main_dir="$2"
		;;
esac
shift
done
#################
##Heading	#
#################
echo -e "\nViruSpy\n"

if [[ -z $srr ]]; then
	echo -e "\tNo SRR provided, exiting."; exit
elif [[ -z $out_dir ]]; then
	echo -e "\tNo output directory provided, exiting."; exit
fi
if [[ -z $blastDB ]] && [[ -z $fasta ]]; then
	echo -e "\tNo fasta or blastDB file provided, resorting to defaults.\n"
fi
echo -e "\tSRR:\t$srr"
if [ -z $fasta ] && [ -z $blastDB ]; then
	echo -e "\tFasta:\tDefault"
elif [ -z $fasta ]; then
	blastDB=$(readlink -e $blastDB)
	echo -e "\tBlastDB:$blastDB"
else
	fasta=$(readlink -e $fasta)
	echo -e "\tFasta:\t$fasta"
fi
if [ -z $main_dir ]; then
	main_dir="/zfs1/ncbi-workshop/virus-discovery/opts_scripts"
fi
echo -e "\tScripts:$main_dir"
echo -e "\tOutput:\t$out_dir"

if [ $paired ]; then
	echo -e "\tPaired:\tTrue"
else
	echo -e "\tPaired:\tFalse"
fi
echo -e "\n"

#srr=SRR1553459
#virDB=/zfs1/ncbi-workshop/virus-discovery/opts_scripts/viral.all.1.genomic.fna
#main_dir=/zfs1/ncbi-workshop/virus-discovery/opts_scripts

#################
#Directories	#
#################
if [ -d $out_dir ]; then
	echo -e "\tSpecified output directory already exists, exiting.\n"; exit
else
	mkdir -p $out_dir
	out_dir=$(readlink -e $out_dir)
fi
magic_dir=$out_dir/data_magicblast
mega_dir=$out_dir/data_megahit
glim_dir=$out_dir/data_glimmer
rpst_dir=$out_dir/data_annotate
out_dir=$out_dir/data_user

mkdir -p $magic_dir
rm -f -r $mega_dir		#Megahit won't overwrite directories, so delete if it already exists.
mkdir -p $glim_dir
mkdir -p $rpst_dir
mkdir -p $out_dir

#################
#Script Locs.	#
#################
magic_blast=$main_dir/magicblast_w_opts.sh
megahit=$main_dir/megahit_opts.sh
glimmer=$main_dir/glimmer_opts.sh
rpst=$main_dir/rpstblstn.sh

#################
#Execution	#
#################
#Make scripts executable.
chmod a+x $magic_blast
chmod a+x $megahit
chmod a+x $glimmer
chmod a+x $rpst

##Run MagicBlast##
cd $magic_dir
$magic_blast -s $srr -f $fasta -o $srr".fastq"
cd $out_dir

##Run MegaHit##
$megahit -i $magic_dir/$srr.fastq -o $srr -d $mega_dir

##Run Glimmer##
#$glimmer 

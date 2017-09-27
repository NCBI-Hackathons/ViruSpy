#!/bin/bash

#This SRR is for an Ebola sample (so should be all virus I think)
#Paired end 
#Illumina HiSeq

while getopts f:b:s:o:p: option
do
case "${option}"
	in
	s) srr=${OPTARG};;
	f) fasta=${OPTARG};;
	d) blastDB=${OPTARG};;
	o) main_dir=${OPTARG};;
	p) paired=${OPTARG:$true};;
esac
done
if [[ -z $srr ]]; then
	echo "No SRR provided, exiting."; exit
elif [[ -z $main_dir ]]; then
	echo "No output directory provided, exiting.";exit
fi



echo $srr
echo $virDB
echo $main_dir
echo $paired

srr=SRR1553459
virDB=/zfs1/ncbi-workshop/virus-discovery/opts_scripts/viral.all.1.genomic.fna
main_dir=/zfs1/ncbi-workshop/virus-discovery/opts_scripts
magic_dir=$main_dir/data_magicblast
mega_dir=$main_dir/data_megahit
glim_dir=$main_dir/data_glimmer
out_dir=$main_dir/data_user

#exit

mkdir -p $magic_dir
rm -f -r $mega_dir		#Megahit won't overwrite directories, so delete if it already exists.
mkdir -p $out_dir
mkdir -p $glim_dir

#set main director
cd $main_dir

##Scripts##
magic_blast=$main_dir/magicblast_w_opts.sh
megahit=$main_dir/megahit_opts.sh
glilmmer=$main_dir/glimmer_opts.sh

#Make scripts executable.
chmod a+x $magic_blast
chmod a+x $megahit
chmod a+x $glimmer

##Run MagicBlast##
cd $magic_dir
$magic_blast -s $srr -f $virDB -o $srr.fastq
cd $main_dir

##Run MegaHit##
$megahit -i $magic_dir/$srr.fastq -o $srr -d $mega_dir

##Run Glimmer##
$glimmer 

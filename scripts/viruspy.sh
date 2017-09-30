#!/bin/bash
set -euo pipefail  # bash strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
IFS=$'\n\t'

#This SRR is for an Ebola sample (so should be all virus I think)
#Paired end
#Illumina HiSeq

srr=""
outdir=""
fasta=""
blastDB=""
paired=""
main_dir=$(pwd)
threads=2
while getopts f:b:s:o:p:t: option
do
case "${option}"
	in
	s) srr=${OPTARG};;
	f) fasta=${OPTARG};;
	b) blastDB=${OPTARG};;
	d) bud=${OPTARG};;
	o) outdir=${OPTARG};;
	p) paired=${OPTARG};;
	t) threads=${OPTARG};;
esac
done
if [[ -z $srr ]]; then
	echo "No SRR provided, exiting."; exit
elif [[ -z $outdir ]]; then
	echo "No output directory provided, exiting.";exit
elif [[ ! -z $fasta && ! -z $blastDB ]]; then
	echo "Cannot use both -f and -d options together, exiting."; exit
elif [[ $threads -le 0 ]]; then
	echo "Threads must be >= 1, exiting."; exit
fi

echo srr: $srr
echo outdir: $outdir
echo blastDB: ${blastDB:-viralrefseq}
echo paired: ${paired:-true}

#srr=SRR1553459
#virDB=viral.all.1.genomic.fna
#main_dir=/zfs1/ncbi-workshop/virus-discovery/opts_scripts/

magic_dir=$outdir/data_magicblast
mega_dir=$outdir/data_megahit
glim_dir=$outdir/data_glimmer
out_dir=$outdir/data_user

mkdir -p $magic_dir
rm -f -r $mega_dir		#Megahit won't overwrite directories, so delete if it already exists.
mkdir -p $out_dir
mkdir -p $glim_dir

##Scripts##
magic_blast=magicblast_w_opts.sh
megahit=megahit_opts.sh
glimmer=glimmer_opts.sh

##Run MagicBlast##
cd $magic_dir
if [[ ! -z $fasta ]]; then
	$magic_blast -s $srr -f "../../$fasta" -o $srr.fastq
elif [[ ! -z $blastDB ]]; then
	$magic_blast -s $srr -b "../../$blastDB" -o $srr.fastq
fi
cd $main_dir

##Run MegaHit##
$megahit -i $magic_dir/$srr.fastq -o $srr -d $mega_dir

##Run Glimmer##
$glimmer

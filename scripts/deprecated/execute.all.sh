#!/bin/bash

#This SRR is for an Ebola sample (so should be all virus I think)
#Paired end 
#Illumina HiSeq
srr=SRR1553459

#path to main director
main_dir=/zfs1/ncbi-workshop/virus-discovery/executable.scripts

#set main director
cd $main_dir

#make all scripts executable
chmod a+x wget.refseq.sh
chmod a+x magicblast_samtools.sh
chmod a+x megahit.sh
chmod a+x prinseq.sh

source wget.refseq.sh


cd $main_dir/test

source /$main_dir/magicblast_samtools.sh

source /$main_dir/megahit.sh

cd $main_dir/test/megahit_out

source /$main_dir/prinseq.sh


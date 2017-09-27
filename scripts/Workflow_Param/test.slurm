#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH -N 1  # Ensure all cores are on one machine
#SBATCH -n 8
#SBATCH --output=output_slurm
#SBATCH --job-name=test_bud_control
#SBATCH --mem=128g

module purge 

module load compiler/perl/5.22.0
module load samtools/1.5-gcc5.2.0
module load magic-blast/1.2.0
module load megahit/1.1.2
module load blast+/2.6.0

#export PERL5LIB=/ihome/ncbi-workshop/CRCWORK3/past_virus_exposure_detection-master/scripts/bioperl

./param.sh -s SRR1553459 -d Phantome_Fasta/Phantome.fasta

#!/bin/bash


#load glimmer

module load glimmer/3.02


#set working directory

cd /zfs1/ncbi-workshop/virus-discovery/glimmer_test


#run glimmer
  
  
long-orfs -n -t 1.15 Amazon.fa amazon.longorfs


extract -t Amazon.fa amazon.longorfs > amazon.train


build-icm -r amazon.icm < amazon.train


glimmer3 -l -o50 -g110 -t30 Amazon.fa amazon.icm amazon.out




grep -B1 'orf' amazon.out.predict > predicted.orfs.txt


grep '>' predicted.orfs.txt > contigs.numbers.txt


grep -A1 -f contigs.numbers.txt Amazon.fa > contigs.with.annotated.genes.fa


rm contigs.numbers.txt


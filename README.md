# ViruSpy: a pipeline for viral identification from metagenomic samples

## Goal

To identify viral gene sequences and even full virus genomes from metagenomic sequencing data available in NCBI's SRA database

## Why this is important?

Viruses compose a large amount of the genomic biodiversity on the planet, but only a small fraction of the viruses that exist are known. To help fill this gap in knowledge we have produced a pipeline that can identify putative viral sequences from large scale metagenomic datasets that already exist in the SRA database.

## What is ViruSpy?

ViruSpy is a program for identiying viral genes and genomes from metagenomic datasets. This pipeline first obtains a set of reference sequences from the NCBI Viral RefSeq server, or as input from the user, and constructs a BLAST index. Next it runs Magic-BLAST on a user specified file from the SRA database. Magic-BLAST is used here to obtain all the virus-like sequences from a metagenomic sample for use with MegaHit, succinct desbrun graph based genome assembly software. Contigs built by MegaBlast are then ran through Glimmer3 to predict open reading frames and Hammer/RPST-BLASTn to predict conserved protein domains. Output files from both of these methods are combined to identify a high confidence set of viral contigs. 

## Workflow 

Virusspace first gathers refseq viral genomes or uses a user supplied fasta, or BLAST database. The SRA file is selected to search for viruses in and the BLAST database is selected so that we use it in conjunction with Magic-BLAST to find putative viral reads.

![alt text](https://github.com/NCBI-Hackathons/VirusCore/blob/master/Slide2.jpg "Obtaining SRA Data and BLAST Databases")

### Magic-BLAST

[Magic-BLAST GitHub repo](https://github.com/boratyng/magicblast)

[Magic-BLAST NCBI Insights](https://ncbiinsights.ncbi.nlm.nih.gov/2016/10/13/introducing-magic-blast/)

The pipeline starts with Magic-BLAST leveraging this tools ability to access SRA data without downloading any large files. A SAM file is generated which is then converted to a FASTQ file for downstream use with MEGAHIT.

### MEGAHIT

[MEGAHIT GitHub repot](https://github.com/voutcn/megahit)

[MEGAHIT Paper](https://www.ncbi.nlm.nih.gov/pubmed/25609793)

The MEGAHIT assembler is a succinct desbrun graph based genome assembler that we used to generate contigs from the Magic-BLAST results.

### Protein Domain Identification

Protein domains were identified in the contigs using both PSSM and HMM methods. 

### Glimmer3

[Glimmer3 Page at JHU](https://ccb.jhu.edu/software/glimmer/)

[Glimmer3 Paper](https://ccb.jhu.edu/papers/glimmer3.pdf)

[Glimmer3 manual/notes PDF](https://ccb.jhu.edu/software/glimmer/glim302notes.pdf)

Glimmer3 was used to identify putative open reading frames in the contigs.

![alt text](https://github.com/NCBI-Hackathons/VirusCore/blob/master/Slide3.jpg "The Pipeline")

## Installing ViruSpace

## ViruSpace Usage

viruspy.sh -srr SRR123456 -vdb viral.refseq -out output_folder

##### -srr 
  SRR number from SRA database

##### - vdb 
  


## ViruSpace Testing and Validation

## Additional Functionality













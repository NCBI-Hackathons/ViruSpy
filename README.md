# ViruSpy: a pipeline for viral identification from metagenomic samples

## What is ViruSpy?

ViruSpy is a pipeline designed for virus discovery from metagenomic sequencing data available in NCBI’s SRA database. The first step lies in identification of viral reads in the metagenomic sample with Magic-BLAST, which allows this step without the need for downloading the metagenomic dataset to the local computer. The extracted raw reads are assembled into contigs by use of MEGAHIT and annotated for genes by Glimmer and for conserved domains by RPS-TBLASTN. Following integration of Building Up Domains (BUD) algorithms allows to whether the viral genomes are non-native (i.e. integrated) to a host genome.

## Why is this important?

Viruses compose a large amount of the genomic biodiversity on the planet, but only a small fraction of the viruses that exist are known. To help fill this gap in knowledge we created a pipeline that can identify putative viral sequences from large scale metagenomic datasets that already exist in the SRA database.

Viruses across multiple virus families are found integrated in host genomes. By including the BUD algorith to the pipeline, we are able to identify these integratd viruses and its host genomes.

## ViruSpy Workflow

The ViruuSpy requires user to provide the SRA ID of the metagenomic sample to be searched through and a reference viral genome database. The reference viral genome database can be either supplied to the ViruSpy by user in form of FASTA file or BLAST database, or if neither is provided, ViruSpy will default to the RefSeq viral genome database and attempt to download those sequences in FASTA format. 

For convenience, a [utility](https://github.com/NCBI-Hackathons/VirusCore/blob/master/get_refseq_viral_seqs.sh) has been provided to download the most recent release of RefSeq viral genomes from NCBI. The resulting FASTA file can be used as the reference file for ViruSpy.
<img src="https://github.com/NCBI-Hackathons/VirusCore/blob/master/input.png" height="400" width="550">

Once Magic-BLAST returns all of the virus-like sequences in the SRA sample, they are assembled into contigs using the MEGAHIT assembler.

Contigs are verified as viral sequences through two methods: Glimmer3 predicts open reading frames within the contigs and RPS-tBLASTn predicts conserved protein domains. Viral domains have been determined based upon the NCBI CDD database. Output files from both of these methods are combined to identify a set of high confidence viral contigs. 

![alt text](https://github.com/NCBI-Hackathons/VirusCore/blob/master/Workflow_Diagram.JPG "Workflow Overview")

Using the identified viral reads, the determination of endogenous reads within a host relies upon the Building Up Domains (BUD) algorithm. BUD takes as input an identified viral contig from a metagenomics dataset and it runs the two ends of the identified contig through MagicBLAST to find overlapping reads. These reads are then used to extend the contig in both directions. This process continues until non-viral domains are identified on either side of the original viral contig, implying that the original contig was endogenous in the host, or until a specified number of iterations has been reached. This process is depicted below:

![alt text](https://github.com/NCBI-Hackathons/VirusCore/blob/master/BUD_Algorithm.JPG "Building Up Domains Algorithm")
### Useful References

#### Magic-BLAST

[BLAST Command Line Manual](https://www.ncbi.nlm.nih.gov/books/NBK279690/)

[Magic-BLAST GitHub repo](https://github.com/boratyng/magicblast)

[Magic-BLAST NCBI Insights](https://ncbiinsights.ncbi.nlm.nih.gov/2016/10/13/introducing-magic-blast/)

#### MEGAHIT

[MEGAHIT GitHub repo](https://github.com/voutcn/megahit)

[MEGAHIT Paper](https://www.ncbi.nlm.nih.gov/pubmed/25609793)

#### Protein Domain Identification

[BLAST Command Line Manual](https://www.ncbi.nlm.nih.gov/books/NBK279690/)

[NCBI Conserved Domain and Protein Classification](https://www.ncbi.nlm.nih.gov/Structure/cdd/cdd_help.shtml)

#### Glimmer3

[Glimmer3 Page at JHU](https://ccb.jhu.edu/software/glimmer/)

[Glimmer3 Paper](https://ccb.jhu.edu/papers/glimmer3.pdf)

[Glimmer3 Manual](https://ccb.jhu.edu/software/glimmer/glim302notes.pdf)

## Installing ViruSpy

## ViruSpy Usage

viruspy.sh [-d] -srr SRR123456 -f/-b viral.refseq -out output_folder

#### -srr

  SRR acession number from SRA database

#### -f 

  FASTA file containing viral sequences to be used in construction of a BLAST database

#### -b 

  BLAST database with viral sequences to be used with Magic-BLAST

#### -d
   
  Determine viruses signatures that are integrated into a host genome (runs the BUD algorithm)

#### -out

  Specify a folder to 

## ViruSpy Testing and Validation

## Additional Functionality













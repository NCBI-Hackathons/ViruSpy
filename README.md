# ViruSpy: a pipeline for viral identification from metagenomic samples

## What is ViruSpy?

ViruSpy is a pipeline that identifies viral gene sequences and even full virus genomes from metagenomic sequencing data available in NCBI's SRA database. From these, ViruSpy determines whether the viral sequences are non-native (i.e. integrated) to a host genome.

## Why is this important?

Viruses compose a large amount of the genomic biodiversity on the planet, but only a small fraction of the viruses that exist are known. To help fill this gap in knowledge we have created a pipeline that can identify putative viral sequences from large scale metagenomic datasets that already exist in the SRA database.

Viruses across multiple virus families are found integrated in host genomes. The genes that are integrated depends upon the specific viral integration. Sometimes the integration event is a complete genome or partial genome.

## Workflow 

NOTE: Delete after workflow below is complete and replace this space with workflow diagram

The pipeline obtains a set of reference sequences from the NCBI Viral RefSeq server, or as input from the user, and constructs a BLAST database from it. Next it runs [Magic-BLAST](https://ncbi.github.io/magicblast/) to align reads from an SRA library to the BLAST database. Magic-BLAST is used here to obtain all the virus-like sequences from a metagenomic sample for use with MegaHit, succinct De Bruin graph based genome assembly software. Contigs built by MegaHit are then run through Glimmer3 to predict open reading frames and RPS-TBLASTN to predict conserved protein domains. Output files from both of these methods are combined to identify a high confidence set of viral contigs.

In addition, VirusSpy attempts to extend the viral contigs with host reads by an iterative process that we call BUD: building up domains. The BUDing process

## Workflow

ViruSpy gathers reference viral genomes through either a user-supplied FASTA file or BLAST database. If neither is given, ViruSpy will default to the RefSeq viral genome database and attempt to download those sequences in FASTA format. Reads from the provided SRA ID are searched against this database using Magic-BLAST to find putative viral reads.

For convenience, a [utility](https://github.com/NCBI-Hackathons/VirusCore/blob/master/get_refseq_viral_seqs.sh) has been provided to download the most recent release of RefSeq viral genomes from NCBI. The resulting FASTA file can be used as the reference file for ViruSpy.

Once Magic-BLAST returns all of the virus-like sequences in the SRA sample, they are assembled into contigs using the MEGAHIT assembler.

Contigs are verified as viral sequences through two methods: Glimmer3 predicts open reading frames within the contigs and RPS-tBLASTn predicts conserved protein domains. Viral domains have been determined based upon the NCBI CDD database. Output files from both of these methods are combined to identify a set of high confidence viral contigs. 

Using the identified viral reads, the determination of endogenous reads within a host relies upon the Building Up Domains (BUD) algorithm. BUD takes as input an identified viral contig from a metagenomics dataset and it runs the two ends of the identified contig through MagicBLAST to find overlapping reads. These reads are then used to extend the contig in both directions. This process continues until non-viral domains are identified on either side of the original viral contig, implying that the original contig was endogenous in the host, or until a specified number of iterations has been reached. This process is depicted below:

![alt text](https://github.com/NCBI-Hackathons/VirusCore/blob/master/BUD.png "Building up domains algorithm")

### Delete pictures below once workflow diagram is added

![alt text](https://github.com/NCBI-Hackathons/VirusCore/blob/master/Slide2.jpg "Obtaining SRA Data and BLAST Databases")


![alt text](https://github.com/NCBI-Hackathons/VirusCore/blob/master/Slide3.jpg "The Pipeline")

Using the identified viral reads, the determination of endogenous reads within a host relies upon the Building Up Domains (BUD) algorithm. BUD takes as input an identified viral contig from a metagenomics dataset and it runs the two ends of the identified contig through MagicBLAST to find overlapping reads. These reads are then used to extend the contig in both directions. This process continues until non-viral domains are identified on either side of the original viral contig, implying that the original contig was endogenous in the host, or until a specified number of iterations has been reached. This process is depicted below:

![alt text](https://github.com/NCBI-Hackathons/VirusCore/blob/master/BUD.png "Building up domains algorithm")

### References

### Magic-BLAST

[BLAST Command Line Manual](https://www.ncbi.nlm.nih.gov/books/NBK279690/)

[Magic-BLAST GitHub repo](https://github.com/boratyng/magicblast)

[Magic-BLAST NCBI Insights](https://ncbiinsights.ncbi.nlm.nih.gov/2016/10/13/introducing-magic-blast/)

The pipeline starts with Magic-BLAST leveraging this tools ability to access SRA data without downloading any large files. A SAM file is generated which is then converted to a FASTQ file for downstream use with MEGAHIT.

### MEGAHIT

[MEGAHIT GitHub repo](https://github.com/voutcn/megahit)

[MEGAHIT Paper](https://www.ncbi.nlm.nih.gov/pubmed/25609793)

The MEGAHIT assembler is a succinct de Bruijn graph-based genome assembler that is used to generate contigs from the viral reads derived from Magic-BLAST.

### Protein Domain Identification

Protein domains were identified using NCBI's RPS-tBLASTn.

[BLAST Command Line Manual](https://www.ncbi.nlm.nih.gov/books/NBK279690/)

[NCBI Conserved Domain and Protein Classification](https://www.ncbi.nlm.nih.gov/Structure/cdd/cdd_help.shtml)

### Glimmer3

Glimmer3 was used to identify putative open reading frames in the contigs.

[Glimmer3 Page at JHU](https://ccb.jhu.edu/software/glimmer/)

[Glimmer3 Paper](https://ccb.jhu.edu/papers/glimmer3.pdf)

[Glimmer3 manual/notes PDF](https://ccb.jhu.edu/software/glimmer/glim302notes.pdf)

## BUD Algorithm

Used to extend contigs that possess viral domains for the purpose of identifying host genome integration sites

# Installing ViruSpy

# ViruSpy Usage

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

## ViruSpace Testing and Validation

## Additional Functionality













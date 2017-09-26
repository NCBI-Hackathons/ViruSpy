# VirusCore
## A shared repository for viral identification

ViruSpy obtains a set of reference sequences from the NCBI Viral RefSeq server, or as input from the user, and constructs a BLAST index before running Magic-BLAST on a user specified file from the SRA database. Magic-BLAST is used here to obtain all the virus-like sequences from a metagenomic sample for use with MegaHit, succinct desbrun graph based genome assembly software (reference earth microbiome and SOAP denovo). Contigs built by MegaBlast are then ran through Glimmer3 to predict open reading frames and Hammer/RPST-BLASTn to predict conserved protein domains. Output files from both of these methods are combined to identify a high confidence set of viral contigs. 

![alt text](https://github.com/NCBI-Hackathons/VirusCore/blob/master/Slide2.jpg "Obtaining SRA Data and BLAST Databases")



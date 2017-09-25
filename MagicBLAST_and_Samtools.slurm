#!/usr/bin/env bash
#SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=10gb
#SBATCH --job-name=MagicBLASTSamtools

module purge
module load magic-blast/1.2.0
module load samtools/1.3.1-gcc5.2.0


##Jacob's Code

echo "Generating Viral RefSeq Database for MAGICBLAST"

output_dir=test1
mkdir $output_dir

cd $output_dir
wget ftp://ftp.ncbi.nlm.nih.gov/refseq/release/viral/viral.1.1.genomic.fna.gz
wget ftp://ftp.ncbi.nlm.nih.gov/refseq/release/viral/viral.2.1.genomic.fna.gz
gunzip viral.1.1.genomic.fna.gz
gunzip viral.2.1.genomic.fna.gz
cat viral.1.1.genomic.fna viral.2.1.genomic.fna > viral.all.1.genomic.fna
rm viral.1.1.genomic.fna
rm viral.2.1.genomic.fna

##Mitch's Code

#MAGICBLAST

echo "Running MAGICBLAST"

makeblastdb -dbtype nucl -in viral.all.1.genomic.fna -out viral.db

#[mae92@login0a ~]$ magicblast -h
#USAGE
#  magicblast [-h] [-help] [-db database_name] [-gilist filename]
#   [-seqidlist filename] [-negative_gilist filename]
#   [-db_soft_mask filtering_algorithm] [-db_hard_mask filtering_algorithm]
#   [-subject subject_input_file] [-subject_loc range] [-query input_file]
#   [-out output_file] [-gzo] [-word_size int_value] [-gapopen open_penalty]
#   [-gapextend extend_penalty] [-perc_identity float_value]
#   [-penalty penalty] [-lcase_masking] [-validate_seqs TF] [-infmt format]
#   [-paired] [-query_mate infile] [-sra accession] [-parse_deflines TF]
#   [-outfmt format] [-num_threads int_value] [-max_intron_length length]
#   [-score num] [-splice TF] [-reftype type] [-limit_lookup TF]
#   [-lookup_stride num] [-batch_size num] [-version]


#Permissible values: 'asn' 'sam' 'tabular' 

blastdb=viral.db
#srr=SRR1161435 west nile viurs
srr=SRR5675673 #amazon river metagenomics


num_threads=2
out_file=putative_viral_reads.sam
out_format=sam
word_size=20
percent_id_cuttoff=60

##This is for paired end reads
echo "Running MAGICBLAST"

magicblast -db $blastdb -sra $srr -paired -num_threads $num_threads -out $out_file -outfmt $out_format -word_size $word_size -perc_identity $percent_id_cuttoff


#SAMTOOLS

echo "Converting putative viral reads back to FASTQ format"

samtools view -bS putative_viral_reads.sam > putative_viral_reads.bam


samtools fastq putative_viral_reads.bam > putative_viral_reads.fastq

rm putative_viral_reads.sam
rm putative_viral_reads.bam










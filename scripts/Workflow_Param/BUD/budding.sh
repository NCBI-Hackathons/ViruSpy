usage() { echo "$0 usage:" && grep " .)\ #" $0; exit 0; }
[ $# -eq 0 ] && usage
while getopts ":h:c:s:n:" arg; do
  case $arg in
    c) # Path of Viral Contig File
      contigs=${OPTARG}
      echo "The viral contig file is located at $contigs."
      ;;

    s) # SRR Number to Connect to Magic-BLAST
      srr=${OPTARG}
      echo "The SRR number of this run is $srr."
      ;;

    n) # Number of iterations of BUD Algorithm
      num=${OPTARG}
      echo "The number of iterations of the BUD Algorithm is $num."
      ;;
 
    h | *) # Display help.
      usage
      exit 0
      ;;
  esac
done

shift "$((OPTIND-1))"

for (( c=1; c<=$num; c++)) 
do 

echo "Trim Ends and Make Database"
./contig2blastdb.pl -f $contigs -d ends

echo "$c Magic BLAST"
magicblast -db ends -sra $srr -num_threads 2 | samtools view -bS - | samtools sort -o $srr.bam

samtools view $srr.bam | awk '{OFS="\t"; print ">"$1"\n"$10}' > $srr.fa

rm $srr.bam

## Combine Sequence Files
cat *.fa > $srr_combined_ends.fasta

## Assemble Reads, Ends, and Contig
megahit -r $srr_combined_ends.fasta -o $srr

mv $srr/final.contigs.fa $c_$srr.fa
rm -r $srr

done



# End of File

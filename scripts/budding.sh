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

echo $c
case $c in 
1) 
	echo "Trim Ends and Make Database"
	./contig2blastdb.pl -f $contigs -d ends

	echo “Magic BLAST number $c, mapping reads against ends“

	## Retrieve Reads and Convert to Fasta
	magicblast -db ends -sra $srr -num_threads 2 | samtools view -bS - | samtools sort -o $srr.bam
	samtools view $srr.bam | awk '{OFS="\t"; print ">"$1"\n"$10}' > $srr.fa

	rm $srr.bam

	## Combine Sequence Files
	cat *.fa > combined_ends_$c.fasta

	## Assemble Reads, Ends, and Contig
	megahit -r combined_ends_$c.fasta -o $srr

	mv combined_ends_$c.fasta $srr/

	mv $srr/final.contigs.fa contigs_assembled_$c.fa

	## Remove Assembly Directory
	rm -r $srr

	mkdir individual_contigs
	mkdir extended_contigs
	cd individual_contigs/

	echo Split fasta files
	awk '/^>/ {OUT=substr($0,2) ".fa"}; {print >> OUT; close(OUT)}' ../contigs_assembled_$c.fa

	rename 's/\s.*$//' *

	echo Perform Extend Match Check
	for f in *;do ../contig_extend_match.pl -q $f -c ../$contigs -x ../extended_contigs/extended_$f.fasta;done;

	

	cd ..

	;;
*)
	echo "Trim New Contig Ends and Make Database"
	./contig2blastdb.pl -f contigs_assembled_*.fa -d ends

	echo “Magic BLAST number $c, mapping reads against ends“

	rm $srr.fa

	## Retrieve Reads and Convert to Fasta
	magicblast -db ends -sra $srr -num_threads 2 | samtools view -bS - | samtools sort -o $srr.bam
	samtools view $srr.bam | awk '{OFS="\t"; print ">"$1"\n"$10}' > $srr.fa

	rm $srr.bam

	## Combine Sequence Files
	cat *.fa > combined_ends_$c.fasta

	## Assemble Reads, Ends, and Contig
	megahit -r combined_ends_$c.fasta -o $srr

	## Store the past iteration for checks downstream
	mv contigs_assembled_*.fa past_iteration_contigs.fasta
	rm contigs_assembled_*
	rm -r extended_contigs/
	rm -r individual_contigs/

	mv combined_ends_$c.fasta $srr/

	mv $srr/final.contigs.fa contigs_assembled_$c.fa

	## Remove Assembly Directory
	rm -r $srr

	mkdir individual_contigs
	mkdir extended_contigs
	cd individual_contigs/

	echo ‘Split fasta files’
	awk '/^>/ {OUT=substr($0,2) ".fa"}; {print >> OUT; close(OUT)}' ../contigs_assembled_$c.fa

	rename 's/\s.*$//' *

	echo Perform Extend Match Check
	for f in *;do ../contig_extend_match.pl -q $f -c ../past_iteration_contigs.fasta -x ../extended_contigs/extended_$f.fasta;done;

	cd ..

	rm past_iteration_contigs.fasta

	;;

  esac

done

# End of File
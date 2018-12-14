#!/bin/bash

# required v5 nt blastdb  ftp://ftp.ncbi.nlm.nih.gov/blast/db/v5
# ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.8.0alpha/

#referencing the Stack Overflow answer that helped me address this particular problem
#http://stackoverflow.com/a/4419971/2146843
exitfunc()
{
exit 1
}

#get first arg from command line
GENE="$1"

if [[ -z $GENE ]]; then
	echo
	cat help.txt
	exitfunc
fi


#limit results to these tax ids
TAXIDS_TO_SEARCH_AGAINST="591946,364106,362663"


#location of blast executables
BLASTDIR=/bigdata/gen220/gloga001/ncbi-blast-2.8.0+/bin
BLASTN=$BLASTDIR/blastn
BLASTCMD=$BLASTDIR/blastdbcmd

#location of blastdb
NCBIDIR=/bigdata/gen220/gloga001/v5
DB=$NCBIDIR/nt



#extract fastas from nt database
$BLASTCMD -db "$DB" -entry "$GENE" -out "$GENE.fasta"


#blast fastas to nt dabase
OPTS="qseqid qlen saccver pident gaps mismatch length evalue bitscore staxids stitle qseq sseq"

QUERY="$GENE.fasta"
SIZE=$(stat --printf="%s" $QUERY)

#run blast
if [[ $SIZE -ne 0 ]]; then
    echo $GENE
    OUTFILE="$GENE.blastout.txt"
    $BLASTN \
    -task 'blastn' -db "$DB" \
    -query "$QUERY" \
    -taxids "$TAXIDS_TO_SEARCH_AGAINST" \
    -max_target_seqs "100" \
    -evalue "0.001" \
    -outfmt "7 $OPTS" \
    -out "$OUTFILE"
else
    echo "$GENE not found in nt"
fi


#run the r script
Rscript genes.R


#display results with less (which are saved in R)
cat $GENE.results.txt | less -S



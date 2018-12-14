

#get file names from current directory
files <- list.files(pattern="blastout.txt")



for(fp in files) {
    # fp <- files[2]
    #read file
    hits1 <- read.delim(fp, header = FALSE, comment.char = '#')

    #define column names
    colnames(hits1) <- c("qseqid","qlen","saccver","pident","gaps","mismatch","length","evalue","bitscore","staxids","stitle","qseq","sseq")
    # dim(hits1)
    # hits1[,1:11]

    gene <- sub("\\.blastout.txt", "", fp)
    # gene
    #remove any hits to self
    self_rows <- grep(gene, hits1$saccver)
    if(length(self_rows) > 0) {
        hits2 <- hits1[-self_rows,]
    } else {
        hits2 <- hits1
    }
    # hits2[,1:11]

    #remove duplicated taxid rows
    dup_taxids <- duplicated(hits2$staxids)
    hits3 <- hits2[!dup_taxids,]
    # hits3[,1:11]

    #sort descending by bitscore
    hits3 <- hits3[order(-hits3$length),]
    # hits3[,1:11]

    #remove poor hits by % of best aligned length
    cutoff <- 0.5
    denom <- hits3$length[1]
    ratios <- hits3$length / denom
    bad_hits <- which(ratios <= cutoff)
    if(length(bad_hits) > 0) {
        hits4 <- hits3[-bad_hits,]
    } else {
        hits4 <- hits3
    }
    write.table(hits4, file=paste0(gene,".results.txt"), sep="\t", row.names=FALSE, col.names=TRUE, quote=FALSE)
}



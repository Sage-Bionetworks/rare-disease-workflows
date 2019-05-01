##copy number detection
library(exomeCopy)
library(Rsamtools)
require(synapser)
require(parallel)

runCnvAnalysis<-function(bam.file.list,ncores){
   target.file<-synGet('syn18078824')$path
   reference<-synGet('syn18082228')$path

   bam.files<-mclapply(bam.file.list,function(x) synGet(x)$path,mc.cores=ncores)
   sample.names<-names(bam.file.list)
   target.df <- read.delim(target.file, header = FALSE)
   target <- GRanges(seqname = target.df[, 1], IRanges(start = target.df[, 2] + 1, end = target.df[, 3]))

   counts <- target

for (i in 1:length(bam.files)) {
   res=indexBam(bam.files[[i]])
   mcols(counts)[[sample.names[i]]] <- countBamInGRanges(bam.files[[i]],target)
   }
counts$GC <- getGCcontent(target, reference)
chroms=setdiff(seqlevels(target),c('X','Y'))

counts$GC.sq <- counts$GC^2
counts$bg <- generateBackground(sample.names, counts, median)
 counts$log.bg <- log(counts$bg + 0.1)
 counts$width <- width(counts)
 fit.list <- mclapply(names(bam.file.list), function(sample.name) {
   lapply(chroms, function(seq.name) {
     #print(seq.name)
    exomeCopy(counts[seqnames(counts) == seq.name],
      sample.name, X.names = c("log.bg", "GC",
       "GC.sq", "width"), S = 0:4, d = 2)
      })
    },mc.cores=ncores)
 compiled.segments <- compileCopyCountSegments(fit.list)
 

   return(compiled.segments)
 }

plotSegs<-function(compiled.segments){
   library("RColorBrewer")
   cols=brewer.pal(n = 8, name = "RdBu")
   abnorm=compiled.segments[compiled.segments$copy.count != 2]
   seqs=unique(compiled.segments@seqnames)
   file.list<-c()
   for(s in seqs){
      fname=paste('chrom',s,'copyNumb.png',sep='')
      png(fname)
      plotCompiledCNV(abnorm,seq.name=s,col=cols)
      dev.off()
      file.list<-c(file.list,fname)
   }
   return(file.list)
   
}

parseArgs<-function(){
   require(optparse)
   
}
 
 

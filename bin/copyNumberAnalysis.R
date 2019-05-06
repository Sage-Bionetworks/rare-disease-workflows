##copy number detection
library(exomeCopy)
library(Rsamtools)
require(synapser)
require(parallel)
library(GenVisR)

require(tidyverse)
plotBetterCopies<-function(segfile,prefix='',all.only=TRUE){
     
   new.tab<-segfile%>%rename(chromosome='seqnames',sample='specimenID',segmean='copy.count')
   
   if(!all.only){
   cnSpec(subset(new.tab,tumorType=='Plexiform Neurofibroma'),
      genome = "hg38", #jhu is based on hg38, which is different from our b37
      plot_title = "pNF Copy Altered Single Sample Graphic")
ggsave(paste0('pnfvals.png'))   

   mpnst.vals=cnSpec(subset(new.tab,tumorType=='Malignant Peripheral Nerve Sheath Tumor'),
             genome = "hg38", #jhu is based on hg38, which is different from our b37
           plot_title = "MPNST Copy Altered Single Sample Graphic")
   mpnst.vals
   ggsave(paste0(prefix,'mpnstVals.png'))
   

   na.vals=cnSpec(subset(new.tab,is.na(tumorType)),
      genome = "hg38", #jhu is based on hg38, which is different from our b37
      plot_title = "NF Copy Altered Single Sample Graphic")
   na.vals
   ggsave(paste0(prefix,'normalvals.png'))
   
}

      cnSpec(new.tab,genome='hg38',plot_title = 'Copy Altered Samples')      
      ggsave(paste0(prefix,'allsamps.png'))
      
      
   ##per-patient values
}

runCnvAnalysis<-function(bam.file.list,ncores){
   target.file<-synGet('syn18078824')$path
   reference<-synGet('syn18082228')$path

   bam.files<-lapply(bam.file.list,function(x) synGet(x)$path)#,mc.cores=ncores)
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
   
   abnorm=compiled.segments[compiled.segments$copy.count != 2]
   cols=brewer.pal(n = length(unique(abnorm$copy.count)), name = "Spectral")
   seqs=unique(compiled.segments@seqnames)
   file.list<-c()
   for(s in seqs){
      fname=paste('chrom',s,'copyNumb.png',sep='')
      png(fname)
      #chr.start <- start(range(abnorm@ranges))
      #chr.end <- end(range(abnorm@ranges))
      plotCompiledCNV(abnorm,copy.counts= unique(abnorm$copy.count),seq.name=s,col=cols)#,xlim=c(chr.start,chr.end))
      dev.off()
      file.list<-c(file.list,fname)
   }
   return(file.list)
   
}

parseArgs<-function(){
   require(optparse)
   
}
 
 

##copy number detection
library(exomeCopy)

require(synapser)

synLogin()

bam.files=c(synGet('syn18084363')$path,synGet('syn18083649')$path)

target.file<-synGet('syn18078824')$path

reference<-synGet('syn18082228')$path

sample.names<-c('samp1','samp2')
target.df <- read.delim(target.file, header = FALSE)
target <- GRanges(seqname = target.df[, 1], IRanges(start = target.df[, 2] + 1, end = target.df[, 3]))

counts <- target

for (i in 1:length(bam.files)) {
   mcols(counts)[[sample.names[i]]] <- countBamInGRanges(bam.files[i],
     target)
   }
counts$GC <- getGCcontent(target, reference.file)


counts$GC.sq <- counts$GC^2
counts$bg <- generateBackground(sample.names, counts,
  + median)
 counts$log.bg <- log(counts$bg + 0.1)
 counts$width <- width(counts)
 fit.list <- lapply(sample.names, function(sample.name) {
   lapply(seqlevels(target), function(seq.name) {
    exomeCopy(counts[seqnames(counts) == seq.name],
      sample.name, X.names = c("log.bg", "GC",
       "GC.sq", "width"), S = 0:4, d = 2)
      })
    })
 compiled.segments <- compileCopyCountSegments(fit.list)

##run and store metaviper on tcga data

library(synapser)
synLogin()
library(dplyr)

all.tcga<-read.csv(synGet('syn4311114')$path,sep='\t',header=T)
clin.data<-synTableQuery('select distinct patient_barcode, diseaseTitle,acronym from syn3281840')$asDataFrame()

pat.names<-colnames(all.tcga)
ind.ids<-sapply(pat.names[2:length(pat.names)],function(x) paste(unlist(strsplit(x,split='.',fixed=T))[1:3],collapse='-'))
this.script='https://raw.githubusercontent.com/sgosline/NEXUS/master/analysis/2019-04-24/formatTcgaForDten.R'

entrez.genes<-sapply(as.character(all.tcga$gene_id),function(x) unlist(strsplit(x,split='|',fixed=T))[2])
rownames(all.tcga)<-entrez.genes
all.tcga[,1]<-entrez.genes
tcga.tab<-tidyr::gather(all.tcga,"sample","counts",2:ncol(all.tcga))
tcga.tab$patient_barcode<-sapply(tcga.tab$sample,function(sample) paste(unlist(strsplit(sample,split='.',fixed=T))[1:3],collapse='-'))

full.tab<-tcga.tab%>%left_join(clin.data,by='patient_barcode')
non.pan.can<-subset(full.tab,acronym!='PANCAN')
fin.tab<-non.pan.can%>%select(gene='gene_id',patient='patient_barcode',condition='diseaseTitle',counts)

write.csv(fin.tab,file=gzfile('tcgaCountsTidied.csv.gz'),row.names=F,col.names=T)

synStore(File('tcgaCountsTidied.csv.gz',parent='syn18134640'),used=c('syn4311114','syn3281840'),executed=this.script)
#all.tcga$gene<-rownames(all.tcga)
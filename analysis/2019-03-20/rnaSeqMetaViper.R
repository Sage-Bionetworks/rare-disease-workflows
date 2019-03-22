###metaVIPER analysis of gene expression data

require(synapser)
require(limma)
require(tidyverse)
library(viper)


#get the tidied data with annotations
#require(reticulate)
#synapse <- import("synapseclient")
#syn <- synapse$Synapse()
#syn$login()

synLogin()
syn_file='syn18421359'
expData<-read.csv(gzfile(synGet(syn_file)$path))%>%subset(Symbol!='')

this.script='https://raw.githubusercontent.com/sgosline/NEXUS/master/analysis/2019-03-20/rnaSeqMetaViper.R'

####DO WE WANT THIS: remove cell culture!!
#expData<-subset(expData,isCellLine%in%c('false','FALSE'))

##add in schwann cells as default
conts=which(is.na(expData$tumorType))
levels(expData$tumorType)<-c(levels(expData$tumorType),'Schwann')
expData$tumorType[conts]<-as.factor(rep('Schwann',length(conts)))


library(aracne.networks)
#get aracne networks
net.names <- data(package="aracne.networks")$results[, "Item"]
all.networks <- lapply(net.names,function(x) get(x))
names(all.networks) <- net.names

#first add in entrez
require(biomaRt)
mart <- useMart('ensembl',dataset='hsapiens_gene_ensembl')

entrez_list <- getBM(filters = "hgnc_symbol", 
  attributes = c("hgnc_symbol", "entrezgene"), 
  values = unique(expData$Symbol), mart = mart)%>%
  rename(Symbol='hgnc_symbol')%>%
  right_join(expData,by='Symbol')%>%tidyr::unite('entre_syn',entrezgene,id,remove=F)

combined.mat=reshape2::acast(entrez_list,entrezgene~id,value.var="zScore",fun.aggregate=function(x) mean(x,na.rm=T))
res <- viper(combined.mat, all.networks)

##now re-shape to be tidy again and store!
rr<-tidyr::gather(data.frame(res,entrezgene=rownames(res)),key=id,value=viper,-entrezgene)%>%tidyr::unite('entre_syn',entrezgene,id)

#now paste the symbol_synId and then join 
vip.res<-rr%>%
    inner_join(dplyr::select(entrez_list,-c(totalCounts,zScore,X)),by='entre_syn')%>%
    separate(entre_syn,c('entrez','id'))


tab<-synBuildTable(name=paste(lubridate::today(),'metaVIPER proteins'),vip.res,parent='syn16941818')
synStore(tab)

##now do some pathway enrichment? 

##run and store metaviper on tcga data

library(viper)
library(synapser)
synLogin()

all.tcga<-read.csv(synGet('syn4311114')$path,sep='\t',header=T)

this.script=''
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
  right_join(expData,by='Symbol')%>%tidyr::unite('entre_syn',entrezgene,id)

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

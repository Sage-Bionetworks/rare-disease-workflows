###networks from proteins

require(synapser)
synLogin()
synQuery="SELECT * FROM syn18460033 WHERE ( ( padj BETWEEN '8.401022050521E-25' AND '0.00001' ) )"

##get github stuff
##get our pcsf
##get fendR


library(devtools)
#devtools::install_github('sgosline/PCSF')
#devtools::install_github('Sage-Bionetworks/fendR')
library(fendR)


require(tidyverse)
tab<-synTableQuery(synQuery)$asDataFrame()


drug.graph <- fendR::loadDrugGraph()
combined.graph <-fendR::buildNetwork(drug.graph)
all.drugs <- fendR::getDrugsFromGraph(drug.graph)

#print(names(all.vprots)[nz.sig])

prots<-lapply(as.character(unique(tab$tumorType)),function(x) {
  res<-subset(tab,tumorType==x)$stat
  names(res)<-subset(tab,tumorType==x)$gene
  res})
names(prots)<-as.character(unique(tab$tumorType))

w=2
b=1
mu=5e-04
fname=paste(paste(lubridate::today(),w,b,mu,sep='_'),'.rds',sep='')
all.genes<-unique(tab$gene)
require(parallel)
#TODO: make this multi-core, possibly break into smaller functions
all.res <- mclapply(names(prots), function(tumor){
  #create viper signature from high vs. low
  cat(tumor)
  #print(high)
  v.res=prots[[tumor]]
  newf=paste(tumor,fname,sep='_')
  
  if(file.exists(newf)){
    pcsf.res<-readRDS(newf)
  } else{
    # print(v.res)
    pcsf.res.id <-fendR::runPcsfWithParams(ppi=combined.graph,terminals=abs(v.res),dummies=all.drugs,w=w,b=b,mu=mu,doRand=TRUE)
    pcsf.res <-fendR::renameDrugIds(pcsf.res.id,all.drugs)
    
    
    saveRDS(pcsf.res,file=newf)
    
  }
  drug.res <- igraph::V(pcsf.res)$name[which(igraph::V(pcsf.res)$type=='Compound')]
  cat(paste("Selected",length(drug.res),'drugs in the graph'))
  ##collect stats, store in synapse table
  list(network=pcsf.res,
    drugs=drug.res,
    w=w,
    b=b,
    mu=mu,
    viperProts=names(v.res),
    tumor=unlist(strsplit(tumor,split='_'))[1],
    file=newf)
})

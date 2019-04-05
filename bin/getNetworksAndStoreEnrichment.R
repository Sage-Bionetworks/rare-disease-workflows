###run network enrichment and store on synase

library(PCSF)
library(synapser)
synLogin()

synProject='syn16941818'
source("../../bin/plotDrugsAcrossCells.R")


doEnrichment<-function(networkfile){
  net=readRDS(synGet(networkfile)$path)
  #get the enrichment
  res<-enrichment_analysis(net)
  
  full.res=res$enrichment
  
  ##now we can filter list to get significant terms
  non.sig<-which(full.res$Adjusted.P.value>0.05)
  print(paste('We have',length(non.sig),'GO terms that are not significanly enrichmed'))
  if(length(non.sig)>0)
    full.res=full.res[-non.sig,]
  
  ##tehn reduce really small areas of enrichment
  small.genes<-which(sapply(full.res$Genes,function(x) length(unlist(strsplit(x,split=';')))<5))
  print(paste('We have',length(small.genes),'GO terms with fewer than 5 genes in network'))
  if(length(small.genes)>0)
    full.res=full.res[-small.genes,]
  
  ##now figure out if there are overlaps of drugs in this tumor type
  full.res$HasCellLineData=sapply(full.res$DrugsByBetweenness,function(druglist){
    drug<-unlist(strsplit(druglist,split=';'))
    drugs.with.data<-intersect(drug,all.compounds)
    return(length(drugs.with.data)>0)
  })
  
  tab.dat=full.res%>%select('Cluster','Term','Overlap','Adjusted.P.value','Genes','DrugsByBetweenness','HasCellLineData')

  return(tab.dat)
  }

##eval selected networks

library(PCSF)
library(synapser)
synLogin()

pnf.net<-readRDS(synGet('syn18485726')$path)

res<-enrichment_analysis(pnf.net)

full.res=res$enrichment

##now we can filter list
non.sig<-which(full.res$Adjusted.P.value>0.05)
print(paste('We have',length(non.sig),'GO terms that are not significanly enrichmed'))
if(length(non.sig)>0)
  full.res=full.res[-non.sig,]

small.genes<-which(sapply(full.res$Genes,function(x) length(unlist(strsplit(x,split=';')))<5))
print(paste('We have',length(small.genes),'GO terms with fewer than 5 genes in network'))
if(length(small.genes)>0)
  full.res=full.res[-small.genes,]


##now do some extra enrichment to identify interesting drugs?
all.drugs=c()
p.val=lapply(all.drugs,function(d){
  drug.targs=c()
  drug.targs.in.net=c()
  total.genes.in.netc=c()
  total.drug.targs=c()
  pval=1.0
})
#now do correction

tumorType='pNF'
##next test: see if we have cell line data!
source("../../bin/plotDrugsAcrossCells.R")
drug.plots<-unlist(lapply(unique(full.res$DrugsByBetweenness),function(druglist,tumorType){
  drug<-unlist(strsplit(druglist,split=';'))
  drugs.with.data<-intersect(drug,all.compounds)
  #print(drugs.with.data)
  if(length(drugs.with.data)>0)
    return(unlist(lapply(drugs.with.data,plotDrugByCellAndTumor,tumorType=tumorType)))
  else
    return(NULL)
},tumorType))

##we're still missing good visualizations of drug subnetworks
getSubnetOfCluster<-function(network,cluster){
  sg=induced_subgraph(network,which(V(network)$group==cluster))
  class(sg)<-c('PCSF','igraph')
  return(sg)
  
}

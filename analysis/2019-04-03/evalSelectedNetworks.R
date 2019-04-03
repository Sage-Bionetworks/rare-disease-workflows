##eval selected networks

library(PCSF)
library(synapser)
synLogin()

mpnst.net<-readRDS(synGet('syn18483779')$path)

res<-enrichment_analysis(mpnst.net)

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


##now do some extra enrichment

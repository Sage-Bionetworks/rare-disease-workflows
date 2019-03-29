###networks from proteins


library(devtools)
if(!require(PCSF)){
  devtools::install_github('sgosline/PCSF')
  library(PCSF)
}
if(!require(fendR)){
  devtools::install_github('Sage-Bionetworks/fendR')
  library(fendR)
}




require(tidyverse)


runNetworkOnTumorTypes<-function(w,b,mu,all.genes,prots,combined.graph,all.drugs){

  fname=paste(paste(lubridate::today(),w,b,mu,sep='_'),'.rds',sep='')
    #TODO: make this multi-core, possibly break into smaller functions
    all.res <- lapply(names(prots), function(tumor){
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
      tumor=tumor,
      file=newf)
  }) 

  }
#'
#'trackNetworkStats takes a list of results from the drug test and shares them on synapse
#'@param pcsf.res.list
#'@param synTableId
#'@param esetFileId
#'@param viperFileId
#'
trackNetworkStats<-function(pcsf.res.list,synTableId='',viperTableId='',dsetName='',  pcsf.parent='syn18482718',  plot.parent='syn18483807'){

  
  this.script=''
  #decouple pcsf.res.list into data frame
  
  #  require(doMC)
  #  cl <- makeCluster(nnodes=8)
  require(parallel)
  # registerDoMC(cores=28)
  
  
  fin<-lapply(pcsf.res.list,function(x){
    #first store network
    network=x[['network']]
    w=x[['w']]
    b=x[['b']]
    mu=x[['mu']]
    fname=x[['file']]
    ko=x[['ko']]
    wt=x[['wt']]
    ds=x[['compoundStats']]%>%rename(Drug='Selected Drug',p.value='Drug Wilcoxon P-value')%>%mutate('Drug Prize Value'=as.numeric(prize))%>%ungroup()
    ds$`Drug Boxplot`=sapply(ds$figFile,function(y) synStore(File(y,parentId=plot.parent))$properties$id)
    res=synapser::synStore(File(fname,parentId=pcsf.parent),used=c(esetFileId,viperFileId),executed=this.script)
    
    ds=ds%>%dplyr::select(-figFile,-prize)
    #store image file
    upl<-data.frame(`NF1 KO`=ko,`NF1 WT`=wt,w=w,beta=b,mu=mu,
      `Viper Proteins`=paste(sort(x$viperProts),collapse=','),
      `Original eSet`=esetFileId,`Original metaViper`=viperFileId,
      `PCSF Result`=res$properties$id,`Dataset name`=dsetName,check.names=F)#,
    #                     check.names=F)
    
    upl2=merge(ds,upl)
    
    tres<-synapser::synStore(Table(synTableId,upl2))
  })#,mc.cores=28)
  #.parallel=TRUE,.paropts = list(.export=ls(.GlobalEnv)))
  #  stopCluster(cl)
  #store as synapse table
  
}




require(synapser)
synLogin()
synQuery="SELECT * FROM syn18460033 WHERE ( ( padj BETWEEN '8.401022050521E-25' AND '0.00001' ) )"
viper.prot.tab<-synTableQuery(synQuery)$asDataFrame()

##Get graphs
drug.graph <- fendR::loadDrugGraph()
combined.graph <-fendR::buildNetwork(drug.graph)
all.drugs <- fendR::getDrugsFromGraph(drug.graph)


prots<-lapply(as.character(unique(viper.prot.tab$tumorType)),function(x) {
  res<-subset(viper.prot.tab,tumorType==x)$stat
  names(res)<-subset(viper.prot.tab,tumorType==x)$gene
  res})
names(prots)<-as.character(unique(viper.prot.tab$tumorType))

all.genes<-unique(viper.prot.tab$gene)
#all.params=all.params[1:10,]
wvals=c(2,3,4,5)
bvals=c(1,2,5,10)
muvals=c(5e-05,5e-04,5e-03,5e-02)

all.params=expand.grid(w=wvals,b=bvals,mu=muvals,dname=names(synIds))

fr=mdply(.data=all.params,.fun=function(w,b,mu,dname){
  
  x=synIds[[dname]]
  
  all.res<-findDrugsWithTargetsAndGenes(eset.file=x$eset.file,
    viper.file=x$viper.file,
    genotype='nf1',
    conditions=list(KOvsWT=list(KO=1,WT=0)),
    w=w,b=b,mu=mu)
  
  
  trackNetworkStats(all.res,esetFileId=x$eset.file,viperFileId=x$viper.file, dsetName=dname)
},.parallel=TRUE)


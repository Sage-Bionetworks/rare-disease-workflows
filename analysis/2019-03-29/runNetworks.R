###networks from proteins


library(PCSF)
library(fendR)
require(tidyverse)
#require(parallel)
library(foreach)
require(doParallel)

runNetworkOnTumorTypes<<-function(w,b,mu,all.genes,prots,combined.graph,all.drugs){

  fname=paste(paste(lubridate::today(),w,b,mu,sep='_'),'.rds',sep='')
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
    steiner <- igraph::V(pcsf.res)$name[which(igraph::V(pcsf.res)$type=='Steiner')]
    prize.res <- igraph::V(pcsf.res)$name[which(igraph::V(pcsf.res)$type=='Terminal')]

    cat(paste("Selected",length(drug.res),'drugs in the graph'))
    ##collect stats, store in synapse table
    list(network=pcsf.res,
      drugs=drug.res,
      terms=prize.res,
      steiners=steiner,
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
trackNetworkStats<<-function(pcsf.res.list,
                             synTableId='syn18483855',
                             viperTableId=viper.table.id,
                             pcsf.parent='syn18482718',
                             plot.parent='syn18483807'){

  #decouple pcsf.res.list into data frame

  fin<-lapply(pcsf.res.list,function(x){
    #first store network
    network=x[['network']]
    w=x[['w']]
    b=x[['b']]
    mu=x[['mu']]
    fname=x[['file']]
    tumor=x[['tumor']]

 #   ds=x[['compoundStats']]%>%dplyr::rename(Drug='Selected Drug',p.value='Drug Wilcoxon P-value')%>%dplyr::mutate('Drug Prize Value'=as.numeric(prize))%>%dplyr::ungroup()

#    ds$`Drug Boxplot`=sapply(ds$figFile,function(y) synStore(File(y,parentId=plot.parent))$properties$id)
    res=synapser::synStore(File(fname,parentId=pcsf.parent),used=viperTableId,executed=this.script)
   print(res$properties)
   # ds=ds%>%dplyr::select(-figFile,-prize)
    #store image file
    upl<-data.frame(tumorType=tumor,w=w,beta=b,mu=mu,
      `Viper Proteins Selected`=paste(sort(x$terms),collapse=','),
      `Viper Table`=viperTableId,
      `Drugs selected`=paste(x$drugs,collapse=','),
      `PCSF Result`=res$properties$id,
      `Num Drugs`=length(x$drugs),
      `Num Terminals`=length(x$terms),
      `Steiner Nodes`=paste(sort(x$steiner),collapse=','),
       `Num Steiner`=length(x$steiner),                   check.names=F)
   print(upl)
    upl2=upl#merge(xxds,upl)

    tres<-synapser::synStore(Table(synTableId,upl2))
  },mc.cores=10)

}
my.prod<-function(w,b,mu){
  return(w*b+mu)
}

require(synapser)
synLogin()
viper.table.id='syn18460033'
synQuery=paste("SELECT * FROM",viper.table.id,"WHERE ( ( padj BETWEEN '8.401022050521E-25' AND '0.00001' ) )")

this.script='https://raw.githubusercontent.com/sgosline/NEXUS/master/analysis/2019-03-29/runNetworks.R'
run<-function(){

                                      # cl=makeCluster(10)
#  registerDoParallel(cl,cores=10)
	viper.prot.tab<<-synTableQuery(synQuery)$asDataFrame()

##Get graphs
  drug.graph <<- fendR::loadDrugGraph()
  combined.graph <<-fendR::buildNetwork(drug.graph)
  all.drugs <<- fendR::getDrugsFromGraph(drug.graph)

  prots<<-lapply(as.character(unique(viper.prot.tab$tumorType)),function(x) {
    res<-subset(viper.prot.tab,tumorType==x)$stat
    names(res)<-subset(viper.prot.tab,tumorType==x)$gene
    res})

  names(prots)<-as.character(unique(viper.prot.tab$tumorType))

  all.genes<<-unique(viper.prot.tab$gene)

  wvals=c(2,3,4,5)
  bvals=c(1,2,5,10,20)
  muvals=c(5e-05,5e-04,5e-03,5e-02)

  all.params=expand.grid(w=wvals,b=bvals,mu=muvals)

  fr=plyr::mdply(.data=all.params,.fun=function(w,b,mu){
    my.prod(w,b,mu)
  #  trackNetworkStats(runNetworkOnTumorTypes(w=w,b=b,mu=mu,
  #    all.genes,prots,combined.graph,all.drugs))
  },.parallel=TRUE)

#stopCluster()

}

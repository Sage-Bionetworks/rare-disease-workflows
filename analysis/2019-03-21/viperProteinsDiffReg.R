#runNF diffex

#require(synapser)
require(synapser)
require(limma)
require(tidyverse)

#get the tidied data with annotations
#synapse <- import("synapseclient")
#syn <- synapse$Synapse()
synLogin()

syn_table='syn18455663'
viper_scores=synTableQuery(paste('select * from',syn_table))$asDataFrame()


this.script='https://raw.githubusercontent.com/sgosline/NEXUS/master/analysis/2019-03-21/viperProteinsDiffReg.R'

####DO WE WANT THIS: remove cell culture!!
viper_scores<-subset(viper_scores,isCellLine%in%c('false','FALSE'))

##add in schwann cells as default
#conts=which(is.na(expData$tumorType))
#levels(expData$tumorType)<-c(levels(expData$tumorType),'Schwann')
#expData$tumorType[conts]<-as.factor(rep('Schwann',length(conts)))

#copied from fendR repo
#
#' \code{getViperForDrug} takes an expression set and a list of drugs and identifies a viper list of proteins that explain differential expression
#' @param drugs is a list of drug names
#' @keywords
#' @export
#' @examples
#' @return viper object
getViperForDiag <- function(v.res,diag,pvalthresh=0.05,useEntrez=FALSE){
  
  #TODO: increase number of permuations! this is too low!!
  inds=which(colnames(v.res)%in%diag)
  sig <-viper::rowTtest(v.res[,inds],v.res[,-inds])$statistic
  pval<-viper::rowTtest(v.res[,inds],v.res[,-inds])$p.value

  ret<-data.frame(gene=rownames(v.res),stat=sig,pvalue=pval,padj=p.adjust(pval))

  if(useEntrez){
    library(org.Hs.eg.db)
    
    #we have to map back to HUGO
    x <- org.Hs.egSYMBOL2EG
    # Get the entrez gene identifiers that are mapped to a gene symbol
    mapped_genes <- AnnotationDbi::mappedkeys(x)
    # Convert to a list
    xx <- AnnotationDbi::as.list(x[mapped_genes])
    inds=match(names(ret),xx)
    names(ret)<-names(xx)[inds]
  }
  
  return(ret)
}


###format expression matrix
#expData<-expData%>%mutate(roundedCounts=round(totalCounts))
combined.mat=reshape2::acast(viper_scores,Symbol~id,value.var="viper",fun.aggregate = mean)

missing=which(apply(combined.mat,1,function(x) any(is.na(x))))
if(length(missing)>0)
  combined.mat=combined.mat[-missing,]

###metadata
vars<-viper_scores%>%dplyr::select(id,Sex,study,isCellLine,tumorType)%>%unique()
vars$isCellLine=tolower(vars$isCellLine)
vars$tumorType<-make.names(vars$tumorType)

#get diffex list for each of the 4 tumor types
df<-dplyr::select(vars,c(study,Sex,tumorType))
rownames(df)<-vars$id

#require(biomaRt)
#mart <- useMart('ensembl',dataset='hsapiens_gene_ensembl')
library(pheatmap)

##build list of all comparisons to be carried out.
comp.list=list(MPNSTvsAll=c('Malignant Peripheral Nerve Sheath Tumor','Massive Soft Tissue Neurofibroma'),
  cNFvsAll=c('Cutaneous Neurofibroma'),
    pNFvsAll=c("Plexiform Neurofibroma",'Neurofibroma'),
    LGGvsAll=c('Low Grade Glioma'),
    HGGvsAll=c('High Grade Glioma'))



#tumorTypes=gsub('.',' ',gsub('tumorType','',unlist(comp.list)),fixed=T)
##create synapse table for today's results.
tableParent='syn16941818' #super secret gene-drug db staging area

full.gex<<-data.frame()
full.pa<<-data.frame()


##loop through all tumor types and comparisons listed above.
lapply(names(comp.list),function(comp){
    #fnames
    prefix=paste(lubridate::today(),comp,sep='')
    
    diag<-unique(viper_scores$id[which(viper_scores$tumorType%in%comp.list[[comp]])])
    res<-data.frame(getViperForDiag(combined.mat,diag),comparison=comp,tumorType=comp.list[[comp]][1])

    #results
    
    #visualize top 20
    top.30=res$gene[order(abs(res$padj),decreasing=F)[1:30]]
    pheatmap(combined.mat[top.30,],annotation_col=df,labels_col=rep("",ncol(combined.mat)),main=paste(comp,'diff ex viper'),filename=paste(prefix,'top30Heatmap.png',sep=''),cellheight=10,cellwith=10)
    #post heatmap to nexus  
    synStore(File(paste(prefix,'top30Heatmap.png',sep=''),parent='syn18459908'),used=syn_table,executed=this.script)
    
    #####GENES
    #post ranked genes to gdb tables place
    full.res=data.frame(diagnosis=as.character(rep('Neurofibromatosis 1',nrow(res))),
      res,      stringsAsFactors=FALSE)

    full.gex<<-rbind(full.gex,full.res)
     #####PATHWAYS
    #get sig diff ex genes

    diffex=res[which(res$padj<0.05),]%>%dplyr::select(gene,stat)
    
    #do kegg enrichment
    entrez_list <- viper_scores%>%dplyr::select(entrez,Symbol)%>%unique()%>%
        rename(Symbol='gene')%>%
        right_join(diffex,by='gene')
    
    eg=entrez_list$stat%>%set_names(entrez_list$entrez)
  
      kk <- clusterProfiler::enrichKEGG(gene = names(sort(abs(eg),decreasing=T)), organism = "hsa", 
      pAdjustMethod = "BH", pvalueCutoff = 0.05, qvalueCutoff = 0.05)
    gg <- clusterProfiler::enrichGO(gene= names(sort(abs(eg),decreasing=T)),OrgDb='org.Hs.eg.db',ont='BP',qvalueCutoff=0.05)
    
    full.path<-summary(kk)%>%dplyr::select(ID,Description,GeneRatio,pvalue,p.adjust,qvalue,geneID)%>%mutate(genelist=paste(sapply(unlist(strsplit(geneID,split='/')),function(x) entrez_list[match(x,entrez_list$entrez),'gene']),collapse=','))%>%dplyr::select(-geneID)
    full.path$Ontology=rep('KEGG',nrow(full.path))
  
    full.go<-summary(gg)%>%dplyr::select(ID,Description,GeneRatio,pvalue,p.adjust,qvalue,geneID)%>%mutate(genelist=paste(sapply(unlist(strsplit(geneID,split='/')),function(x) entrez_list[match(x,entrez_list$entrez),'gene']),collapse=','))%>%dplyr::select(-geneID)
    full.go$Ontology=rep('GO_BP',nrow(full.go))
   
    full.all<-rbind(full.go,full.path)
    
      path.res=data.frame(diagnosis=rep('Neurofibromatosis 1',nrow(full.all)),comp=rep(comp,nrow(full.all)),tumorType=rep(gsub('.',' ',gsub('tumorType','',comp.list[[comp]][1]),fixed=T),nrow(full.all)),full.all,stringsAsFactors=FALSE)

    # qcnetplot(kk, showCategory=10,categorySize = "pvalue", foldChange = 2^eg)
    full.pa<<-rbind(full.pa,path.res)
    #post ranked pathways to gdb pathways 
    
})

#add to gene table
tab<-synStore(synBuildTable(name=paste(lubridate::today(),'Differentially regulated viper proteins'),parent='syn16941818',values=full.gex),activity=Activity(name='differential viper regulation',used=syn_table,executed=this.script))

synStore(synBuildTable(name=paste(lubridate::today(),'pathways from differentially regulated viper proteins'),parent='syn16941818',values=full.pa),activity=Activity(name='differential viper regulation pathways',used=syn_table,executed=this.script))

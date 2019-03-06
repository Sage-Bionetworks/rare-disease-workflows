#runNF diffex

#require(synapser)
require(reticulate)
require(limma)
require(tidyverse)

#get the tidied data with annotations
synapse <- import("synapseclient")
syn <- synapse$Synapse()
syn$login()


syn_file='syn18403945'
expData<-read.csv(gzfile(syn$get(syn_file)$path))%>%subset(Symbol!='')

this.script='https://raw.githubusercontent.com/sgosline/NEXUS/master/analysis/2019-02-28/rnaSeqDiffEx.R'

####DO WE WANT THIS: remove cell culture!!
expData<-subset(expData,isCellLine%in%c('false','FALSE'))

##add in schwann cells as default
conts=which(is.na(expData$tumorType))
levels(expData$tumorType)<-c(levels(expData$tumorType),'Schwann')
expData$tumorType[conts]<-as.factor(rep('Schwann',length(conts)))

###format expression matrix
expData<-expData%>%mutate(roundedCounts=round(totalCounts))
combined.mat=reshape2::acast(expData,Symbol~id,value.var="roundedCounts")
missing=which(apply(combined.mat,1,function(x) any(is.na(x))))
if(length(missing)>0)
  combined.mat=combined.mat[-missing,]

###metadata
vars<-expData%>%dplyr::select(id,Sex,study,isCellLine,tumorType)%>%unique()
vars$isCellLine=tolower(vars$isCellLine)
vars$tumorType<-make.names(vars$tumorType)

##run DESeq2
library(DESeq2)
dds <- DESeqDataSetFromMatrix(countData = combined.mat,
  colData = vars,
  design= ~ 0+tumorType+Sex)

dds <- DESeq(dds)

resultsNames(dds)

#get diffex list for each of the 4 tumor types

df<-dplyr::select(vars,c(study,Sex,tumorType))
rownames(df)<-vars$id

require(biomaRt)
mart <- useMart('ensembl',dataset='hsapiens_gene_ensembl')
library(pheatmap)

##build list of all comparisons to be carried out.
comp.list=list(    MPNSTvsAll=c('tumorTypeMalignant.Peripheral.Nerve.Sheath.Tumor','tumorTypeMassive.Soft.Tissue.Neurofibroma'),
  cNFvsAll=c('tumorTypeCutaneous.Neurofibroma'),
    pNFvsAll=c("tumorTypePlexiform.Neurofibroma",'tumorTypeNeurofibroma'),
    LGGvsAll=c('tumorTypeLow.Grade.Glioma'),
    HGGvsAll=c('tumorTypeHigh.Grade.Glioma'))

tumorTypes=gsub('.',' ',gsub('tumorType','',unlist(comp.list)),fixed=T)
#get all names
all.tt=resultsNames(dds)[grep('tumorType',resultsNames(dds))]

##create synapse table for today's results.
tableParent='syn16941818' #super secret gene-drug db staging area
geneExTable=synapse$Schema(name=paste(lubridate::today(),'oneVsAll gene expression'),
    parent=tableParent,
    cols=c(synapse$Column(name='diagnosis',columnType='STRING',maximumSize=100),
      synapse$Column(name='tumorType',enumValues=tumorTypes,columnType='STRING',maximumSize=100),
      synapse$Column(name='gene',columnType='STRING',maximumSize=100),
      synapse$Column(name='baseMean',columnType='INTEGER'),
        synapse$Column(name='log2FoldChange',columnType='INTEGER'),
        synapse$Column(name='lfcSE',columnType='INTEGER'),
        synapse$Column(name='stat',columnType='INTEGER'),
        synapse$Column(name='pvalue',columnType='INTEGER'),
        synapse$Column(name='padj',columnType='INTEGER'),
        synapse$Column(name='comparison',columnType='STRING',maximumSize=100)
        ))
      
pathwayTable=synapse$Schema(name=paste(lubridate::today(),'oneVsAll pathway enrichment'), 
    parent=tableParent, 
    cols=c( synapse$Column(name='diagnosis',columnType='STRING',maximumSize=100),
      synapse$Column(name='comp',columnType='STRING',maximumSize=100),
      synapse$Column(name='tumorType',enumValues=tumorTypes,columnType='STRING',maximumSize=100),
      synapse$Column(name='ID',columnType='STRING',maximumSize=10),
          synapse$Column(name='Description',columnType='STRING',maximumSize=100),
        synapse$Column(name='GeneRatio',columnType='STRING',maximumSize=10),
        synapse$Column(name='pvalue',columnType='INTEGER'),
        synapse$Column(name='p.adjust',columnType='INTEGER'),
        synapse$Column(name='qvalue',columnType='INTEGER'),
      synapse$Column(name='genelist',columnType='LARGETEXT')
   ))

full.gex<<-data.frame()
full.pa<<-data.frame()


##loop through all tumor types and comparisons listed above.
lapply(names(comp.list),function(comp){
    #fnames
    prefix=paste(lubridate::today(),comp,sep='')
  
    #results
    sampls=unlist(comp.list[[comp]])
    res=results(dds,
        contrast=list(sampls,setdiff(all.tt,sampls)),
        listValues=c(1/length(sampls),-1/length(setdiff(all.tt,sampls))))
    
    #visualize top 20
    top.30=order(abs(res$padj),decreasing=F)[1:30]
    pheatmap(log2(assay(dds)[top.30,]+1),annotation_col=df,labels_col=rep("",ncol(assay(dds))),main=paste(comp,'diff ex genes'),filename=paste(prefix,'top30Heatmap.png',sep=''),cellheight=10,cellwith=10)
    #post heatmap to nexus  
    syn$store(synapse$File(paste(prefix,'top30Heatmap.png',sep=''),parent='syn18380760'),used=syn_file,executed=this.script)
    
    #####GENES
    #post ranked genes to gdb tables place
    full.res=data.frame(diagnosis=as.character(rep('Neurofibromatosis 1',nrow(res))),
      tumorType=as.character(rep(gsub('.',' ',gsub('tumorType','',comp.list[[comp]][1]),fixed=T)),nrow(res)),
      comparison=as.character(rep(comp,nrow(res))),
      gene=as.character(rownames(res)),
      apply(res,2,as.numeric),
      stringsAsFactors=FALSE)

    full.gex<<-rbind(full.gex,full.res)
     #####PATHWAYS
    #get sig diff ex genes

    diffex=full.res[which(full.res$padj<0.01),]%>%dplyr::select(gene,log2FoldChange)
    
    #do kegg enrichment
    entrez_list <- getBM(filters = "hgnc_symbol", 
      attributes = c("hgnc_symbol", "entrezgene"), 
      values = diffex$gene, mart = mart)%>%
        rename(hgnc_symbol='gene')%>%
        left_join(diffex,by='gene')
    
    eg=entrez_list$log2FoldChange%>%set_names(entrez_list$entrezgene)
    kk <- clusterProfiler::enrichKEGG(gene = names(sort(abs(eg),decreasing=T)), organism = "hsa", 
      pAdjustMethod = "BH", pvalueCutoff = 0.05, qvalueCutoff = 0.1)
    full.path<-summary(kk)%>%dplyr::select(ID,Description,GeneRatio,pvalue,p.adjust,qvalue,geneID)%>%mutate(genelist=paste(sapply(unlist(strsplit(geneID,split='/')),function(x) entrez_list[match(x,entrez_list$entrezgene),'gene']),collapse=','))%>%dplyr::select(-geneID)
  
      path.res=data.frame(diagnosis=rep('Neurofibromatosis 1',nrow(kk)),comp=rep(comp,nrow(kk)),tumorType=rep(gsub('.',' ',gsub('tumorType','',comp.list[[comp]][1]),fixed=T),nrow(kk)),full.path,stringsAsFactors=FALSE)

    # qcnetplot(kk, showCategory=10,categorySize = "pvalue", foldChange = 2^eg)
    full.pa<<-rbind(full.pa,path.res)
    #post ranked pathways to gdb pathways 
    
})
#add to gene table
tab<-syn$store(synapse$Table(geneExTable,full.gex),activity=synapse$Activity(name='differential expression',used=syn_file,executed=this.script))
syn$store(synapse$Table(pathwayTable,full.pa),activity=synapse$Activity(name='pathway enrichment '),used=syn_file,executed=this.script)



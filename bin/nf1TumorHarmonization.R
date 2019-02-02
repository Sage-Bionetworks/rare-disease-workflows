##nf tumor harmonization

#goal of this file is to harmonize patient samples across 3 projects


require(tidyverse)

#
# plot metadata to display variety of samples#
#
plotMetadata<-function(fv.tab,prefix){
  tab.with.meta<-fv.tab%>%dplyr::select(c('id','specimenID','species','age','sex','tumorType','isCellLine','study','diagnosis'))%>%mutate(Sex=tolower(sex))%>%mutate(cellCulture=tolower(isCellLine))

  ##first plot: just summary of data by sex
  ggplot(tab.with.meta)+geom_bar(aes(x=Sex,fill=tumorType),position='dodge')+ggtitle('NF1 RNA-seq samples')
  ggsave(paste(prefix,'metadataSummary.png',sep=''))
  tab.with.meta
}

#
# how does my gene of interest change across variables?
#
analyzeMetdataWithGenes<-function(full.tab,tab.with.meta,prefix){

  genes.with.meta<-tab.with.meta%>%left_join(dplyr::rename(full.tab,id=synId))%>%unique



 
  ##EVALUATE NORMALIZED MATRIX
# #look at some marker genes
  ggplot(subset(genes.with.meta,Symbol%in%c('NF1','S100B','ATRX','NF2','SMARCB1','APOD','KRT10')))+geom_jitter(aes(x=Symbol,y=zScore,shape=study,col=tumorType))+ggtitle('Selected gene counts')
  ggsave(paste(prefix,'genesByStudyTumor.png',sep=''))
  
#  ggplot(subset(genes.with.meta,Symbol%in%c('NF1','APOD','ATRX','NF2','S100B','SMARCB1','KRT10')))+geom_jitter(aes(x=Symbol,y=zScore,col=tumorType))+ggtitle('Selected gene counts')
#  ggsave(paste(prefix,'genesByTumor.png',sep=''))
  
  genes.with.meta
}

doPcaPlots<-function(full.tab,tab.with.meta,prefix){

  rownames(tab.with.meta)<-tab.with.meta$id
  
  #create matrix
  combined.mat=reshape2::acast(full.tab,Symbol~synId,value.var="zScore")

    #then remove missing
  missing=which(apply(combined.mat,1,function(x) any(is.na(x))))
  combined.mat=combined.mat[-missing,]
  
  ###PCA ANALYSIS
  library(ggfortify)
  autoplot(prcomp(t(combined.mat)),data=tab.with.meta,shape='study',col='tumorType')
  ggsave(paste(prefix,'PCA.png',sep=''),width=10)
  loads=prcomp(combined.mat)$x

  genes1=rownames(combined.mat)[rev(order(loads[,1]))[1:25]]

  genes.with.meta<-tab.with.meta%>%left_join(dplyr::rename(full.tab,id=synId))%>%unique

  #now take those loadings from pc1
  ggplot(subset(genes.with.meta,Symbol%in%genes1[1:10]))+geom_jitter(aes(x=Symbol,y=zScore,col=tumorType,shape=study))+ggtitle('Selected gene counts from PC1')
  ggsave(paste(prefix,'pc1_gene_loadings.png',sep=''),width=10)
  
  genes2=rownames(combined.mat)[rev(order(loads[,2]))[1:25]]

  #now take those loadings from pc1
  ggplot(subset(genes.with.meta,Symbol%in%genes2[1:10]))+geom_jitter(aes(x=Symbol,y=zScore,col=tumorType,shape=study))+ggtitle('Selected gene counts from PC2')
  ggsave(paste(prefix,'pc2_gene_loadings.png',sep=''),width=10)
  
##now maybe do some gsea?

##now plot in heatmap
  genes3=rownames(combined.mat)[rev(order(loads[,3]))[1:25]]
  
  ggplot(subset(genes.with.meta,Symbol%in%genes3[1:10]))+geom_jitter(aes(x=Symbol,y=zScore,col=tumorType,shape=study))+ggtitle('Selected gene counts from PC3')
  ggsave(paste(prefix,'pc3_gene_loadings.png',sep=''),width=10)
  library(pheatmap)
  pheatmap(combined.mat[union(genes1,union(genes2,genes3)),],annotation_col = dplyr::select(tab.with.meta,c(Sex,study,cellCulture,tumorType,age,diagnosis)),labels_col=rep("",ncol(combined.mat)),fontsize_row = 8,clustering_method = 'ward.D2',file=paste(prefix,'top25pcs3heatmap.png',sep=''))

   # ggsave(paste(prefix,'top25pcs3heatmap.png',sep=''))
  
  files=paste(prefix,c('top25pcs3heatmap.png','pc2_gene_loadings.png','pc1_gene_loadings.png','pc3_gene_loadings.png'),sep='')
  files
  
}


singleGeneBoxplot<-function(genes.with.meta,gene='NF1'){
  ggplot(subset(genes.with.meta,Symbol==gene))+geom_boxplot(aes(x=study,y=zScore,fill=tumorType))+coord_flip()+ggtitle(paste(gene,'expression'))
  
}

runGSVA<-function(genes.with.meta){

  ###now do gsva
  library(GSVA)
  library(GSVAdata)
  mat<-reshape2::acast(genes.with.meta,Symbol~id,value.var='zScore')
  missing<-which(apply(mat,1,function(x) any(is.na(x))))
  mat<-mat[-missing,]
  data("c2BroadSets")
  
  library(biomaRt)
  #get mapping from enst to hgnc
  mart = useMart("ensembl", dataset="hsapiens_gene_ensembl")
  my_chr <- c(1:22,'X','Y')
  map <- getBM(attributes=c("entrezgene","hgnc_symbol"),mart=mart,filters='chromosome_name',values=my_chr)
  
  entrez<-map[match(rownames(mat),map[,2]),1]
  mat<-mat[which(!is.na(entrez)),]
  rownames(mat)<-entrez[!is.na(entrez)]
  res=gsva(mat,method='ssgsea',gset.idx.list=c2BroadSets)
  library(pheatmap)
  vars<-apply(res,1,var)
 annotes=genes.with.meta%>%dplyr::select(id,age,Sex,tumorType,cellCulture,study)%>%unique
 rownames(annotes)<-annotes$id
 
  pheatmap(res[names(sort(vars)[1:50]),],labels_col=rep("",ncol(res)),fontsize_row = 8,clustering_method = 'ward.D2',annotation_col = dplyr::select(annotes,-id))
  
  res
}

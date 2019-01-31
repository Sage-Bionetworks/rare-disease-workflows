##nf tumor harmonization

#goal of this file is to harmonize patient samples across 3 projects


require(tidyverse)

#
# plot metadata to display variety of samples#
#
plotMetadata<-function(fv.tab,prefix){
  tab.with.meta<-fv.tab%>%dplyr::select(c('id','specimenID','species','age','sex','tumorType','isCellLine','study'))%>%mutate(Sex=tolower(sex))%>%mutate(cellCulture=tolower(isCellLine))

  ##first plot: just summary of data by sex
  ggplot(tab.with.meta)+geom_bar(aes(x=Sex,fill=tumorType))+ggtitle('NF1 RNA-seq samples')
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
  ggplot(subset(genes.with.meta,Symbol%in%c('NF1','APOD','GFAP','EEF1A','S100B','CD74','KRT10')))+geom_jitter(aes(x=Symbol,y=zScore,col=study))+ggtitle('Selected gene counts')
  ggsave(paste(prefix,'genesByStudy.png',sep=''))
  

  ggplot(subset(genes.with.meta,Symbol%in%c('NF1','APOD','GFAP','EEF1A','S100B','CD74','KRT10')))+geom_jitter(aes(x=Symbol,y=zScore,col=tumorType))+ggtitle('Selected gene counts')
  ggsave(paste(prefix,'genesByTumor.png',sep=''))
  
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
  ggsave(paste(prefix,'PCA.png',sep=''))
  loads=prcomp(combined.mat)$x

  genes1=rownames(combined.mat)[rev(order(loads[,1]))[1:25]]

  genes.with.meta<-tab.with.meta%>%left_join(dplyr::rename(full.tab,id=synId))%>%unique

  #now take those loadings from pc1
  ggplot(subset(genes.with.meta,Symbol%in%genes1[1:10]))+geom_jitter(aes(x=Symbol,y=zScore,col=tumorType))+ggtitle('Selected gene counts from PC1')
  ggsave(paste(prefix,'pc1_gene_loadings.png',sep=''))
  
  genes2=rownames(combined.mat)[rev(order(loads[,2]))[1:25]]

  #now take those loadings from pc1
  ggplot(subset(genes.with.meta,Symbol%in%genes2[1:10]))+geom_jitter(aes(x=Symbol,y=zScore,col=tumorType))+ggtitle('Selected gene counts from PC2')
  ggsave(paste(prefix,'pc2_gene_loadings.png',sep=''))
  
##now maybe do some gsea?

##now plot in heatmap
  genes3=rownames(combined.mat)[rev(order(loads[,3]))[1:25]]

  library(pheatmap)
  pheatmap(combined.mat[union(genes1,union(genes2,genes3)),],annotation_col = dplyr::select(tab.with.meta,c(Sex,study,cellCulture,tumorType,age)),labels_col=rep("",ncol(combined.mat)),fontsize_row = 8,clustering_method = 'ward.D2',file=paste(prefix,'top25pcs3heatmap.png',sep=''))
 # ggsave(paste(prefix,'top25pcs3heatmap.png',sep=''))
  
  files=paste(prefix,c('top25pcs3heatmap.png','pc2_gene_loadings.png','pc1_gene_loadings.png'),sep='')
  files
  
}

###now do gsva
#library(GSVA)
#library(GSVAdata)
#gsva(zscored,method='ssgsea',gset.idx.list=)


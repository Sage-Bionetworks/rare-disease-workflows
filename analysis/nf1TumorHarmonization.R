##nf tumor harmonization

#goal of this file is to harmonize patient samples across 3 projects

library(synapser)
#library(tidyverse)

synLogin()
require(tidyverse)


##create each query separately for now :-/
##biobank returns sf files
biobank=synTableQuery("SELECT id,specimenID,species,sex,age,tumorType,isCellLine,study  FROM syn13363852 WHERE ( ( \"assay\" = 'rnaSeq' ) AND ( \"fileFormat\" = 'sf' ) )")$asDataFrame()

#this gets the gzipped counts files
gliomanf1=synTableQuery("SELECT id,specimenID,species,sex,age,tumorType,isCellLine,study FROM syn11614207 WHERE ( ( \"assay\" = 'rnaSeq' ) )")$asDataFrame()

#cNF data
cnf=synTableQuery('SELECT id,specimenID,species,sex,age,tumorType,isCellLine,study FROM syn9702734 WHERE ( ( "parentId" = \'syn5493036\' ) AND ( "assay" = \'rnaSeq\' ) AND ( "individualID" IS NOT NULL ) )')$asDataFrame()

full.metadata<-rbind(
    dplyr::select(biobank,c(id,age,sex,tumorType,isCellLine,study)),
    dplyr::select(gliomanf1,c(id,age,sex,tumorType,isCellLine,study)),
    dplyr::select(cnf,c(id,age,sex,tumorType,isCellLine,study))
)%>%mutate(Sex=tolower(sex))

rownames(full.metadata)<-full.metadata$id

tab.with.meta<-rbind(biobank,gliomanf1,cnf)%>%dplyr::select(c('id','specimenID','species','age','sex','tumorType','isCellLine','study'))%>%mutate(Sex=tolower(sex))%>%mutate(cellCulture=tolower(isCellLine))

##first plot: just summary of data by sex
ggplot(tab.with.meta)+geom_bar(aes(x=Sex,fill=tumorType))+ggtitle('NF1 RNA-seq samples')


#####NOW DOWNLOAD COUNTS
library(biomaRt)
#get mapping from enst to hgnc
mart = useMart("ensembl", dataset="hsapiens_gene_ensembl")
my_chr <- c(1:22,'X','Y')
map <- getBM(attributes=c("ensembl_transcript_id","hgnc_symbol"),mart=mart,filters='chromosome_name',values=my_chr)

##MPNST Biobank
bio.genes=do.call('rbind',lapply(biobank$id,function(x){
  f=synGet(x)$path
  tab<-read.table(f,header=T,sep='\t')%>%separate(Name,into=c('ensembl_transcript_id',NA))%>%inner_join(map,by='ensembl_transcript_id')%>%group_by(hgnc_symbol)%>%summarize(totalCounts=sum(NumReads))
  data.frame(dplyr::select(tab,'totalCounts',Symbol='hgnc_symbol'),synId=rep(x,nrow(tab)
    ))
}))

###COlumbia Glioma
gli.genes=do.call('rbind',lapply(gliomanf1$id,function(x){
  f=synGet(x)$path
  tab<-read.table(gzfile(f),header=F)
  colnames(tab)<-c('ensemble','Symbol','Counts')
  tab<-tab%>%group_by(Symbol)%>%summarize(totalCounts=sum(Counts))
  
  data.frame(tab,synId=rep(x,nrow(tab)))
}))


###cNF data
cnf.genes=do.call('rbind',lapply(cnf$id,function(x){
  f=synGet(x)$path
  tab<-read.table(f,header=T)
  names(tab)<-c('Counts','Symbol')
  tab<-tab%>%group_by(Symbol)%>%summarize(totalCounts=sum(Counts))
  data.frame(tab,synId=rep(x,nrow(tab)))   
}))

##now merge them into matrix and normalize
full.tab<-rbind(cnf.genes,gli.genes,bio.genes)
 # cbind(cnf.genes,dataset=rep('cNF',nrow(cnf.genes))),
#  cbind(gli.genes,dataset=rep('glioma',nrow(gli.genes))),
#  cbind(bio.genes,dataset=rep('biobank',nrow(bio.genes))))

genes.with.meta<-tab.with.meta%>%left_join(dplyr::rename(full.tab,id=synId))%>%unique

rownames(tab.with.meta)<-tab.with.meta$id

#create matrix
combined.mat=reshape2::acast(full.tab,Symbol~synId,value.var="totalCounts")
#first z score
zscored.mat=apply(combined.mat,2,function(x) (x-mean(x,na.rm=T))/sd(x,na.rm=T))
#then remove missing
missing=which(apply(zscored.mat,1,function(x) any(is.na(x))))
highs=c()
#highs=which(apply(zscored,1,function(x) any(x>10)))

zscored.mat=zscored.mat[-union(missing,highs),]

##EVALUATE NORMALIZED MATRIX
##look at some marker genes
ggplot(subset(genes.with.meta,Symbol%in%c('NF1','APOD','GFAP','EEF1A','S100B','CD74','KRT10')))+geom_jitter(aes(x=Symbol,y=totalCounts,col=study))+scale_y_log10()+ggtitle('Selected gene counts')


ggplot(subset(genes.with.meta,Symbol%in%c('NF1','APOD','GFAP','EEF1A','S100B','CD74','KRT10')))+geom_jitter(aes(x=Symbol,y=totalCounts,col=tumorType))+scale_y_log10()+ggtitle('Selected gene counts')


###PCA ANALYSIS
library(ggfortify)
autoplot(prcomp(t(zscored.mat)),data=tab.with.meta,shape='study',col='tumorType')
loads=prcomp(zscored.mat)$x

genes1=rownames(zscored.mat)[rev(order(loads[,1]))[1:25]]

#now take those loadings from pc1
ggplot(subset(genes.with.meta,Symbol%in%genes1[1:10]))+geom_jitter(aes(x=Symbol,y=totalCounts,col=tumorType))+scale_y_log10()+ggtitle('Selected gene counts from PC1')

genes2=rownames(zscored.mat)[rev(order(loads[,2]))[1:25]]

#now take those loadings from pc1
ggplot(subset(genes.with.meta,Symbol%in%genes2[1:10]))+geom_jitter(aes(x=Symbol,y=totalCounts,col=tumorType))+scale_y_log10()+ggtitle('Selected gene counts from PC2')
##now maybe do some gsea?

##now plot in heatmap
genes3=rownames(zscored.mat)[rev(order(loads[,3]))[1:25]]

library(pheatmap)
pheatmap(zscored.mat[union(genes1,union(genes2,genes3)),],annotation_col = dplyr::select(tab.with.meta,c(Sex,study,cellCulture,tumorType,age)),labels_col=rep("",ncol(zscored.mat)),fontsize_row = 8,clustering_method = 'ward.D2')+ggtitle('ploting of top 25 genes from first three PCs')


ggplot(subset(genes.with.meta,Symbol=='GFAP'))+geom_point(aes(x=age,y=totalCounts,col=tumorType))+ggtitle('GFAP expression by age')


###now do gsva
library(GSVA)
library(GSVAdata)
#gsva(zscored,method='ssgsea',gset.idx.list=)


library(synapser)
#library(tidyverse)

synLogin()

source("../../bin/nf1TumorHarmonization.R")

prefix=paste(lubridate::today(),'bioBank_glioma_cNF',sep='-')

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

fv.tab<-rbind(biobank,gliomanf1,cnf)

tab.with.metadata<-plotMetadata(fv.tab,prefix)

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

##here is the gene table
full.tab<-rbind(cnf.genes,gli.genes,bio.genes)

#now z score it
with.z=full.tab%>%group_by(synId)%>%mutate(zScore=(totalCounts-mean(totalCounts+0.001,na.rm=T))/sd(totalCounts,na.rm=T))

########now call basic metadata plots
genes.with.meta=analyzeMetdataWithGenes(with.z,tab.with.metadata,prefix)
met.file=paste(prefix,'metadataSummary.png',sep='')
dataset.dir='syn18134640'


###now the pca
pc.files=doPcaPlots(with.z,tab.with.metadata,prefix)

###now upload data to appropriate places with provenance. 

pca.dir='syn18134640'

#ggplot(subset(genes.with.meta,Symbol=='GFAP'))+geom_point(aes(x=age,y=zScore,col=tumorType))+ggtitle('GFAP expression by age')

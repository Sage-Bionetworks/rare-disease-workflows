library(synapser)
#library(tidyverse)

synLogin()

source("../../bin/nf1TumorHarmonization.R")

prefix=paste(lubridate::today(),'coding_only_bioBank_glioma_cNF_pnf',sep='-')

##create each query separately for now :-/
##biobank returns sf files
biobank=synTableQuery("SELECT id,specimenID,species,sex,age,tumorType,isCellLine,study,diagnosis  FROM syn13363852 WHERE ( ( \"assay\" = 'rnaSeq' ) AND ( \"fileFormat\" = 'sf' ) )")$asDataFrame()

#this gets the gzipped counts files
gliomanf1=synTableQuery("SELECT id,specimenID,species,sex,age,tumorType,isCellLine,study,diagnosis FROM syn11614207 WHERE ( ( \"assay\" = 'rnaSeq' ) )")$asDataFrame()

#cNF data
cnf=synTableQuery('SELECT id,specimenID,species,sex,age,tumorType,isCellLine,study,diagnosis FROM syn9702734 WHERE ( ( "parentId" = \'syn18407530\' ) AND ( "assay" = \'rnaSeq\' ) AND ( "individualID" IS NOT NULL ) )')$asDataFrame()

##pNFCell culture
pnf=synTableQuery('SELECT id,specimenID,species,sex,age,tumorType,isCellLine,study,diagnosis FROM syn8518944 WHERE ( ( "assay" = \'rnaSeq\' ) ) and fileFormat=\'tsv\' and isMultiSpecimen is NULL and name like \'%gencode%\'')$asDataFrame()

full.metadata<-rbind(
  dplyr::select(biobank,c(id,age,sex,tumorType,isCellLine,study,diagnosis)),
  dplyr::select(gliomanf1,c(id,age,sex,tumorType,isCellLine,study,diagnosis)),
  dplyr::select(cnf,c(id,age,sex,tumorType,isCellLine,study,diagnosis)),
  dplyr::select(pnf,c(id,age,sex,tumorType,isCellLine,study,diagnosis))
)%>%mutate(Sex=tolower(sex))

rownames(full.metadata)<-full.metadata$id

fv.tab<-rbind(biobank,gliomanf1,cnf,pnf)

tab.with.metadata<-plotMetadata(fv.tab,prefix)

##now get all genes
path=synGet('syn18134565')$path
R.utils::gunzip(path,overwrite=T)
system(paste("grep protein_coding",gsub(".gz","",path),"|cut -d '|' -f 1 |uniq > gencode.v29.transcripts.txt"))

#now parse the headers
genes=apply(read.table('gencode.v29.transcripts.txt'),1,function(x) gsub('>','',unlist(strsplit(x,split='.',fixed=T))[1]))

#full.tab<-subset(full.tab,Symbol%in%genes[,1])

#####NOW DOWNLOAD COUNTS
library(biomaRt)
#get mapping from enst to hgnc
mart = useMart("ensembl", dataset="hsapiens_gene_ensembl")
my_chr <- c(1:22,'X','Y')
map <- getBM(attributes=c("ensembl_transcript_id","hgnc_symbol"),mart=mart,filters='chromosome_name',values=my_chr)

##MPNST Biobank
bio.genes=do.call('rbind',lapply(biobank$id,function(x){
  f=synGet(x)$path
  tab<-read.table(f,header=T,sep='\t')%>%separate(Name,into=c('ensembl_transcript_id',NA))%>%inner_join(map,by='ensembl_transcript_id')%>%subset(ensembl_transcript_id%in%genes)%>%group_by(hgnc_symbol)%>%summarize(totalCounts=sum(NumReads))
  data.frame(dplyr::select(tab,'totalCounts',Symbol='hgnc_symbol'),synId=rep(x,nrow(tab)
  ))
}))

###COlumbia Glioma
gli.genes=do.call('rbind',lapply(gliomanf1$id,function(x){
  f=synGet(x)$path
  tab<-read.table(gzfile(f),header=F)
  colnames(tab)<-c('ensembl','Symbol','Counts')
  tab<-tab%>%group_by(Symbol)%>%summarize(totalCounts=sum(Counts))

  data.frame(tab,synId=rep(x,nrow(tab)))
}))


###cNF data
cnf.genes=do.call('rbind',lapply(cnf$id,function(x){
  f=synGet(x)$path
  tab<-read.table(f,header=T,sep='\t')%>%separate(Name,into=c('ensembl_transcript_id',NA))%>%inner_join(map,by='ensembl_transcript_id')%>%subset(ensembl_transcript_id%in%genes)%>%group_by(hgnc_symbol)%>%summarize(totalCounts=sum(NumReads))
  data.frame(dplyr::select(tab,'totalCounts',Symbol='hgnc_symbol'),synId=rep(x,nrow(tab)
  ))

  #  tab<-read.table(f,header=T)
#  names(tab)<-c('Counts','Symbol')
#  tab<-tab%>%group_by(Symbol)%>%summarize(totalCounts=sum(Counts))
#  data.frame(tab,synId=rep(x,nrow(tab)))
}))

#pNF cell culture
pnf.genes<-do.call('rbind',lapply(pnf$id,function(x){
  f=synGet(x)$path
  tab<-read.table(f,header=T)%>%dplyr::select(Symbol='HugoSymbol',Counts='est_counts',tpm)
  tab<-tab%>%group_by(Symbol)%>%summarize(totalCounts=sum(Counts))
  data.frame(tab,synId=rep(x,nrow(tab)))
}))


##here is the gene table
full.tab<-rbind(cnf.genes,gli.genes,bio.genes,pnf.genes)



#now z score it
with.z=full.tab%>%group_by(synId)%>%mutate(zScore=(totalCounts-mean(totalCounts+0.001,na.rm=T))/sd(totalCounts,na.rm=T))


######RUN ANALYSIS AND STORE ON SYNAPSE
this.script='https://raw.githubusercontent.com/sgosline/NEXUS/master/analysis/2019-03-13/refilterForCodingGenes.R'
analysis.script='https://raw.githubusercontent.com/sgosline/NEXUS/master/bin/nf1TumorHarmonization.R'

########now call basic metadata plots
genes.with.meta=analyzeMetdataWithGenes(with.z,tab.with.metadata,prefix)
met.file=paste(prefix,'metadataSummary.png',sep='\\')

dataset.dir='syn18134640'

gz1=gzfile(paste(prefix,'tidiedData.csv.gz',sep=''))
write.csv(genes.with.meta,gz1)

sid=synStore(File(paste(prefix,'tidiedData.csv.gz',sep=''),parent=dataset.dir),used=unique(genes.with.meta$id),executed=c(this.script,analysis.script))

sapply(paste(prefix,c('genesByStudyTumor.png','metadataSummary.png'),sep=''),function(x) synStore(File(x,parent=dataset.dir),used=sid$properties$id,executed=c(this.script,analysis.script)))


###now the pca
pc.files=doPcaPlots(with.z,tab.with.metadata,prefix)

###now upload data to appropriate places with provenance.

pca.dir='syn18134641'
sapply(pc.files,function(x) synStore(File(x,parent=pca.dir),used=sid$properties$id,executed=c(this.script,analysis.script)))

#ggplot(subset(genes.with.meta,Symbol=='GFAP'))+geom_point(aes(x=age,y=zScore,col=tumorType))+ggtitle('GFAP expression by age')

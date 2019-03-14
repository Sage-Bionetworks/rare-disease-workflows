
library(reticulate)
synapse <- import("synapseclient")
syn <- synapse$Synapse()
syn$login()

require(tidyverse)
syn_file='syn18408380'
expData<-read.csv(gzfile(syn$get(syn_file)$path))%>%subset(Symbol!='')

#require(singleCellSeq)
#analysis_dir='syn11398941'

#call the heatmap rmd
rmd<-system.file('heatmap_vis.Rmd',package='singleCellSeq')

this.code='https://raw.githubusercontent.com/sgosline/NEXUS/master/analysis/2019-03-08/panNF_immune_sigs.R'
#rownames(expData)<-expData$id

#create matrix
combined.mat=reshape2::acast(expData,Symbol~id,value.var="zScore")
missing=which(apply(combined.mat,1,function(x) any(is.na(x))))
combined.mat=combined.mat[-missing,]

#create phenData
phenData<-expData%>%dplyr::select(id,age,Sex,tumorType,isCellLine,study)%>%unique()

rownames(phenData)<-phenData$id
phenData$isCellLine<-tolower(phenData$isCellLine)


gene.lists<-c('mcpcounter','cibersort','LyonsEtAl','Wallet','SchelkerEtAl')
#require(pheatmap)
suppressMessages(library(GSVA))


##get gene lists
tab=syn$tableQuery('select * from syn12211688')$asDataFrame()%>%dplyr::select(Gene=`Gene Name`,Cell=`Cell Type`,Source,Operator)
tab.list<-lapply(split(tab,tab$Source),function(x) lapply(split(x,x$Cell),function(y) y$Gene))



immune.tab<-NULL

for(gl in gene.lists){
  g.list<-tab.list[[gl]]
  # g.list<-lapply(cell.annotations%>%split(.$Cell),function(x) x$Gene)
  g.res<-as.data.frame(gsva(as.matrix(combined.mat),g.list,method='ssgsea',rnaseq=seqData,verbose=FALSE))
  g.res$cellType=rownames(g.res)
  gg=g.res%>%gather('id','ssGSEA',-cellType)%>%left_join(phenData,by='id')
  gg$geneList=rep(gl,nrow(gg))
  gg$Sex=as.character(gg$Sex)
  gg$study<-as.character(gg$study)
  gg$tumorType<-as.character(gg$tumorType)
  immune.tab<-rbind(immune.tab,data.frame(gg,stringsAsFactors=FALSE))
}

kf<-rmarkdown::render(rmd,rmarkdown::html_document(),output_file=paste(getwd(),'/',lubridate::today(),'panNFHeatmap.html',sep=''),params=list(samp.mat=combined.mat,cell.annotations=phenData%>%dplyr::select(-id),seqData=TRUE))

analysis_dir='syn18134642'
syn$store(synapse$File(kf,parentId=analysis_dir),used=syn_file,executed=this.code)

##now add table
tableParent='syn16941818' #super secret gene-drug db staging area
gseaTab=synapse$Schema(name=paste(lubridate::today(),'ssGSEA of cell types'),
  parent=tableParent,
  cols=c(synapse$Column(name='cellType',columnType='STRING',maximumSize=100),
    synapse$Column(name='id',columnType='ENTITY'),
    synapse$Column(name='ssGSEA',columnType='INTEGER'),
    synapse$Column(name='age',columnType='INTEGER'),
    synapse$Column(name='Sex',columnType='STRING'),
    synapse$Column(name='tumorType',columnType='STRING'),
    synapse$Column(name='isCellLine',columnType='STRING'),
    synapse$Column(name='geneList',columnType='STRING'),
    synapse$Column(name='study',columnType='STRING')))

tab<-syn$store(synapse$Table(gseaTab,immune.tab),activity=synapse$Activity(name='ssGSEA expression',used=syn_file,executed=this.script))


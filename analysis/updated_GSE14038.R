
library(reticulate)
synapse <- import("synapseclient")
syn <- synapse$Synapse()
syn$login()

require(tidyverse)
syn_file='syn5950004'
expData<-read.table(syn$get(syn_file)$path,sep='\t')
phenData<-read.table(syn$get('syn5950620')$path,sep='\t',header=T)
rownames(phenData)<-phenData$geo_accession
phenData<-phenData%>%select(-geo_accession)%>%subset(cellType!='reference')
expData<-expData[,intersect(colnames(expData),rownames(phenData))]
#get rid of all cells that only include phenotype

require(singleCellSeq)
analysis_dir='syn5908068'

#call the heatmap rmd
rmd<-system.file('heatmap_vis.Rmd',package='singleCellSeq')

kf<-rmarkdown::render(rmd,rmarkdown::html_document(),output_file=paste(getwd(),'/panNFHeatmap.html',sep=''),params=list(samp.mat=expData,cell.annotations=phenData,seqData=FALSE))

syn$store(synapse$File(kf,parentId=analysis_dir),used=syn_file)

##now get cutaneous matrix

cut.tab<-read.table(syn$get('syn5051784')$path)
annotes<-syn$tableQuery("SELECT sampleIdentifier,Patient,TumorLocation,RNASeq FROM syn5556216 where usedforRNA=TRUE")$asDataFrame()%>%select(sampleIdentifier,Patient,TumorLocation,RNASeq)

rownames(cut.tab)<-annotes$sampleIdentifier[match(rownames(cut.tab),annotes$RNASeq)]
rownames(annotes)<-annotes$sampleIdentifier
annotes<-annotes%>%select(Patient,TumorLocation)

kf<-rmarkdown::render(rmd,rmarkdown::html_document(),output_file=paste(getwd(),'/cutNFHeatmap.html',sep=''),params=list(samp.mat=t(cut.tab),cell.annotations=annotes[rownames(cut.tab),],seqData=FALSE))

syn$store(synapse$File(kf,parentId=analysis_dir),used=c('syn5051784','syn5556216'))



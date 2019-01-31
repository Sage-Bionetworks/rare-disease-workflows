
library(reticulate)
synapse <- import("synapseclient")
syn <- synapse$Synapse()
syn$login()

require(tidyverse)
syn_file='syn5950004'
expData<-read.table(syn$get(syn_file)$path,sep='\t')
phenData<-read.table(syn$get('syn5950620',version=1)$path,sep='\t',header=T)
phenData$cellName <- sapply(phenData$cellType,function(x){
  if(x%in%c('dNF','dNFSC --'))
    return('cutaneousNF')
  else if(x%in%c('MPNST','MPNST cell'))
    return('MPNST')
  else if(x%in%c('pNF','pNFSC'))
    return('plexiformNF')
  else if(x=='dNFSC +-')
    return("cutaneousHet")
  else if(x=='NHSC')
    return('Schwann')
  else
    return('reference')
})

rownames(phenData)<-phenData$geo_accession
phenData<-phenData%>%select(-geo_accession)%>%subset(cellType!='reference')%>%select(sourceType,cellName)
expData<-expData[,intersect(colnames(expData),rownames(phenData))]
#get rid of all cells that only include phenotype

require(singleCellSeq)
analysis_dir='syn11398941'

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
annotes<-data.frame(apply(annotes,2,function(x) as.factor(unlist(x))))
annotes$TumorLocation<-sapply(as.character(annotes$TumorLocation),function(x){
  if(x%in%c("R chest"))
    return("Chest")
  else if(x%in%c('Lat abdomen','Ant torso'))
    return("Trunk")
  else if(x%in%c('R arm'))
    return('Arm')
  else if(x%in%c('Upper back','Lower back'))
    return('Back')
  else if(x=='NaN')
    return('Unknown')
  else
    return(x)
})


kf<-rmarkdown::render(rmd,rmarkdown::html_document(),output_file=paste(getwd(),'/cutNFHeatmap.html',sep=''),params=list(samp.mat=t(cut.tab),cell.annotations=annotes[rownames(cut.tab),],seqData=TRUE))

syn$store(synapse$File(kf,parentId=analysis_dir),used=c('syn5051784','syn5556216'))



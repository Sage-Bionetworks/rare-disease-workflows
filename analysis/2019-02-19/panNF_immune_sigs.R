
library(reticulate)
synapse <- import("synapseclient")
syn <- synapse$Synapse()
syn$login()

require(tidyverse)
syn_file='syn18349249'
expData<-read.csv(gzfile(syn$get(syn_file)$path))

require(singleCellSeq)
#analysis_dir='syn11398941'

#call the heatmap rmd
rmd<-system.file('heatmap_vis.Rmd',package='singleCellSeq')

this.code='https://raw.githubusercontent.com/sgosline/NEXUS/master/analysis/2019-02-19/panNF_immune_sigs.R'
#rownames(expData)<-expData$id

#create matrix
combined.mat=reshape2::acast(expData,Symbol~id,value.var="zScore")
missing=which(apply(combined.mat,1,function(x) any(is.na(x))))
combined.mat=combined.mat[-missing,]

#create phenData
phenData<-expData%>%select(id,age,Sex,tumorType,isCellLine,study)%>%unique()

rownames(phenData)<-phenData$id
phenData$isCellLine<-tolower(phenData$isCellLine)
kf<-rmarkdown::render(rmd,rmarkdown::html_document(),output_file=paste(getwd(),'/',lubridate::today(),'panNFHeatmap.html',sep=''),params=list(samp.mat=combined.mat,cell.annotations=phenData%>%select(-id),seqData=TRUE))

analysis_dir='syn18134642'
syn$store(synapse$File(kf,parentId=analysis_dir),used=syn_file,executed=this.code)

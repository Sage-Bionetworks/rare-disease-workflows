
library(reticulate)
synapse <- import("synapseclient")
syn <- synapse$Synapse()
syn$login()

require(tidyverse)
syn_file='syn18137070'
expData<-read.csv(gzfile(syn$get(syn_file)$path))

require(singleCellSeq)
#analysis_dir='syn11398941'

#call the heatmap rmd
rmd<-system.file('heatmap_vis.Rmd',package='singleCellSeq')

#rownames(expData)<-expData$id

#create matrix
combined.mat=reshape2::acast(expData,Symbol~id,value.var="zScore")
missing=which(apply(combined.mat,1,function(x) any(is.na(x))))
combined.mat=combined.mat[-missing,]

#create phenData
phenData<-expData%>%select(id,species,age,Sex,tumorType,isCellLine,study)%>%unique()

rownames(phenData)<-phenData$id
kf<-rmarkdown::render(rmd,rmarkdown::html_document(),output_file=paste(getwd(),'/panNFHeatmap.html',sep=''),params=list(samp.mat=combined.mat,cell.annotations=phenData%>%select(-id),seqData=FALSE))

syn$store(synapse$File(kf,parentId=analysis_dir),used=syn_file)

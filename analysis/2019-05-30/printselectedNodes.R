##eval nodes 

require(tidyverse)
node.tab='../../../drug-target-expression-network/testallNodeResults.tsv'
tumorType='MPNST'
full.res<-read.table(node.tab,sep='\t')%>%subset(nodeType=='Compound')%>%subset(Condition=='Malignant Peripheral Nerve Sheath Tumor')
##next test: see if we have cell line data!
source("../../bin/plotDrugsAcrossCells.R")
drugs.with.data<-subset(tab.with.id,symptom_name==tumorType)%>%subset(std_name%in%full.res$Node)%>%select(std_name)%>%distinct()
#  drugs.with.data<-intersect(full.res$Node,all.compounds)
  #print(drugs.with.data)
  if(row(drugs.with.data)>0){
    p1=unlist(lapply(drugs.with.data$std_name,plotDrugByCellAndTumor,tumorType=tumorType))
    p2=unlist(lapply(drugs.with.data$std_name,plotDoseResponseCurve,tumorTypes=c(tumorType),scaleY = F, minLogDose = -6, minDosesPerGroup = 5))
  }


##now do the same for pnfs
tumorType='pNF'
full.res<-read.table(node.tab,sep='\t')%>%subset(nodeType=='Compound')%>%subset(Condition=='Plexiform Neurofibroma')
##next test: see if we have cell line data!
drugs.with.data<-subset(tab.with.id,symptom_name==tumorType)%>%subset(std_name%in%full.res$Node)%>%select(std_name)%>%distinct()
  #print(drugs.with.data)
  if(nrow(drugs.with.data)>0){
    p1=unlist(lapply(drugs.with.data$std_name,plotDrugByCellAndTumor,tumorType=tumorType))
  p2=unlist(lapply(drugs.with.data$std_name,plotDoseResponseCurve,tumorTypes=c(tumorType),scaleY = F, minLogDose = -6, minDosesPerGroup = 5))
  }
 

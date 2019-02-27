#runNF diffex

require(synapser)
require(limma)
require(tidyverse)

#get the tidied data with annotations
synLogin()
syn_file='syn18349249'
expData<-read.csv(gzfile(synGet(syn_file)$path))%>%subset(Symbol!='')

conts=which(is.na(expData$tumorType))
levels(expData$tumorType)<-c(levels(expData$tumorType),'Schwann')
expData$tumorType[conts]<-as.factor(rep('Schwann',length(conts)))

expData<-expData%>%mutate(roundedCounts=round(totalCounts))
combined.mat=reshape2::acast(expData,Symbol~id,value.var="roundedCounts")
missing=which(apply(combined.mat,1,function(x) any(is.na(x))))
if(length(missing)>0)
  combined.mat=combined.mat[-missing,]

vars<-expData%>%select(id,Sex,study,isCellLine,tumorType)%>%unique()
vars$isCellLine=tolower(vars$isCellLine)
vars$tumorType<-make.names(vars$tumorType)
design<-model.matrix(~ Sex+tumorType+study+isCellLine,vars)

contrasts=makeContrasts(cNF=Cutaneous.Neurofibroma,pNF=Plexiform.Neurofibroma,lgg=Low.Grade.Glioma,MPNST=Malignant.Peripheral.Nerve.Sheath.Tumor,levels=unique(vars$tumorType))


v <- voomWithQualityWeights(combined.mat, design, plot=TRUE)

vfit <- lmFit(v, design)
#vfit <- contrasts.fit(vfit, contrasts=contrasts)

efit <- eBayes(vfit)




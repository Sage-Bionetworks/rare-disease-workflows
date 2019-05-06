#run pNF coopy number analysis

source("../../bin/copyNumberAnalysis.R")


synLogin()

all.segs<-synGet('syn18635308')$path
pat.data<-synTableQuery("SELECT distinct specimenID,individualID,tumorType,diagnosis,tissue,isCellLine,transplantationType FROM syn13363852 WHERE ( ( \"assay\" = 'exomeSeq' ) AND ( \"fileFormat\" = 'bam' ) )")$asDataFrame()

parent='syn18634452'
this.script='https://raw.githubusercontent.com/sgosline/NEXUS/master/analysis/2019-05-03/dopNFCopyNumber.R'


segdata<-read.csv(all.segs)%>%rename(specimenID=sample.name)%>%left_join(pat.data,by='specimenID')
#seg.pngs<-plotSegs(comp.segs)
plotBetterCopies(segdata,prefix='all',all.only=F)

sapply(unique(segdata$individualID),function(x){
  plotBetterCopies(subset(segdata,individualID==x),prefix=x,all.only=T)
})

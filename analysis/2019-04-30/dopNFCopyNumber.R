                                        #run pNF coopy number analysis

source("../../bin/copyNumberAnalysis.R")

synLogin()

all.files<-synTableQuery("SELECT * FROM syn13363852 WHERE ( ( \"assay\" = 'exomeSeq' ) AND ( \"fileFormat\" = 'bam' ) )")$asDataFrame()

parent='syn18634452'
this.script=''
bam.files=all.files$id
names(bam.files)<-all.files$specimenID

comp.segs<-runCnvAnalysis(bam.files,12)

seg.pngs<-plotSegs(comp.segs)

comp.annotes<-as.list(unique(all.files[,c('assay','cellType','dataSubtype','dataType','diagnosis','organ','platform','species','study','studyId','studyName','consortium','fundingAgency')]))
comp.annotes$resourceType='analysis'
comp.annotes$isMultiSpecimen='TRUE'

df<-as.data.frame(comp.segs)
write.csv(df,file='pNFSegs.csv')
#store bulk files
for(fi in c('pNFSegs.csv',seg.pngs)){
  synStore(File(fi,parentId=parent,annotations=comp.annotes),used=all.files$id,executed=this.script)
}

#now store distinct files
specs<-unique(all.files$specimenID)
lapply(specs,function(x){
  mdf=subset(df,sample==x)
  annotes<-as.list(all.files[which(all.files$specimenID==x),9:48])
  annotes$assay='exomeSeq'
  annotes$resourceType='analysis'
  fname=paste('pNFSegsSample',x,'.csv',sep='')
  write.csv(mdf,file=fname)
  synStore(File(fname,annotations=annotes,parentId=parent),used='',executed=this.script)
})

library(synapser)
synLogin()

fendR.table<-'syn18483855'

source("../../bin/getNetworksAndStoreEnrichment.R")
all.nets<-synTableQuery(paste('select tumorType, "PCSF Result",mu,beta,w from',fendR.table))$asDataFrame()

fendr.path='syn18488120'
library(iterators)
source("../../bin/getNetworksAndStoreEnrichment.R")
library(parallel)
library(PCSF)
completed.nets<-synTableQuery(paste('select distinct "PCSF Result" from',fendr.path))$asDataFrame()
all.nets<-all.nets[which(!all.nets$`PCSF Result`%in%completed.nets$`PCSF Result`),]


fin.tab<-lapply(iter(all.nets,by='row'), function(x){
 # print(x[["PCSF Result"]])
  ntab<-doEnrichment(x[['PCSF Result']])
  ntab$`PCSF Result`=rep(x[['PCSF Result']],nrow(ntab))
  new.tab=ntab%>%dplyr::left_join(x,by='PCSF Result')%>%select(-c(ROW_ID,ROW_VERSION))
  synapser::synStore(synapser::Table(fendr.path,new.tab))

})

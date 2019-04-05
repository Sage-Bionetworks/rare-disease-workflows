library(synapser)
synLogin()

fendR.table<-'syn18483855'

source("../../bin/getNetworksAndStoreEnrichment.R")
all.nets<-synTableQuery(paste('select tumorType, "PCSF Result",mu,beta,w from',fendR.table))$asDataFrame()

fin.tab<-apply(all.nets,1,function(x){
  tab<-doEnrichment(x[['PCSF Result']])
  tab$`PCSF Result`=x[['PCSF Result']]
  new.tab=tab%>%dplyr::left_join(x,by='PCSF Result')%>%select(-ROW_ID,-ROW_VERSION)
  synapser::synStore(synapser::Table(fendr.path,new.tab))
  
})


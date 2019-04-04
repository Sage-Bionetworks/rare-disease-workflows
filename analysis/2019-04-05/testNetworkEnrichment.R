library(synapser)
synLogin()

fendR.table<-'syn18483855'

source("../../bin/getNetworksAndStoreEnrichment.R")
all.nets<-synTableQuery(paste('select tumorType, "PCSF Result" from',fendR.table))$asDataFrame()



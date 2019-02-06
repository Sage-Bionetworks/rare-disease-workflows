##agora test plots
#try to recreate the analysis that agor does

library(synapser)
synLogin()

genes.with.meta<-read.csv(gzfile(synGet('syn18137070')$path))

source("../../bin/nf1TumorHarmonization.R")

##barplot
singleGeneBarplot(genes.with.meta,'GFAP')
singleGeneBarplot(genes.with.meta,'AXL')
singleGeneBarplot(genes.with.meta,'SMARCA2')


##diffex boxplot

diffexdata<-getMvsF(genes.with.meta)
diffExBoxplot(diffexdata,'GFAP')
diffExBoxplot(diffexdata,'AXL')
diffExBoxplot(diffexdata,'SMARCA2')



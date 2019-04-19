
require(synapser)
synLogin()
require(parallel)

#first get dataset

fpath = synGet('syn18408380')$path
tab = read.csv(fpath,header=T)
rtab = tab[,c('specimenID','tumorType','totalCounts','Symbol')]
colnames(rtab)<-c('sample','conditions','counts','gene')
#rtab.to_csv('newTab.csv')
write.csv(rtab,file='newTab.csv')

conds = c('Low Grade Glioma','Cutaneous Neurofibroma','Plexiform Neurofibroma')
allnets=c()


mclapply(conds,function(condition){
    mv=paste(gsub(' ','',condition),'Prots.tsv',sep='')
    #run metaviper
    cmd=paste("Rscript /usr/local/bin/runMetaViper.R --input newTab.csv --output",mv,'--idtype hugo --condition \"',condition,'\"')
    print(cmd)
    system(cmd)

    #then run pcsf
    mo=paste(gsub(' ','',condition),'net.rds',sep='')
    allnets.append(mo)
    cmd = paste("Rscript /usr/local/bin/runNetworkFromGenes.R --input",mv," --condition \"",condition,"\" --b 3 --mu 5e-05 --w 2 --output",mo)
    print(cmd)
    system(cmd)
})
#now with all three run the meta-analysis
newcmd=paste('Rscript /usr/local/bin/metaNetworkComparisons.R --input ',paste(allnets,collapse=','))
print(newcmd)
system(newcmd)

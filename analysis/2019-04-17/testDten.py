#!/usr/local/bin/python3
import os
import re
import synapseclient
from synapseclient import *
import pandas as pd



syn = synapseclient.Synapse()
syn.login()

#first get dataset

fpath = syn.get('syn18408380').path
tab = pd.read_csv(fpath)
rtab = tab[['specimenID','tumorType','totalCounts','Symbol']]
rtab.columns = ['sample','conditions','counts','gene']
rtab.to_csv('newTab.csv')


conds = ['Low Grade Glioma','Cutaneous Neurofibroma','Plexiform Neurofibroma']
#conds = ['Plexiform Neurofibroma']
allnets=[]

for condition in conds:
    mv=re.sub(' ','',condition)+'Prots.tsv'
    #run metaviper
    cmd="Rscript ../../../drug-target-expression-network/bin/runMetaViper.R --input newTab.csv --output "+mv+' --idtype hugo --condition \"'+condition+'\"'
    print(cmd)
    os.system(cmd)

    #then run pcsf
    mo=re.sub(' ','',condition)+'net.rds'
    allnets.append(mo)
    cmd = "Rscript ../../../drug-target-expression-network/bin/runNetworkFromGenes.R --input "+mv+" --condition \""+condition+"\" --b 3 --mu 5e-05 --w 2 --output "+mo
    print(cmd)
    os.system(cmd)

#now with all three run the meta-analysis
newcmd='Rscript ../../../drug-target-expression-network/bin/metaNetworkComparisons.R --input '+','.join(allnets)
print(newcmd)
os.system(newcmd)

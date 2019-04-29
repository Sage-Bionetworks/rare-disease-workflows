#!/usr/local/bin/python3

import synapseclient
import pandas
import os

syn = synapseclient.Synapse()
syn.login()
#get cram files
query="SELECT * FROM syn13363852 where fileFormat='cram' AND assay='exomeSeq' AND name like '%cram'"
results = syn.tableQuery(query).asDataFrame()

refgenome=syn.get('syn18082228').path#i hope this is it
bamdir='syn18632539'
this.script='https://raw.githubusercontent.com/sgosline/NEXUS/master/analysis/2019-04-29/convertCramToBam.py'
#get fastq files
for row in results:
    synid=row.id
    fileEnt=syn.get(synid)
    filepath=fileEnt.path
    #run samtools
    bamfile=re.sub('.cram','.bam',os.path.basename(filepath))
    stools='samtools view -b -T'+refgenome+' -o '+bamfile+' '+filepath
    print(stools)
    os.system(stools)

    #store files with annotations
    annotes=syn.getAnnotations(fileEnt)
    annotes['fileFormat']='bam'
    ent=syn.File(bamfile,description='BAM file',parent=bamdir,annotations=annotes)
    activity=syn.Activity(used=syndi,executed=this.script)
    syn.store(ent,activity=activity)

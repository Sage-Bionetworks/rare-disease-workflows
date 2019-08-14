suppressPackageStartupMessages(require(optparse))


getArgs<-function(){

  option_list <- list(
      make_option(c("-f", "--files"), dest = 'files', help= 'Comma-delimited list of count files'),
      make_option(c("-m", "--manifest"), dest = 'manifest', help= 'Single manifest file'))
    args=parse_args(OptionParser(option_list = option_list))

    return(args)
}


main<-function(){
    args<-getArgs()
    ##here we have all the file metadata we need
    all.manifests<-read.table(args$manifest,header=T,sep='\t')
   # message('Manifest dimensions')
   # message(dim(all.manifests))

    #here we have all the counts
    all.count.files<-do.call(rbind,lapply(unlist(strsplit(args$files,split=',')),function(x){
        tab<-read.table(x,header=T,sep='\t')
        tab$fname=rep(basename(x),nrow(tab))
        return(tab)
    }))
    message("Count dimensions")
    message(dim(all.count.files))

    #add in gene names and get total counts
    ensmap<-getGeneMap()
    genes.with.names<-annotateGenesFilterGetCounts(all.count.files,ensmap)

                                        #now join with manifest
    require(dplyr)
    tidied.df<-genes.with.names%>%rename(path='fname')%>%left_join(all.manifests,by='path')%>%unique()
    message(paste("table with manifest:"))
   message(dim(tidied.df))

    ##get synapse id of origin file by parent and path
    syn.ids<-getIdsFromPathParent(select(tidied.df,c('path','parent'))%>%unique())

    with.prov<-tidied.df%>%left_join(syn.ids,by='path')%>%unique()

    cat(format_tsv(with.prov))

}


# this function gets a mapping of all gene names to enst ids
# @requires biomaRt
getGeneMap<-function(){
#####NOW DOWNLOAD COUNTS
    library(biomaRt)
#get mapping from enst to hgnc
    mart = useMart("ensembl", dataset="hsapiens_gene_ensembl")
    my_chr <- c(1:22,'X','Y')
    map <- getBM(attributes=c("ensembl_transcript_id","hgnc_symbol"),mart=mart,filters='chromosome_name',values=my_chr)
    return (map)
}

# This function filters out protein-coding genes for analysis, then maps to to HUGO gene ids, gets the z score
# synapser dependencies is due to gene list downloaded from synapse.
# @export
# @require synapser
# @require dplyr
# @require tidyr
annotateGenesFilterGetCounts<-function(genetab,genemap){
    require(tidyr)
    require(dplyr)
    require(synapser)
    synLogin()
    ##now get all genes
    path=synapser::synGet('syn18134565')$path
    R.utils::gunzip(path,overwrite=T)
    system(paste("grep protein_coding",gsub(".gz","",path),"|cut -d '|' -f 6 |uniq > gencode.v29.transcripts.txt"))

                                        #now parse the headers
    genes=read.table('gencode.v29.transcripts.txt')

    ##add in gene names
    full.tab<-genetab%>%
        tidyr::separate(Name,into=c('ensembl_transcript_id',NA))%>%
        dplyr::inner_join(genemap,by='ensembl_transcript_id')
    message(paste('table after join:',nrow(full.tab)))
                                        #filter out genes
    red.tab<-subset(full.tab,hgnc_symbol%in%genes[,1])
    message(paste('table with protein coding:',nrow(red.tab)))


                                        #now z score it


    fin.tab=red.tab%>%
        dplyr::group_by(hgnc_symbol,fname)%>%
        dplyr::summarize(totalCounts=sum(NumReads))%>%
        dplyr::select(totalCounts,Symbol='hgnc_symbol',fname)%>%unique()

    with.z=fin.tab%>%dplyr::group_by(fname)%>%dplyr::mutate(zScore=(totalCounts-mean(totalCounts+0.001,na.rm=T))/sd(totalCounts,na.rm=T))

    message(paste('table with unique gene counts:',nrow(with.z)))
    return(with.z)

}

# this is a generic `synapse` helper function to get the ids of a file from its parent
# the goal is to reverse engineer provenance downstream of the original generation.
# @export
# @requires synapser
getIdsFromPathParent<-function(path.parent.df){
  require(synapser)
  synLogin()
  synid<-apply(path.parent.df,1,function(x){
  # print(x[['parent']])
   children<-synapser::synGetChildren(x[['parent']])$asList()
    #print(children)
    for(c in children){
      if(c$name==basename(x[['path']]))
        return(c$id)
      else
          return(NA)}
  })
#  print(synid)
  path.parent.df<-data.frame(path.parent.df,used=synid)#rep(synid,nrow(path.parent.df)))
  return(dplyr::select(path.parent.df,c(path,used)))
}


main()

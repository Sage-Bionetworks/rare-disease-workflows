suppressPackageStartupMessages(require(optparse))


getArgs<-function(){

  option_list <- list(
      make_option(c("-f", "--files"), dest='files',help='Comma-delimited list of count files'),
      make_option(c("-m", "--manifest"),dest='manifest',help='Single list of manifest file'),
#      make_option(c("-s", "--samples"),dest='samples',help='Comma-delimited list of samples'),
      make_option(c("-o", "--output"), default="merged-tidied.df.tsv", dest='output',help = "output file name"),
      make_option(c("-p", "--tableparentid"), dest='tableparentid',help='Synapse id of project containing data model',default=""),
      make_option(c("-n", "--tablename"), default="Default Table", dest='tablename',help='Name of table'))

    args=parse_args(OptionParser(option_list = option_list))

    return(args)
}

#prefix=paste(lubridate::today(),'coding_only_bioBank_glioma_cNF_pnf',sep='-')

# Get synapse ID of files based on path and parent in manifest
# @export
# @requires synapser
getIdsFromPathParent<-function(path.parent.df){
  require(synapser)
  
  synid<-apply(path.parent.df,1,function(x){
  
    children<-synapser::synGetChildren(x[['parent']])$asList()
    for(c in children)
      if(c$name==x[['path']])
        return(c$id)})
  
  path.parent.df$used=synid
  return(select(path.parent.df,c(path,used)))
}

main<-function(){

    args<-getArgs()
  print(args)
    ##here we have all the file metadata we need
    all.manifests<-read.csv(args$manifest,header=T,sep='\t')
    print('Manifest dimensions')
    print(dim(all.manifests))

    #here we have all the counts
    all.count.files<-do.call(rbind,lapply(unlist(strsplit(args$files,split=',')),function(x){
        tab<-read.table(x,header=T,sep='\t')
        tab$fname=rep(x,nrow(tab))
        return(tab)
    }))
    print("Count dimensions")
    print(dim(all.count.files))

    #add in gene names and get total counts
    ensmap<-getGeneMap()
    genes.with.names<-annotateGenesFilterGetCounts(all.count.files,ensmap)

                                        #now join with manifest
    require(dplyr)
    tidied.df<-genes.with.names%>%rename(path='fname')%>%left_join(all.manifests,by='path')
    
    ##get synapse id of origin file by parent and path
    syn.ids<-getIdsFromPathParent(select(tidied.df,c('path','parent'))%>%unique())
    
    with.prov<-tidied.df%>%left_join(syn.ids,by='path')
    
    if(args$tableparentid!=""){
      saveToTable(with.prov,args$tablename,args$tableparentid)
    }
#    write.table(with.prov,file=args$output)

}

# @export
# @requires synapser
# @requires dplyr
# @requires tidyr
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
    print(paste('table after join:',nrow(full.tab)))
                                        #filter out genes
    red.tab<-subset(full.tab,hgnc_symbol%in%genes[,1])
    print(paste('table with protein coding:',nrow(red.tab)))


                                        #now z score it


    fin.tab=red.tab%>%
        dplyr::group_by(hgnc_symbol,fname)%>%
        dplyr::summarize(totalCounts=sum(NumReads))%>%
        dplyr::select(totalCounts,Symbol='hgnc_symbol',fname)%>%unique()

    with.z=fin.tab%>%dplyr::group_by(fname)%>%dplyr::mutate(zScore=(totalCounts-mean(totalCounts+0.001,na.rm=T))/sd(totalCounts,na.rm=T))

    print(paste('table with unique gene counts:',nrow(with.z)))
    return(with.z)

}

# creates a new table unless one already exists
# reqires synapser
# @export
saveToTable<-function(tidied.df,tablename,parentId){
  require(synapser)
  ##first see if there is a table with an existing name
  children<-synapser::synGetChildren(parentId)$asList()
  id<-NULL
  for(c in children)
    if(c$name==tablename)
      id<-c$id
  if(is.null(id)){
    synapser::synStore(synapser::synBuildTable(tablename,parentId,tidied.df))
  }else{
    saveResultsToExistingTable(tidied.df,id)
  }
}

 
# @requires synapser
# @export
saveResultsToExistingTable<-function(tidied.df,tableid){
  require(synapser)
  #first get table schema
  orig.tab<-synGet(tableid)
  
  #then get column names
  cur.cols<-sapply(as.list(synGetTableColumns(orig.tab)),function(x) x$name)
  
  #how are they different?
  missing.cols<-setdiff(cur.cols,names(tidied.df))
  
  #then add in values
  for(a in missing.cols){
    tidied.df<-data.frame(tidied.df,rep(NA,nrow(tidied.df)))
    colnames(tidied.df)[ncol(tidied.df)]<-a
  }
  
  other.cols<-setdiff(names(tidied.df),cur.cols)
  for(a in other.cols){
    if(is.numeric(tidied.df[,o]))
      orig.tab$addColumn(synapser::Column(name=o,columnType="DOUBLE"))
    else{
      orig.tab$addColumn(synapser::Column(name=o,type="STRING",maximumSize=100))
    }
  }
  
  #store to synapse
  synapser::synStore(synapser::Table(orig.tab,tidied.df))
}


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

main()

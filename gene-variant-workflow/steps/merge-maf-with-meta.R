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
    message('Manifest dimensions')
    message(nrow(all.manifests))

    #here we have all the counts
    all.count.files<-do.call(rbind,lapply(unlist(strsplit(args$files,split=',')),function(x){
        tab<-read.table(x,header=T,sep='\t')
        tab$fname=rep(basename(x),nrow(tab))
        return(tab)
    }))
    message("Count dimensions")
    message(nrow(all.count.files))

    #add in gene names and get total counts
    genes.with.names<-all.count.files

                                        #now join with manifest
    require(dplyr)
    tidied.df<-genes.with.names%>%rename(path='fname')%>%left_join(all.manifests,by='path')%>%unique()
    message(paste("table with manifest:"))
    message(nrow(tidied.df))

    ##get synapse id of origin file by parent and path
    syn.ids<-getIdsFromPathParent(select(tidied.df,c('path','parent'))%>%unique())

    with.prov<-tidied.df%>%left_join(syn.ids,by='path')%>%unique()
    require(readr)
    cat(readr::format_tsv(with.prov))

}



quiet <- function(x) {
  sink(tempfile())
  on.exit(sink())
  invisible(force(x))
}


# this is a generic `synapse` helper function to get the ids of a file from its parent
# the goal is to reverse engineer provenance downstream of the original generation.
# @export
# @requires synapser
getIdsFromPathParent<-function(path.parent.df){
  require(synapser)
  quiet(synLogin())
  synid<-apply(path.parent.df,1,function(x){
   message(x[['parent']])
   children<-synapser::synGetChildren(x[['parent']])$asList()
   message(children)
   for(c in children){
       if(c$name==basename(x[['path']]))
           return(c$id)
   }
   return(NA)
  })
#  print(synid)
  path.parent.df<-data.frame(path.parent.df,used=synid)#rep(synid,nrow(path.parent.df)))
  return(dplyr::select(path.parent.df,c(path,used)))
}


main()

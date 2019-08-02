suppressPackageStartupMessages(require(optparse))


getArgs<-function(){

  option_list <- list(
      make_option(c("-f", "--file"), default="merged-tidied.df.tsv", dest='file',help = "tab-delimited table file name"),
      make_option(c("-p", "--tableparentid"), dest='tableparentid',help='List of synapse ids of projects containing data model',default=""),
      make_option(c("-n", "--tablename"), default="Default Table", dest='tablename',help='Comma-delimited list of table names'))

    args=parse_args(OptionParser(option_list = option_list))

    return(args)
}


main<-function(){

    args<-getArgs()


    with.prov<-read.table(args$file,sep='\t',header=T,as.is=T,check.names=F)

    if(args$tableparentid!=""){
        synids=unlist(strsplit(args$tableparentid,split=','))
        tabnames=unlist(strsplit(args$tablename,split=','))
        print(synids)
        print(tabnames)
        if(length(synids)!=length(tabnames))
            print("Number of synids must match number of table names")
        else
            for(a in 1:length(synids))
                saveToTable(with.prov,tabnames[a],synids[a])
    }


}


# creates a new table unless one already exists
# reqires synapser
# @export
saveToTable<-function(tidied.df,tablename,parentId){
  require(synapser)
  synapser::synLogin()
  ##first see if there is a table with an existing name
  children<-synapser::synGetChildren(parentId)$asList()
  id<-NULL
  for(c in children)
    if(c$name==tablename)
      id<-c$id
  if(is.null(id)){
      print('No table found, creating new one')
    synapser::synStore(synapser::synBuildTable(tablename,parentId,tidied.df))
  }else{
    saveResultsToExistingTable(tidied.df,id)
  }
}


# @requires synapser
# @export
saveResultsToExistingTable<-function(tidied.df,tableid){
    require(synapser)
    synapser::synLogin()
print(paste(tableid,'already exists with that name, adding'))
  #first get table schema
  orig.tab<-synGet(tableid)

  #then get column names
  cur.cols<-sapply(as.list(synGetTableColumns(orig.tab)),function(x) x$name)

  #how are they different?
    missing.cols<-setdiff(cur.cols,names(tidied.df))
    print(paste("DF missing:",paste(missing.cols,collapse=',')))
 # print('orig table')
 # print(dim(tidied.df))
  #then add in values
  for(a in missing.cols){
	   print(paste('adding',a))
    tidied.df<-cbind(as.data.frame(tidied.df),rep(NA,nrow(tidied.df)))
    names(tidied.df)[ncol(tidied.df)]<-a
  }

    other.cols<-setdiff(names(tidied.df),cur.cols)
    print(paste("Syn table missing:",paste(other.cols,collapse=',')))
  for(a in other.cols){
	   print(paste('creating',a))
    if(is.numeric(tidied.df[,a])){
      nc=synStore(Column(name=a,columnType='DOUBLE'))
    }else{
      nc=synStore(Column(name=a,columnType='STRING',maximumSize=100))
    }
    print('adding')
    orig.tab$addColumn(nc)
    print('storing')
    synStore(orig.tab)
    print('retriving')
    orig.tab<-synGet(orig.tab$properties$id)

  }
  print('final table')
    print(dim(tidied.df))
    chsize=100000 #TODO: fix this once synapser is no longer broken :'(
    chunks=floor(nrow(tidied.df)/chsize)
    print(paste('into',chunks,'chunks'))
                                        #store to synapse
    for(i in 0:chunks){
        print(paste('storing chunk',i))
    	inds=seq(i*chsize+1,min((i+1)*chsize,nrow(tidied.df)))
        cdf<-tidied.df[inds,]
	print(dim(cdf))
        stab<-synapser::Table(orig.tab,cdf)
	
        synapser::synStore(stab)
    }
}



main()

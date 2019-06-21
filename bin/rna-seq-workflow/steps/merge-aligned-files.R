suppressPackageStartupMessages(require(optparse))


getArgs<-function(){

  option_list <- list(
      make_option(c("-f", "--files"), dest='files',help='Comma-delimited list of count files'),
      make_option(c("-m", "--manifest"),dest='manifest',help='Comma-delimited list of manifest files'),
#      make_option(c("-s", "--samples"),dest='samples',help='Comma-delimited list of samples'),
      make_option(c("-o", "--output"), default="merged-tidied.df.tsv", dest='output',help = "output file name"))

    args=parse_args(OptionParser(option_list = option_list))

    return(args)
}

#prefix=paste(lubridate::today(),'coding_only_bioBank_glioma_cNF_pnf',sep='-')

main<-function(){
    args<-getArgs()

    ##here we have all the file metadata we need
    all.manifests<-do.call(lapply(args$manifest,function(x) read.csv(x,header=T)))
    print('Manifest dimensions')
    print(dim(all.manifests))

    #here we have all the counts
    all.count.files<-do.call(lapply(args$files,function(x){
        tab<-read.table(x,header=T)
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
    tidied.df<-genes.with.names%>%left_join(all.manifest)
    write.table(tidied,df,file=args$output)

}

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
    red.tab<-subset(full.tab,Symbol%in%genes[,1])
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

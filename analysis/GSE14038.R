library(affy)
library(gcrma)
library(hgu133plus2hsrefseqprobe)
library(hgu133plus2hsrefseqcdf)
library(hgu133plus2hsrefseq.db)
library(WGCNA)
library(GEOquery)

source("../bin/common.R")

#GCRMA
cdf <- "hgu133plus2hsrefseq"

#Read in the raw data from specified dir of CEL files
raw.data.ALL <- ReadAffy(verbose=TRUE, celfile.path="./GSE14038/data/GSE14038_RAW/", cdfname=cdf)

#perform GCRMA normalization
data.gcrma <- gcrma(raw.data.ALL)
#Get the important stuff out of the data - the expression estimates for each array
gcrma.ALL <- exprs(data.gcrma)

#Remove control probes: probenames starting with "AFFX"
control <- grep("^AFFX",rownames(gcrma.ALL),value=TRUE)
gcrma.ALL <- gcrma.ALL[!rownames(gcrma.ALL) %in% control,]

probes.ALL<- row.names(gcrma.ALL)
symbol.ALL <- unlist(mget(probes.ALL,hgu133plus2hsrefseqSYMBOL))
gcrma.ALL <- cbind(symbol.ALL,gcrma.ALL)

df <- as.data.frame(gcrma.ALL)
df <- data.frame(lapply(df, as.character), stringsAsFactors=FALSE)
df <- df[,-1]
df <- data.frame(lapply(df,as.numeric))
df$symbol <- symbol.ALL

# for gene sample with multiple probes, take the row with highest IQR
df.iqr <- getMaxIQR(df,df$symbol)
colnames(df.iqr) <- gsub("\\.CEL\\.gz","",colnames(df.iqr))
write.table(df.iqr, file = "GSE14038_expVal.tsv", quote = FALSE, sep = "\t")

getMaxIQR <- function(df,refCol){  
  result <- do.call(rbind,lapply(unique(refCol),FUN =function(x){
    temp <- df[df$symbol == x,]
    temp$symbol <- NULL
    if(dim(temp)[1] > 1){
      result <- apply(temp, 1, function(y){
        return(IQR(y))
      })
      final <- temp[which.max(result),]
      row.names(final) <- x
      return(final)
    }else{
      final <- temp[1,]
      row.names(final) <- x
      return(final)
    }
  }))
  return(result)
}

rm(df)

# Get the phenotype data
phenotype_data <- getGEO("GSE14038")
phenotype_data <- pData(phenotype_data[[1]])
phenotype_data <- phenotype_data[,c("geo_accession", "source_name_ch1", "characteristics_ch1")]
colnames(phenotype_data) <- c("geo_accession", "sourceType","cellType")
phenotype_data$sourceType <- sub('\\:.+','',phenotype_data$sourceType)
write.table(phenotype_data,"GSE14038_phenotype_data.tsv",sep="\t",rownames =FALSE)

###############
# ESTIMATE
###############
est_score <- estimateMatrix("GSE14038_expVal.tsv", "GSE14038")
write.table(est_score, "./estimate/GSE14038_estimate_score.tsv",quote = FALSE, sep = "\t", row.names = TRUE, col.names = TRUE)

sourceTypes <- unique(phenotype_data$sourceType)

library(ggplot2)
est_score <- data.frame(t(est_score))
est_score <- merge(est_score,phenotype_data,by="geo_accession")
ggplot(est_score, aes(x=StromalScore, y=TumorPurity, color=sourceType)) + geom_point(size=2)
ggsave("./estimate/stromalScore_tumorPurity_by_source.png", width=8, height=4)

ggplot(est_score, aes(x=ImmuneScore, y=TumorPurity, color=sourceType)) + geom_point(size=2)
ggsave("./estimate/immuneScore_tumorPurity_by_source.png", width=8, height=4)

ggplot(est_score, aes(x=ESTIMATEScore, y=TumorPurity, color=sourceType)) + geom_point(size=2)
ggsave("./estimate/ESTIMIATEScore_tumorPurity_by_source.png", width=8, height=4)

###########
# GSVA
###########
expr <- as.matrix(df.iqr)
phenotype_data$geo_accession <- NULL

# immune signature
gsva.imm <- gsvaMatrix(expr,geneSet.bindea,"GSE14038","immSig")
gsvaHeatMap(mat = gsva.imm,fileName = "GSE14038_immSig_GSVA_heatmap.png",df = phenotype_data)

# hallmarks
gsva.hallmarks <- gsvaMatrix(expr,geneSet.hallmarks,"GSE14038","hallmarks")
gsvaHeatMap(mat = gsva.hallmarks,fileName = "GSE14038_hallmarks_GSVA_heatmap.png",df = phenotype_data)



library(GSVA)
library(pheatmap)
library(estimate)
library(CePa)

# load gene sets for GSVA
load("geneSets.RData")

# Create folders for GSVA and ESTIMATE
dir.create(file.path("pathway_analysis"), showWarnings = FALSE)
dir.create(file.path("estimate"), showWarnings = FALSE)

# Generates the gsva matrix and saves in pathway_analysis/ folder
# Returns gsva matrix
# @param expr matrix
# @param geneSet list
# @param exprName string
# @param geneSetName string
# @param core integer
gsvaMatrix <- function(expr,geneSet,exprName,geneSetName, core=3){
  obs <- gsva(expr, geneSet ,parallel.sz=core)$es.obs
  write.table(obs,paste0("./pathway_analysis/",paste(exprName,geneSetName,"GSVA_enrichment.tsv",sep="_")),sep="\t")
  return(obs)
}

# Outputs the heatmap
# @param mat matrix
# @param fileName string
# @param df dataframe for annotation
# @param clusterRows True/False
# @param clusterCols True/False
gsvaHeatMap <- function(mat, fileName, df = NULL,clusterRows=T,clusterCols = T){
  pheatmap(mat, cellheight=10,cellwidth=10, annotation = df,
           filename=paste0("pathway_analysis/",fileName), 
           cluster_rows=clusterRows,cluster_cols = clusterCols)
}

# Outputs estimate scores and saves in estimate/ folder
# Returns estimate output
# @param exprFileLocation string
# @param exprName string
# @param platform
estimateMatrix <- function(exprFileLocation, exprName, platform="affymetrix"){
  exprGct <- paste0("estimate/",exprName,".gct")
  estGct <- paste0("estimate/",exprName,"_estimate_score.gct")
  filterCommonGenes(input.f=exprFileLocation, output.f=exprGct, id="GeneSymbol")
  estimateScore(exprGct, estGct, platform=platform)
  temp <- read.gct(estGct)
  return(temp)
}

#runNF diffex

#require(synapser)
require(reticulate)
require(limma)
require(tidyverse)

#get the tidied data with annotations
synapse <- import("synapseclient")
syn <- synapse$Synapse()
syn$login()


syn_file='syn18349249'
expData<-read.csv(gzfile(syn$get(syn_file)$path))%>%subset(Symbol!='')

expData<-subset(expData,isCellLine%in%c('false','FALSE'))

conts=which(is.na(expData$tumorType))
levels(expData$tumorType)<-c(levels(expData$tumorType),'Schwann')
expData$tumorType[conts]<-as.factor(rep('Schwann',length(conts)))

expData<-expData%>%mutate(roundedCounts=round(totalCounts))
combined.mat=reshape2::acast(expData,Symbol~id,value.var="roundedCounts")
missing=which(apply(combined.mat,1,function(x) any(is.na(x))))
if(length(missing)>0)
  combined.mat=combined.mat[-missing,]

vars<-expData%>%select(id,Sex,study,isCellLine,tumorType)%>%unique()
vars$isCellLine=tolower(vars$isCellLine)
vars$tumorType<-make.names(vars$tumorType)


if(FALSE){
new.mat<-limma::removeBatchEffect(combined.mat,vars$study,vars$isCellLine)

design<-model.matrix(~0+ tumorType,vars)
colnames(design)<-gsub('Sex|tumorType|true','',colnames(design))
#contrasts=makeContrasts(cNF=Cutaneous.Neurofibroma-.,pNF=Plexiform.Neurofibroma,lgg=Low.Grade.Glioma,MPNST=Malignant.Peripheral.Nerve.Sheath.Tumor,levels=unique(vars$tumorType))

contrasts=makeContrasts(cNF=Cutaneous.Neurofibroma-(Plexiform.Neurofibroma+Low.Grade.Glioma+Malignant.Peripheral.Nerve.Sheath.Tumor+Schwann+High.Grade.Glioma+Neurofibroma+Massive.Soft.Tissue.Neurofibroma)/7,pNF=Plexiform.Neurofibroma-(Cutaneous.Neurofibroma+Low.Grade.Glioma+Malignant.Peripheral.Nerve.Sheath.Tumor+Schwann+High.Grade.Glioma+Neurofibroma+Massive.Soft.Tissue.Neurofibroma)/7,levels=colnames(design))

#levels=colnames(design)


#v <- voomWithQualityWeights(new.mat, design, plot=TRUE)


vfit <- lmFit(new.mat, design)
vfit <- contrasts.fit(vfit, contrasts=contrasts)

efit <- eBayes(vfit)
}

library(DESeq2)

#design<-model.matrix(~0+ tumorType,vars)
#colnames(design)<-gsub('Sex|tumorType|true','',colnames(design))

dds <- DESeqDataSetFromMatrix(countData = combined.mat,
  colData = vars,
  design= ~ 0+tumorType+Sex)

dds <- DESeq(dds)

resultsNames(dds)

#get diffex list for each of the 4 tumor types
library(pheatmap)
df<-select(vars,c(study,Sex,tumorType))
rownames(df)<-vars$id

require(biomaRt)
mart <- useMart('ensembl',dataset='hsapiens_gene_ensembl')


cnfRes=results(dds,contrast=list(c("tumorTypeCutaneous.Neurofibroma"),c('tumorTypeLow.Grade.Glioma','tumorTypeHigh.Grade.Glioma','tumorTypeMalignant.Peripheral.Nerve.Sheath.Tumor','tumorTypeMassive.Soft.Tissue.Neurofibroma','tumorTypeNeurofibroma','tumorTypePlexiform.Neurofibroma')),listValues=c(1,-1/6))

cg=order(abs(cnfRes$padj),decreasing=F)[1:20]
cgenes=subset(cnfRes,padj<0.01)

pheatmap(log2(assay(dds)[cg,]+1),annotation_col=df,labels_col=rep("",ncol(assay(dds))),title='cNF diff ex genes')

entrez_list <- getBM(filters = "hgnc_symbol", 
  attributes = c("hgnc_symbol", "entrezgene"), 
  values = rownames(cgenes), mart = mart)

pnfRes=results(dds,contrast=list(c("tumorTypePlexiform.Neurofibroma",'tumorTypeNeurofibroma'),c('tumorTypeLow.Grade.Glioma','tumorTypeHigh.Grade.Glioma','tumorTypeMalignant.Peripheral.Nerve.Sheath.Tumor','tumorTypeMassive.Soft.Tissue.Neurofibroma','tumorTypeCutaneous.Neurofibroma')),listValues=c(1/2,-1/5))

pgenes=order(abs(pnfRes$padj),decreasing=F)[1:20]
pheatmap(log2(assay(dds)[pgenes,]+1),annotation_col=df,labels_col=rep("",ncol(assay(dds))),title='pNF diff ex genes')

mpnstRes=results(dds,contrast=list(c('tumorTypeMalignant.Peripheral.Nerve.Sheath.Tumor','tumorTypeMassive.Soft.Tissue.Neurofibroma'),c('tumorTypeLow.Grade.Glioma','tumorTypeHigh.Grade.Glioma',"tumorTypePlexiform.Neurofibroma",'tumorTypeNeurofibroma','tumorTypeCutaneous.Neurofibroma')),listValues=c(1/2,-1/5))

mgenes=order(abs(mpnstRes$padj),decreasing=F)[1:20]
pheatmap(log2(assay(dds)[mgenes,]+1),annotation_col=df,labels_col=rep("",ncol(assay(dds))),title='MPNST diff ex genes')

lggRes=results(dds,contrast=list(c('tumorTypeLow.Grade.Glioma'),c('tumorTypeMalignant.Peripheral.Nerve.Sheath.Tumor','tumorTypeHigh.Grade.Glioma',"tumorTypePlexiform.Neurofibroma",'tumorTypeMassive.Soft.Tissue.Neurofibroma','tumorTypeNeurofibroma','tumorTypeCutaneous.Neurofibroma')),listValues=c(1,-1/6))

lgenes=order(abs(lggRes$padj),decreasing=F)[1:20]
pheatmap(log2(assay(dds)[lgenes,]+1),annotation_col=df,labels_col=rep("",ncol(assay(dds))),title='lGG diff ex genes',clustering_method = 'ward.D2')

genes=union(lgenes,union(mgenes,union(pgenes,cgenes)))
pheatmap(log2(assay(dds)[genes,]+1),annotation_col=df,labels_col=rep("",ncol(assay(dds))),title='all diff ex genes',clustering_method = 'ward.D2')

## KEGG


kk <- clusterProfiler::enrichKEGG(gene = gene, organism = "hsa", 
  pAdjustMethod = "BH", pvalueCutoff = 0.05, qvalueCutoff = 0.05)
head(summary(kk)[, -8])


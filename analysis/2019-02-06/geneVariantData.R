##harmonize vcf files

#require(synapser)
#synLogin()

#vcf.files=synTableQuery('SELECT id,specimenID,assay,diagnosis,tumorType,individualID,sex,age FROM syn16858331 WHERE ( ( "dataType" = \'genomicVariants\' ) AND ( "fileFormat" = \'vcf\' ) AND ( "isMultiSpecimen" = \'FALSE\' ) )')$asDataFrame()

#library(vcfR)

#f=vcf.files$id[1]

#res=read.vcfR(synGet(f)$path)
#cr<-create.chromR(res)
#pc<-proc.chromR(cr)

#qc<-chromoqc(pc)


f="/Users/sgosline/.synapseCache/449/6167449/SL102344.vcf"

library(VariantAnnotation)
vcf=readVcf(f,'hg19')
library(TxDb.Hsapiens.UCSC.hg19.knownGene)
txdb <- TxDb.Hsapiens.UCSC.hg19.knownGene
#seqlevels(vcf) <- "chr22"

rd <- rowRanges(vcf)
loc <- locateVariants(rd, txdb, CodingVariants())

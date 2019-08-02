# Simple script to upload a dataframe to Synapse table ( to be converted into CWL for gene-variant-workflow)

project <- "syn5702691"  #parentId

orig_tab <- synGet("syn20554939") #original Table

# load dataframe (maf+annotation)
public_maf <- genome_data  # make sure the data contains proper access restrictions

# A maximum of 152 columns are permitted in a Synapse table, so drop extra irrelevant columns
dropcols <- names(public_maf) %in%c("Source_MAF", "name", "filepath","newfilepath" )
public_maf <- public_maf[!dropcols]

# Dataframes are first converted to CSVs when being uploaded to Synapse tables with a max of 1GB permitted at a time. 
#The code below splits the dataframe into chunks and appends the small chunks to the table.
c <- split(public_maf, (seq(nrow(public_maf))-1) %/% 20000)
for (chunk in c){
  tab <-synapser::Table(orig_tab$properties$id,chunk)
  synapser::synStore(tab)
}

# RNA-seq Salmon alignment workflow

This end-to-end workflow to queries Synapse, acquires FASTQs, aligns them to the `Gencode v29` transcriptome and quantifies transcript counts. The output of the workflow is a tidy data frame that contains all samples, counts, and metadata. This data frame is stored as a Synapse table. 

### Required inputs

We have tried to build the tool to be as generalizable as possible but for now we still require the following inputs:

| Input value | Description | Example |
| --- | --- | --- |
| synapse_config | Path to your Synapse config file | `/home/sgosline/.synapseConfig` |
| indexid | Synapse id of gencode index file | `syn18134565` |
| index-type | Type of index to be passed into Salmon | `gencode`|
| index-dir | Name of directory to create and use in workflow | `gencode_v29`|
| idquery | Specific query to pull down `id`,`specimenID`, and `readPair` for fastq files||
| sample_query | Specific Synapse query to get relevant clinical information to add to annotations||
| parentid | Synapse id to use as destination to upload files||
| tableparentid | This is where the table will live||
| tablename | Name of synapse table to be created or added to

### Running the tool

To run the tool you should.
1. Clone this repository
2. `cd bin/rna-seq-workflow`
3. Create your own YAML or JSON file with the above parameters
4. `cwl-tool synapse-salmon-alignment-workflow.cwl myParams.yml`

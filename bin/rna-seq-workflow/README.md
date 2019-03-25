# RNA-seq Salmon alignment workflow

Below is the documentation for and end-to-end workflow to query Synapse to acquire files to be aligned to the `Gencode v29` transcriptome and quantified.

### Required inputs

We have tried to build the tool to be as generalizable as possible but for now we still require the following inputs:

| Input value | Description | Example |
| --- | --- | --- |
| synapse_config | Path to your Synapse config file | `/home/sgosline/.synapseConfig` |
| indexid | Synapse id of gencode index file | `syn18134565` |
| index-type |||
| index-dir |||
| idquery |||
| sample_query |||
| parentid |||
| scripts |||

### Running the tool

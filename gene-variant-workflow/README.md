# Gene Variant Workflow

This workflow consumes a set of vcf files to create per-sample files and/or a larger tidied data frame of gene variant information in an expanded maf format that includes the source file annotations.

# Running the workflow: 

## Configure the workflow

This is done by editing the following parameters in `gene-variant.yml`: 

- `vep-file-id:` vep file synapse id. we use the GENIE project vep (syn18491780)

- `synapse_config:
  class: File
  path:` absolute path to local synapse config file, e.g. /Users/rallaway/.synapseConfig
  
- `parentid:` maf destination folder on synapse

- `group_by:` e.g. mafid, column of clinical-query to use to join to data

- `input-query:` synapse fileview query to get VCF ids for conversion to maf. eg `SELECT id FROM syn16858331 WHERE ( ( "fileFormat" = 'vcf' ) AND ( "diagnosis" = 'Neurofibromatosis 1' ) AND ( "isMultiSpecimen" = 'FALSE' ) AND ( "assay" = 'exomeSeq' ) ) limit 5`

- `clinical-query:` synapse fileview query with metadata for vcfs, eg `SELECT distinct id as mafid,specimenID,individualID,assay,dataType,sex,consortium,diagnosis,tumorType,species,fundingAgency,resourceType,nf1Genotype,nf2Genotype,studyName from syn16858331`

## Run with cwltool/cwl-runner

Once this file has been updated simply run:
`cwltool --relax-path-checks variant-call-from-synapse.cwl gene-variant.yml`

`--relax-path-checks` is a required flag for this workflow. At the time of writing, `toil` does not support this parameter and therefore cannot run this workflow (see `toil` issue [#1782](https://github.com/DataBiosphere/toil/issues/1782)). 

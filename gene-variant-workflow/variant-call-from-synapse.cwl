class: Workflow
label: variant-call-from-synapse
id: variant-call-from-synapse
cwlVersion: v1.0

inputs:
  vep-file-id:
    type: string
  clinical-query:
    type: string
  #these are for the next step
  input-query:
    type: string
  synapse_config:
    type: File
  parentid:
    type: string
  group_by:
    type: string

requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement

outputs:
  manifest-file:
    type: File
    outputSource: join-fileview-by-specimen/newmanifest
  maf-files:
    type: File[]
    outputSource: get-vcf-run-vep/maffile
  synids:
    type: string[]
    outputSource: get-vcf-run-vep/vcf-id
#  tidied-matrix:
#    type: File
#    outputSource: harmonize-counts/harmonized-df


steps:
  get-fv:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-query-tool.cwl
    in:
        synapse_config: synapse_config
        query: input-query
    out: [query_result]
  get-samples-from-fv:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/sage-workflows-sandbox/master/examples/tools/breakdown-by-row.cwl
    in:
        query_tsv: get-fv/query_result
    out: [id_array]
  get-index-file:
    run: get-index-and-unzip.cwl
    in:
      vep-file-id: vep-file-id
      synapse_config: synapse_config
    out:
      [reference-fasta,dotvep-dir,vep-dir]
  get-vcf-run-vep:
    run: get-vcf-run-vep.cwl
    scatter: vcfid
    in:
      vepdir: get-index-file/vep-dir
      dotvepdir: get-index-file/dotvep-dir
      vcfid: get-samples-from-fv/id_array
      synapse_config: synapse_config
      indexfile: get-index-file/reference-fasta
    out:
      [vcf-id,maffile]
  get-clinical:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-query-tool.cwl
    in:
      synapse_config: synapse_config
      query: clinical-query
    out: [query_result]
  join-fileview-by-specimen:
    run: https://raw.githubusercontent.com/sgosline/synapse-workflow-cwl-tools/master/join-fileview-by-specimen-tool.cwl
    in:
      filelist: get-vcf-run-vep/maffile
      values: get-vcf-run-vep/vcf-id
      manifest_file: get-clinical/query_result
      parentid: parentid
      key: group_by
    out:
      [newmanifest]
 # store-files:
 #   run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-sync-to-synapse-tool.cwl
 #   in:
 #     synapse_config: synapse_config
 #     files: get-vcf-run-vep/maffile
 #     manifest_file: join-fileview-by-specimen/newmanifest
 #   out:
 #     []

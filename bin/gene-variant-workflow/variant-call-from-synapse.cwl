class: Workflow
label: variant-call-from-synapse
id: variant-call-from-synapse
cwlVersion: v1.0

inputs:
  vep-file-id:
    type: string
  clinical-query:
    type: string[]
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
  tidied-matrix:
    type: File
    outputSource: harmonize-counts/harmonized-df

steps:

  get-fv:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-query-tool.cwl
    in:
        synapse_config: synapse_config
        query: input-query
    out: [query_result]
  get-samples-from-fv:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/sage-workflows-sandbox/master/examples/tools/breakdown.cwl
    in:
        query_tsv: get-fv/query_result
        group_by_column: group_by
    out: [names]
  get-index-file:
    run: get-vcf-run-vep.cwl
    in:
      vep-index: vep-file-id
    out:
      [index-file]
  get-vcf-run-vep:
    run: get-vcf-run-vep.cwl
    scatter: [vcf-file-id]
    in:
      vcf-file-id: [get-samples-from-fv/names]
      synapse_config: synapse_config
      indexfile: get-index-file/index-file
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
    store-files:
        run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-sync-to-synapse-tool.cwl
        in:
          synapse_config: synapse_config
          files: run-alignment-by-specimen/quants
          manifest_file: join-fileview-by-specimen/newmanifest
        out:
          []

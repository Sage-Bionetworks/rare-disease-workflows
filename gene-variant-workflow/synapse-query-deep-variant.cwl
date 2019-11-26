class: Workflow
cwlVersion: v1.0
id: synapse-query-deep-variant
label: synapse-query-deep-variant

requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement

inputs:
  - id: indexurl
    type: string
  - id: idquery
    type: string
  - id: sample_query
    type: string
  - id: vcf_parentid
    type: string
  - id: group_by
    type: string
  - id: tableparentid
    type: string[]
  - id: tablename
    type: string[]
  - id: synapse_config
    type: File
  - id: vep-file-id
    type: string
  - id: maf_parentid
    type: string
  - id: num-shards
    type: string
  - id: model-type
    type: string

outputs:
  - id: merged
    type: File
    outputSource: harmonize-counts/merged
  - id: vcffile
    outputSource:
      - run-deepvar-by-specimen/vcf-file
    type: File[]
  - id: manifest
    outputSource:
      - join-fileview-by-specimen/newmanifest
    type: File
  

steps:
  get-index:
    run: steps/get-index-and-unzip.cwl
    in:
      index-url: indexurl
    out:
      [reference-fasta,indexed-fasta]
  get-fv:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-query-tool.cwl
    in:
      synapse_config: synapse_config
      query: idquery
    out: [query_result]
  get-samples-from-fv:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/sage-workflows-sandbox/master/examples/tools/breakdown-by-row.cwl
    in:
      query_tsv: get-fv/query_result
    out: [id_array]
  run-deepvar-by-specimen:
    run: cram-to-bam-index-deepvar.cwl
    scatter: synid
    in:
      synid: get-samples-from-fv/id_array
      synapse_config: synapse_config
      indexed-fa: get-index/indexed-fasta
      index-fa: get-index/reference-fasta
      model-type: model-type
      num-shards: num-shards
    out: [vcf-file,gvcf-file]
  get-clinical:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-query-tool.cwl
    in:
      synapse_config: synapse_config
      query: sample_query
    out: [query_result]
  join-fileview-by-specimen:
    run: https://raw.githubusercontent.com/sgosline/synapse-workflow-cwl-tools/master/join-fileview-by-specimen-tool.cwl
    in:
      filelist: run-deepvar-by-specimen/vcf-file
      values: get-samples-from-fv/id_array
      manifest_file: get-clinical/query_result
      parentid: vcf_parentid
      key: group_by
    out:
      [newmanifest]
  store-files:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-sync-to-synapse-tool.cwl
    in:
      synapse_config: synapse_config
      files: run-deepvar-by-specimen/vcf-file
      manifest_file: join-fileview-by-specimen/newmanifest
    out:
      []
  get-vep-index:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-get-tool.cwl
    in:
      synapse_config: synapse_config
      synapseid: vep-file-id
    out:
      [filepath]
  uz-vep-index:
    run: steps/unzip-dir.cwl
    in:
      file: get-vep-index/filepath
    out:
      [gz-index-file,dotvep-dir,vep-dir]
  run-vep:
    run: steps/run-vep.cwl
    scatter: [input_vcf]
    scatterMethod: dotproduct
    in:
      vepdir: uz-vep-index/vep-dir
      dotvepdir: uz-vep-index/dotvep-dir
      input_vcf: run-deepvar-by-specimen/vcf-file
      ref_fasta: get-index/reference-fasta
    out:
      [maf-file]
  join-mafs-by-specimen:
    run: https://raw.githubusercontent.com/sgosline/synapse-workflow-cwl-tools/master/join-fileview-by-specimen-tool.cwl
    in:
      filelist: run-vep/maf-file
      values: get-samples-from-fv/id_array
      manifest_file: get-clinical/query_result
      parentid: maf_parentid
      key: group_by
    out:
      [newmanifest]
  harmonize-counts:
    run: steps/merge-maf-with-meta-tool.cwl
    in:
      synapse_config: synapse_config
      manifest: join-mafs-by-specimen/newmanifest
      files: run-vep/maf-file
    out:
      [merged]
  add-to-table:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/rare-disease-workflows/master/synapse-table-store/synapse-table-store-tool.cwl
    in:
      synapse_config: synapse_config
      tableparentid: tableparentid
      tablename: tablename
      file: harmonize-counts/merged
    out:
      []

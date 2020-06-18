class: Workflow
cwlVersion: v1.0
id: variant_call_from_synapse
label: variant-call-from-synapse
inputs:
  - id: clinical-query
    type: string
  - id: group_by
    type: string
  - id: input-query
    type: string
  - id: parentid
    type: string
  - id: synapse_config
    type: File
  - id: vep_zip
    type: File
outputs:
  - id: maf-files
    outputSource:
      - get-vcf-run-vep/maffile
    type: 'File[]'
  - id: manifest-file
    outputSource:
      - join-fileview-by-specimen/newmanifest
    type: File
  - id: synids
    outputSource:
      - get-vcf-run-vep/vcf-id
    type: 'string[]'
steps:
  - id: get-clinical
    in:
      - id: query
        source: clinical-query
      - id: synapse_config
        source: synapse_config
    out:
      - id: query_result
    run: >-
      https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/v0.1/synapse-query-tool.cwl
    label: synapse-query-tool
  - id: get-fv
    in:
      - id: query
        source: input-query
      - id: synapse_config
        source: synapse_config
    out:
      - id: query_result
    run: >-
      https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/v0.1/synapse-query-tool.cwl
    label: synapse-query-tool
  - id: get-samples-from-fv
    in:
      - id: query_tsv
        source: get-fv/query_result
    out:
      - id: id_array
    run: >-
      https://raw.githubusercontent.com/Sage-Bionetworks/sage-workflows-sandbox/master/examples/tools/breakdown-by-row.cwl
    label: breakdown-by-row-tool
  - id: get-vcf-run-vep
    in:
      - id: dotvepdir
        source: get_index_and_unzip/dotvep-dir
      - id: indexfile
        source: get_index_and_unzip/reference-fasta
      - id: synapse_config
        source: synapse_config
      - id: vcfid
        source: get-samples-from-fv/id_array
      - id: vepdir
        source: get_index_and_unzip/vep-dir
    out:
      - id: maffile
      - id: vcf-id
    run: get-vcf-run-vep-hg19_to_grch37.cwl
    label: get-vcf-run-vep
    scatter:
      - vcfid
  - id: join-fileview-by-specimen
    in:
      - id: filelist
        source:
          - get-vcf-run-vep/maffile
      - id: key
        source: group_by
      - id: manifest_file
        source: get-clinical/query_result
      - id: parentid
        source: parentid
      - id: values
        source:
          - get-vcf-run-vep/vcf-id
    out:
      - id: newmanifest
    run: >-
      https://raw.githubusercontent.com/sgosline/synapse-workflow-cwl-tools/master/join-fileview-by-specimen-tool.cwl
    label: join-fileview-by-specimen-tool
  - id: get_index_and_unzip
    in:
      - id: vep_zip
        source: vep_zip
    out:
      - id: dotvep-dir
      - id: reference-fasta
      - id: vep-dir
    run: ./get-index-and-unzip-predownloaded.cwl
    label: get-index-and-unzip
requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement

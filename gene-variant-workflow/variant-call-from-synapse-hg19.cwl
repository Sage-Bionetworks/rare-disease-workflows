class: Workflow
cwlVersion: v1.0
id: variant_call_from_synapse
label: variant-call-from-synapse
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
inputs:
  - id: clinical-query
    type: string
    'sbg:x': 0
    'sbg:y': 428
  - id: group_by
    type: string
    'sbg:x': 638.2509155273438
    'sbg:y': 132.5
  - id: input-query
    type: string
    'sbg:x': 0
    'sbg:y': 321
  - id: parentid
    type: string
    'sbg:x': 0
    'sbg:y': 214
  - id: synapse_config
    type: File
    'sbg:x': 0
    'sbg:y': 107
  - id: vep-file-id
    type: string
    'sbg:x': 0
    'sbg:y': 0
outputs:
  - id: maf-files
    outputSource:
      - get-vcf-run-vep/maffile
    type: 'File[]'
    'sbg:x': 898.4661865234375
    'sbg:y': 186
  - id: manifest-file
    outputSource:
      - join-fileview-by-specimen/newmanifest
    type: File
    'sbg:x': 1179.8099365234375
    'sbg:y': 214
  - id: synids
    outputSource:
      - get-vcf-run-vep/vcf-id
    type: 'string[]'
    'sbg:x': 898.4661865234375
    'sbg:y': 79
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
      https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-query-tool.cwl
    label: synapse-query-tool
    'sbg:x': 173.453125
    'sbg:y': 328
  - id: get-fv
    in:
      - id: query
        source: input-query
      - id: synapse_config
        source: synapse_config
    out:
      - id: query_result
    run: >-
      https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-query-tool.cwl
    label: synapse-query-tool
    'sbg:x': 173.453125
    'sbg:y': 207
  - id: get-index-file
    in:
      - id: synapse_config
        source: synapse_config
      - id: vep-file-id
        source: vep-file-id
    out:
      - id: dotvep-dir
      - id: reference-fasta
      - id: vep-dir
    run: get-index-and-unzip.cwl
    label: get-index-and-unzip
    'sbg:x': 173.453125
    'sbg:y': 79
  - id: get-samples-from-fv
    in:
      - id: query_tsv
        source: get-fv/query_result
    out:
      - id: id_array
    run: >-
      https://raw.githubusercontent.com/Sage-Bionetworks/sage-workflows-sandbox/master/examples/tools/breakdown-by-row.cwl
    label: breakdown-by-row-tool
    'sbg:x': 451.26654052734375
    'sbg:y': 214
  - id: get-vcf-run-vep
    in:
      - id: dotvepdir
        source: get-index-file/dotvep-dir
      - id: indexfile
        source: get-index-file/reference-fasta
      - id: synapse_config
        source: synapse_config
      - id: vcfid
        source: get-samples-from-fv/id_array
      - id: vepdir
        source: get-index-file/vep-dir
    out:
      - id: maffile
      - id: vcf-id
    run: get-vcf-run-vep-hg19_to_grch37.cwl
    label: get-vcf-run-vep
    scatter:
      - vcfid
    'sbg:x': 638.2509155273438
    'sbg:y': 267.5
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
    'sbg:x': 898.4661865234375
    'sbg:y': 321
requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement

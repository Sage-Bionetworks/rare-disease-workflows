class: Workflow
cwlVersion: v1.0
id: get_index_and_unzip
label: get-index-and-unzip
inputs:
  - id: vep_zip
    type: File
outputs:
  - id: dotvep-dir
    outputSource:
      - unzip-vep-index/dotvep-dir
    type: Directory
  - id: reference-fasta
    outputSource:
      - unzip-fasta-file/index-file
    type: File
  - id: vep-dir
    outputSource:
      - unzip-vep-index/vep-dir
    type: Directory
steps:
  - id: unzip-fasta-file
    in:
      - id: file
        source: unzip-vep-index/gz-index-file
    out:
      - id: index-file
    run: steps/unzip-file.cwl
    label: unzip-file
  - id: unzip-vep-index
    in:
      - id: file
        source: vep_zip
    out:
      - id: dotvep-dir
      - id: gz-index-file
      - id: vep-dir
    run: steps/unzip-dir.cwl
    label: unzip-dir
requirements: []

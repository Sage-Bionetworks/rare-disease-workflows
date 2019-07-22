class: Workflow
cwlVersion: v1.0
id: get_index_and_unzip
label: get-index-and-unzip
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
inputs:
  - id: vep_zip
    type: File
    'sbg:x': 248.20855712890625
    'sbg:y': 93.5
outputs:
  - id: dotvep-dir
    outputSource:
      - unzip-vep-index/dotvep-dir
    type: Directory
    'sbg:x': 596.8858642578125
    'sbg:y': 214
  - id: reference-fasta
    outputSource:
      - unzip-fasta-file/index-file
    type: File
    'sbg:x': 752.6514892578125
    'sbg:y': 107
  - id: vep-dir
    outputSource:
      - unzip-vep-index/vep-dir
    type: Directory
    'sbg:x': 596.8858642578125
    'sbg:y': 0
steps:
  - id: unzip-fasta-file
    in:
      - id: file
        source: unzip-vep-index/gz-index-file
    out:
      - id: index-file
    run: steps/unzip-file.cwl
    label: unzip-file
    'sbg:x': 596.8858642578125
    'sbg:y': 107
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
    'sbg:x': 396.8702697753906
    'sbg:y': 93
requirements: []

id: get-index-and-unzip
label: get-index-and-unzip
cwlVersion: v1.0
class: Workflow


inputs:
  vep-file-id:
    type: string
  synapse_config:
    type: File

outputs:
  reference-fasta:
    type: File
    outputSource: unzip-fasta-file/index-file
  dotvep-dir:
    type: Directory
    outputSource: unzip-vep-index/dotvep-dir
  vep-dir:
    type: Directory
    outputSource: unzip-vep-index/vep-dir

steps:
  get-vep-index:
    run:  https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-get-tool.cwl
    in:
      synapseid: vep-file-id
      synapse_config: synapse_config
    out: [filepath]
  unzip-vep-index:
    run: steps/unzip-dir.cwl
    in:
      file: get-vep-index/filepath
    out: [index-file,dotvep-dir,vep-dir]
  unzip-fasta-file:
    run: steps/unzip-file.cwl
    in:
      file: unzip-vep-index/gz-index-file
    out:
      [index-file]

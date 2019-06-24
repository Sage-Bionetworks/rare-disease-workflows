id: get-index-and-unzip
label: get-index-and-unzip
cwlVersion: v1.0
class: Workflow


inputs:
  vep-file-id:
    type: string
  synapse_config:
    type: File
  indexfile: 
    type: File

outputs:
  reference-fasta:
    type: File
    outputSource: unzip-fasta-file/index-file

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
    out: [index-dir]
  unzip-fasta-file:
    run: steps/unzip-file.cwl
    in:
      file: indexfile
    out:
      [index-file]

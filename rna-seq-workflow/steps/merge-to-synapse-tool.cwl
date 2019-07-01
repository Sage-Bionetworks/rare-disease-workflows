label: merge-to-synapse-tool
id: merge-to-synapse-tool
cwlVersion: v1.0
class: CommandLineTool
baseCommand: Rscript

requirements:
   - class: DockerRequirement
     dockerPull: nfosi/merge-counts-to-synapse

arguments:
  - /usr/local/bin/merge-aligned-files.R

inputs:
  manifest:
    type: File
    inputBinding:
      position: 1
      prefix: --manifest
  files:
    type: File[]
    inputBinding:
      position: 2
      prefix: --files
      itemSeparator: ,
  tableparentid:
    type: string
    inputBinding:
      position: 3
      prefix: --tableparentid
  tablename:
    type: string
    intputBinding:
      position: 4
      prefix: --tablename

outputs:
  []

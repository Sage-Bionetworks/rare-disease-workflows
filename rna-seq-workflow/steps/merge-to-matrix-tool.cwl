label: merge-to-matrix-tool
id: merge-to-matrix-tool
cwlVersion: v1.0
class: CommandLineTool
baseCommand: Rscript

requirements:
   - class: DockerRequirement
     dockerPull:
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
  sampnames:
    type: string[]
    inputBinding:
      position: 3
      prefix: --samps
      itemSeparator: ,

outputs:
  [harmonized-df]

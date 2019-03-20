#!/usr/bin/env cwl-runner
class: CommandLineTool
id: salmon-quant-tool
label: salmon-quant-tool
cwlVersion: v1.0

requirements:
  - class: DockerRequirement
    dockerPull: combinelab/salmon

baseCommand: [salmon, quant, "-l A"]

inputs:
  mates1:
    type: File[]
    inputBinding:
      position: 1
      prefix: '-1'
      itemSeparator: " "
  mates2:
    type: File[]
    inputBinding:
      position: 2
      prefix: '-2'
      itemSeparator: " "
  index-dir:
    type: Directory
    inputBinding:
      prefix: -i
      position: 3
outputs:
  quants:
    type: File
    outputBinding:
      glob: "*.sf"


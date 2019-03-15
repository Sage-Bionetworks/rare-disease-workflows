#!/usr/bin/env cwl-runner
class: CommandLineTool
id: salmon-quant-tool
label: salmon-quant-tool
cwlVersion: v1.0

requirements:
  -class: DockerRequirement
    dockerPull: combinelab/salmon

baseCommand: [salmon, quant, "-l A"]

inputs:
  mates1:
    type: array
    items: File
    inputBinding:
      prefix: -1
  mates2:
    type: array
    items: File
    inputBinding:
      prefix: -2
  index-dir:
    type: string
    inputBinding:
      prefix: -i

outputs:
  quants:
    type: File
    outputBinding:
      glob: "*.sf"

baseCommand: salmon

#!/usr/bin/env cwl-runner
class: CommandLineTool
id: salmon-index-tool
label: salmon-index-tool
cwlVersion: v1.0

requirements:
  - class: DockerRequirement
    dockerPull: combinelab/salmon

baseCommand: [salmon, index]

inputs:
  index-file:
    type: File
    doc: index file
    inputBinding:
      position: 2
      prefix: -t
  index-type:
    type: string
    inputBinding:
      position: 1
      prefix: --
      separate: False
  index-dir:
    type: string
    inputBinding:
      position: 3
      prefix: -i

outputs:
  indexDir:
    type: Directory
    outputBinding:
      glob: "*"

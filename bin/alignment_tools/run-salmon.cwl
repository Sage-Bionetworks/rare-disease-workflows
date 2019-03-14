#!/usr/bin/env cwl-runner
class: CommandLineTool
id: run-salmon
label: run-salmon
cwlVersion: 1.0

requirements:
  -class: DockerRequirement
    dockerPull: combinelab/salmon

inputs:
  mates1:
    type: array
    items: string
    inputBinding:
      prefix: -1
  mates2:
    type: array
    items: string
    inputBinding:
      prefix: -2
  index:
    type: File

outputs:
  quants:
    type: File
    outputBinding:
      glob: "*.sf"

baseCommand: salmon

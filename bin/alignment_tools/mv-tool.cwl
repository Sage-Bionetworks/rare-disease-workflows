#!/usr/bin/env cwl-runner
class: CommandLineTool
id: mv-tool
label: mv-tool
cwlVersion: v1.0

baseCommand: mv

inputs: 
  fname: 
      type: File
      inputBinding:
         position: 1
  newname:
      type: string
      inputBinding:
         position: 2
outputs:
  newfile:
      type: File
      outputBinding:
         glob: "*"

#!/usr/bin/env cwl-runner
class: CommandLineTool
id: mv-tool
label: mv-tool
cwlVersion: v1.0

baseCommand: mv

requirements:
  InlineJavascriptRequirement: {}

arguments: [$(inputs.fname),$(inputs.newname+'.sf')]

inputs:
  fname:
      type: File
  newname:
      type: string


outputs:
  newfile:
      type: File
      outputBinding:
         glob: "*"

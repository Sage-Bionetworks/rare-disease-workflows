label: unzip-file
id: unzip-file
class: CommandLineTool
cwlVersion: v1.0
baseCommand: unzip

inputs:
  file:
    type: File
    inputBinding:
      position: 1
outputs:
  index-file:
    type: File
    outputBinding:
      glob: "*"

label: rm
id: rm
cwlVersion: v1.0
class: CommandLineTool
baseCommand: rm

inputs:
  file:
    type: File
    inputBinding:
      position: 1

outputs:
  []

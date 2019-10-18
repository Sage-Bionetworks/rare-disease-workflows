cwlVersion: v1.0
class: CommandLineTool
id: ftp-get

hints:
  DockerRequirement:
    dockerPull: cirrusci/wget:latest

baseCommand: [wget]

arguments:
  - valueFrom: $(inputs.path)
  - valueFrom: .

inputs:
  path:
    type: string
    inputBinding:
      position: 1

outputs:
  []

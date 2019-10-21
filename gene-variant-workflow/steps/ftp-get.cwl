cwlVersion: v1.0
class: CommandLineTool
id: ftp-get

hints:
  DockerRequirement:
    dockerPull: cirrusci/wget:latest

baseCommand: [wget]

requirements:
  - class: InlineJavascriptRequirement

inputs:

  url:
    type: string
    inputBinding:
      position: 1

outputs:

  output:
    type: File
    outputBinding:
      glob: $(inputs.url.split("/").slice(-1))

label: unzip-file
id: unzip-file
class: CommandLineTool
cwlVersion: v1.0
baseCommand: bgzip
stdout: index.fa
arguments: ["-d","-c"]

inputs:
  infile:
    type: File
    inputBinding:
      position: 1
outputs:
  index-file:
    type: stdout

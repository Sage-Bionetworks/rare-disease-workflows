label: unzip-file
id: unzip-file
class: CommandLineTool
cwlVersion: v1.0
baseCommand: gzip
stdout: index.fa
arguments: ["-d","-c"]

inputs:
  file:
    type: File
    inputBinding:
      position: 1
outputs:
  index-file:
    type: stdout  

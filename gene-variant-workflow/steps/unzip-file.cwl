label: unzip-file
id: unzip-file
class: CommandLineTool
cwlVersion: v1.0
baseCommand: bgzip
stdout: index.fa
arguments: ["-d","-c"]

requirements:
  - class: DockerRequirement
    dockerPull: miguelpmachado/htslib:1.9

inputs:
  infile:
    type: File
    inputBinding:
      position: 1
outputs:
  index-file:
    type: stdout

label: unzip-dir
id: unzip-dir
class: CommandLineTool
cwlVersion: v1.0
baseCommand: unzip

inputs:
  file:
    type: File
    inputBinding:
      position: 1
outputs:
   index-dir:
    type: File
    outputBinding:
      glob: ".vep/homo_sapiens/95_GRCh37/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa.gz"

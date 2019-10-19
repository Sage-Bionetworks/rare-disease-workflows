cwlVersion: v1.0
id: samtools-index
label: samtools-index
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: biocontainers/samtools

arguments:
  - id: command
    valueFrom: $(inputs.arg)
  - id: filepath
    valueFrom: $(inputs.filepath)

inputs:
  - id: arg
    type: string
    inputBinding:
      position: 1
  - id: filepath
    type: string
    inputBinding:
      position: 2

outputs:
  indexed-file:
    type: File
    outputBinding:
      glob: '*'

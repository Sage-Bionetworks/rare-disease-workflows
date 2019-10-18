cwlVersion: v1.0
id: samtools-index
label: samtools-index
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: biocontainers/samtools

baseCommand: [index]

arguments:
  - valueFrom: $(inputs.path)

inputs:
  path:
    type: string
    inputBinding:
      position: 1

outputs:
  []

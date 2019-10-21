cwlVersion: v1.0
id: samtools-index
label: samtools-index
class: CommandLineTool

requirements:
 - class: DockerRequirement
   dockerPull: biocontainers/samtools:v1.9-4-deb_cv1
 - class: StepInputExpressionRequirement

arguments:
  - id: samtools
    valueFrom: samtools
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
    type: File
    inputBinding:
      position: 2

outputs:
  indexed-files:
    type: File[]
    outputBinding:
      glob: '*'

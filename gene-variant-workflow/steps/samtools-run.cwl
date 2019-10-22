cwlVersion: v1.0
id: samtools-index
label: samtools-index
class: CommandLineTool

requirements:
 - class: DockerRequirement
   dockerPull: biocontainers/samtools:v1.9-4-deb_cv1
   dockerOutputDirectory: /tmp
 - class: StepInputExpressionRequirement
 - class: InitialWorkDirRequirement
   listing: 
     -$(inputs.fpath)

arguments:
  - id: samtools
    valueFrom: samtools
  - id: command
    valueFrom: $(inputs.arg)
  - id: filepath
    valueFrom: $(inputs.fpath)

inputs:
  - id: arg
    type: string
  - id: fpath
    type: File

outputs:
  indexed-files:
    type: File[]
    outputBinding:
      glob: '*'

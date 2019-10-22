cwlVersion: v1.0
id: samtools-index
label: samtools-index
class: CommandLineTool

baseCommand:
  - samtools

requirements:
 - class: DockerRequirement
   dockerPull: biocontainers/samtools:v1.9-4-deb_cv1
 - class: InitialWorkDirRequirement
   listing:
     - $(inputs.fpath)

inputs:
  - id: command
    type: string
    default: "faidx"
    inputBinding:
      position: 1
  - id: fpath
    type: File
    inputBinding:
      position: 2

outputs:
  - id: indexed_file
    type: File
    outputBinding:
      glob: "*ai"

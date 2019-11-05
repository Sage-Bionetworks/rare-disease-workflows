cwlVersion: v1.0
id: samtools-view
label: samtools-view
class: CommandLineTool

baseCommand:
  - samtools
  - view

requirements:
 - class: DockerRequirement
   dockerPull: biocontainers/samtools:v1.9-4-deb_cv1
 - class: InitialWorkDirRequirement
   listing:
     - $(inputs.fpath)
     - $(inputs.ref_genome)

inputs:
  - id: ref_genome
    type: File
    inputBinding:
      position: 1
      prefix: -T
  - id: output_str
    type: string
    inputBinding:
      position: 2
      prefix: -o
  - id: fpath
    type: File
    inputBinding:
      position: 3


outputs:
  - id: bam_file
    type: File
    outputBinding:
      glob: "*bam"

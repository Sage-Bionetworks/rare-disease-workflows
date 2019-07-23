class: CommandLineTool
cwlVersion: v1.0
id: vcf_zip_check
requirements:
  - class: DockerRequirement
    dockerPull: nfosi/zipcheck
  - class: InitialWorkDirRequirement
    listing: [ $(inputs.file) ]
baseCommand:
  - sh
  - /usr/local/bin/zipcheck.sh
inputs:
  - id: file
    type: File
    inputBinding:
      position: 1
outputs:
  - id: out-file
    type: File
    outputBinding:
      glob: '*.vcf'
label: vcf-zip-check
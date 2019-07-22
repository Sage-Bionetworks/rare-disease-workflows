class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
id: liftover_vcf
baseCommand:
  - bash
  - /usr/working/liftover-vcf.sh
inputs:
  - id: hg19vcf
    type: File
    inputBinding:
      position: 1
      valueFrom: $(self.basename)
outputs:
  - id: hg38vcf
    type: File
    outputBinding:
      glob: '*hg38.vcf'
  - id: rejected
    type: File?
    outputBinding:
      glob: '*rej.vcf'
label: liftover-vcf
requirements:
  - class: ResourceRequirement
    ramMin: 8000
    coresMin: 0
  - class: DockerRequirement
    dockerPull: nfosi/liftover-hg19-to-hg38
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.hg19vcf)
        writable: true
  - class: InlineJavascriptRequirement

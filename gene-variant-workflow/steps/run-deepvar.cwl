cwlVersion: v1.0
id: run-deepvar
label: run-deepvar
class: CommandLineTool

requirements:
  - class: DockerRequirement
    dockerPull: gcr.io/deepvariant-docker/deepvariant:0.8.0
  - class: InitialWorkDirRequirement
    listing:
      - $(inputs.bam_file)
      - $(inputs.ref)
      - $(inputs.bam_index)
      - $(inputs.indexed_fa)
  - class: InlineJavascriptRequirement
arguments:
  - valueFrom: $(inputs.output_prefix + ".vcf")
    prefix: --output_vcf
  - valueFrom: $(inputs.output_prefix + ".g.vcf")
    prefix: --output_gvcf

baseCommand:
  - /opt/deepvariant/bin/run_deepvariant

inputs:
  model_type:
    type: string
    inputBinding:
      position: 1
      prefix: --model_type
  ref:
    type: File
    inputBinding:
      position: 2
      prefix: --ref
  bam_file:
    type: File
    inputBinding:
      position: 3
      prefix: --reads
  num_shards:
    type: string
    inputBinding:
      position: 6
      prefix: --num_shards
  bam_index:
    type: File
  indexed_fa:
    type: File
  output_prefix:
    type: string

outputs:
  vcf-file:
    type: File
    outputBinding:
      glob: "*.vcf"
  gvcf-file:
    type: File
    outputBinding:
      glob: "*.g.vcf"

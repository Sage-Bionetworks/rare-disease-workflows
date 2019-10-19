cwlVersion: v1.0
id: run-deepvar
label: run-deepvar
class: Workflow

hints:
  DockerRequirement:
    dockerPull: gcr.io/deepvariant-docker/deepvariant:0.8.0

arguments: [/opt/deepvariant/bin/run_deepvariant]

inputs:
  model-type:
    type: string
    inputBinding: 1
    prefix: --model_type
  ref:
    type: File
    inputBinding: 2
    prefix: --ref
  bam-file:
    type: File
    inputBinding: 3
    prefix: --reads
  output-vcf:
    type: string
    inputBinding: 4
    prefix: --output_vcf
  output-gvcf:
    type: string
    inputBinding: 5
    prefix: --output_gvcf
  num-shards:
    type: string
    inputBinding: 6
    prefix: --num_shards
  bam-index:
    type: File

outputs:

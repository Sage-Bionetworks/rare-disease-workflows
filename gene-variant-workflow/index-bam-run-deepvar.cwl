cwlVersion: v1.0
label: index-bam-run-deepvar
id: index-bam-run-deepvar
class: Workflow

inputs:
  synid:
    type: string
  synapse_config:
    type: File
  index-file:
    type: File
  samtools-arg:
    type: string
    valueFrom: index
  model-type:
    type: string
  output-vcf:
    type: string
  output-gvcf:
    type: string
  num-shards:
    type: string



requirements:
  - class: StepInputExpressionRequirement


outputs:
  vcffile:
    valueFrom: run-deepvar/vcf-file

steps:
  get-file:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-get-tool.cwl
    in:
      synapse_config: synapse_config
      synapseid: synid
    out:
      [filepath]
  index-bam:
    run: steps/samtools-run.cwl
    in:
      filepath: get-file/filepath
      arg:
        valueFrom: index
    out:
      [indexed-bam]
  run-deepvar:
    run: steps/run-deepvar.cwl
    in:
      bam-file: get-file/filepath
      indexedbam: index-bam/indexed-bam
      ref: index-file
      model-type: model-type
    out:
      [vcf-file]

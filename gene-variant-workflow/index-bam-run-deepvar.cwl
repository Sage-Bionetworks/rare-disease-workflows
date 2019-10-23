cwlVersion: v1.0
label: index-bam-run-deepvar
id: index-bam-run-deepvar
class: Workflow

inputs:
  synid:
    type: string
  synapse_config:
    type: File
  index-fa:
    type: File
  samtools-arg:
    type: string
    default: "index"
  model-type:
    type: string
  num-shards:
    type: string
  indexed-fa:
    type: File



requirements:
  - class: StepInputExpressionRequirement


outputs:
  vcffile:
    type: File
    outputSource: run-deepvar/vcf-file

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
      fpath: get-file/filepath
      command:
        valueFrom: index
    out:
      [indexed_file]
  run-deepvar:
    run: steps/run-deepvar.cwl
    in:
      bam_file: get-file/filepath
      bamr_ndex: index-bam/indexed_file
      ref: index-fa
      model_type: model-type
      indexed_fa: indexed-fa
      bam_index: index-bam/indexed_file
      num_shards: num-shards
      output_prefix: synid

    out:
      [vcf-file,gvcf-file]

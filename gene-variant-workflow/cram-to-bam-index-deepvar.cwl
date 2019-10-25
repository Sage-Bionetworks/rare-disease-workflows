cwlVersion: v1.0
label: index-bam-run-deepvar
id: index-bam-run-deepvar
class: Workflow

inputs:
  synid:
    type: string
  synapse_config:
    type: File
  indexed-fa:
    type: File
  index-fa:
    type: File
  model-type:
    type: string
  num-shards:
    type: string
  samtools-arg:
    type: string
    default: "index"

requirements:
  - class: StepInputExpressionRequirement

outputs:
  vcf-file:
    type: File
    outputSource: run-deepvar/vcf-file
  gvcf-file:
    type: File
    outputSource: run-deepvar/gvcf-file

steps:
  get-file:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-get-tool.cwl
    in:
      synapse_config: synapse_config
      synapseid: synid
    out:
      [filepath]
  cram-to-bam:
    run: steps/samtools-view.cwl
    in:
      fpath: get-file/filepath
      ref_genome: index-fa
      output_str:
        valueFrom: $(inputs.synid + ".bam")
    out:
      bam_file
  index-bam:
    run: steps/samtools-run.cwl
    in:
      fpath: cram-to-bam/bam_file
      command:
        valueFrom: index
    out:
      [indexed_file]
  run-deepvar:
    run: steps/run-deepvar.cwl
    in:
      bam_file: get-file/filepath
      bam_index: index-bam/indexed_file
      ref: index-fa
      model_type: model-type
      indexed_fa: indexed-fa
      num_shards: num-shards
      output_prefix: synid
    out:
      [vcf-file,gvcf-file]

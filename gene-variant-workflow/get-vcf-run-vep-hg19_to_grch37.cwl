class: Workflow
cwlVersion: v1.0
id: get_vcf_run_vep
label: get-vcf-run-vep
inputs:
  - id: dotvepdir
    type: Directory
  - id: indexfile
    type: File
  - id: synapse_config
    type: File
  - id: vcfid
    type: string
  - id: vepdir
    type: Directory
outputs:
  - id: maffile
    outputSource:
      - run-vep/maf-file
    type: File
  - id: vcf-id
    outputSource:
      - vcfid
    type: string
steps:
  - id: get-vcf
    in:
      - id: synapse_config
        source: synapse_config
      - id: synapseid
        source: vcfid
    out:
      - id: filepath
    run: >-
      https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-get-tool.cwl
  - id: vcf_zip_check
    in:
      - id: file
        source: get-vcf/filepath
    out:
      - id: out-file
    run: steps/vcf-zip-check.cwl
    label: vcf-zip-check
  - id: run-vep
    in:
      - id: dotvepdir
        source: dotvepdir
      - id: input_vcf
        source:
          - liftover-vcf/grch37vcf
      - id: output-maf
        source: get-vcf/filepath
        valueFrom: $(self.nameroot + '.maf')
      - id: ref_fasta
        source: indexfile
      - id: vepdir
        source: vepdir
    out:
      - id: maf-file
    run: steps/run-vep.cwl
    label: run-vep
  - id: liftover-vcf
    in:
      - id: hg19vcf
        source: vcf_zip_check/out-file
    out:
      - id: grch37vcf
      - id: rejected
    run: steps/liftover_hg19togrch37.cwl
    label: liftover-vcf
requirements:
  - class: MultipleInputFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement

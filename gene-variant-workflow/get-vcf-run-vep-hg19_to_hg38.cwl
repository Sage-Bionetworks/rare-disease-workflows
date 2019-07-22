class: Workflow
cwlVersion: v1.0
id: get_vcf_run_vep
label: get-vcf-run-vep
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
inputs:
  - id: dotvepdir
    type: Directory
    'sbg:x': 591
    'sbg:y': 322
  - id: indexfile
    type: File
    'sbg:x': 431.8702697753906
    'sbg:y': -143
  - id: synapse_config
    type: File
    'sbg:x': 0
    'sbg:y': 214
  - id: vcfid
    type: string
    'sbg:x': 0
    'sbg:y': 107
  - id: vepdir
    type: Directory
    'sbg:x': 0
    'sbg:y': 0
outputs:
  - id: maffile
    outputSource:
      - run-vep/maf-file
    type: File
    'sbg:x': 890
    'sbg:y': 17
  - id: vcf-id
    outputSource:
      - vcfid
    type: string
    'sbg:x': 173.453125
    'sbg:y': 46.5
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
    'sbg:x': 288.453125
    'sbg:y': 98.5
  - id: vcf_zip_check
    in:
      - id: file
        source: get-vcf/filepath
    out:
      - id: out-file
    run: steps/vcf-zip-check.cwl
    label: vcf-zip-check
    'sbg:x': 421
    'sbg:y': 174
  - id: run-vep
    in:
      - id: dotvepdir
        source: dotvepdir
      - id: input_vcf
        source: liftover_vcf/hg38vcf
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
    'sbg:x': 700
    'sbg:y': 49
  - id: liftover_vcf
    in:
      - id: hg19vcf
        source: vcf_zip_check/out-file
    out:
      - id: hg38vcf
      - id: rejected
    run: steps/liftover_hg19tohg38.cwl
    label: liftover-vcf
    'sbg:x': 538
    'sbg:y': 127
requirements:
  - class: MultipleInputFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement

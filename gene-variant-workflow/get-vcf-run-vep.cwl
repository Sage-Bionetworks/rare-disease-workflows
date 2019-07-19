class: Workflow
cwlVersion: v1.0
id: get_vcf_run_vep
label: get-vcf-run-vep
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
inputs:
  - id: dotvepdir
    type: Directory
    'sbg:x': 400.8702697753906
    'sbg:y': 305
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
    'sbg:x': 785.1983642578125
    'sbg:y': 107
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
    'sbg:x': 438.8702697753906
    'sbg:y': 178
  - id: run-vep
    in:
      - id: dotvepdir
        source: dotvepdir
      - id: input_vcf
        source: vcf_zip_check/out-file
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
    'sbg:x': 635.9327392578125
    'sbg:y': 111
requirements: 
  - class: StepInputExpressionRequirement


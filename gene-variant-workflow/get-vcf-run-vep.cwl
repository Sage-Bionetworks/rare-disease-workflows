class: Workflow
label: get-vcf-run-vep
id: get-vcf-run-vep
cwlVersion: v1.0

requirements:
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
inputs:
  indexfile:
    type: File
  vcfid:
    type: string
  synapse_config:
    type: File
  vepdir:
    type: Directory
  dotvepdir:
    type: Directory

outputs:
  vcf-id:
    type: string
    outputSource: vcfid
  maffile:
    type: File
    outputSource: run-vep/maf-file

steps:
  get-vcf:
    run:  https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-get-tool.cwl
    in:
      synapseid: vcfid
      synapse_config: synapse_config
    out: [filepath]
 # make-maf-file:
 #   run: steps/make-maf-file.cwl
 #   in:
 #     vcf: get-vcf/filepath
 #   out: [maf_file_name]
  run-vep:
    run: steps/run-vep.cwl
    in:
      dotvepdir: dotvepdir
      vepdir: vepdir
      ref_fasta: indexfile
      input_vcf: get-vcf/filepath
      output-maf:
         source: get-vcf/filepath
         valueFrom: $(self.nameroot + '.maf')
    out: [maf-file]

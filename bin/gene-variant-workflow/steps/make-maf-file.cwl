id: make-maf-file
label: make-maf-file
cwlVersion: v1.0
class: ExpressionTool


requirements:
  InlineJavascriptRequirement: {}

expression: |
  ${ var maf_file_name=(inputs.vcf.nameroot) + ".maf";
     return maf_file_name;
  }

inputs:
  vcf:
    type: File
outputs:
  maf_file_name:
    type: string

label: run-vep
id: run-vep
cwlVersion: v1.0
class: CommandLineTool
baseCommand: perl

requirements:
  - class: DockerRequirement
    dockerPull: sgosline/vcf2maf
  - class: InitialWorkDirRequirement
    listing:
       - entry: $(inputs.input_vcf)
         writable: true
       - entry: $(inputs.ref_fasta)
         writable: true
       - entry: $(inputs.vepdir)
         writable: true
       - entry: $(inputs.dotvepdir)
         writable: true
  - class: InlineJavascriptRequirement

inputs:
  vepdir:
    type: Directory
  dotvepdir:
    type: Directory
  input_vcf:
    type: File
    inputBinding:
      position: 1
      prefix: --input-vcf
  output-maf:
    type: string?
    inputBinding:
      position: 2
      prefix: --output-maf
      valueFrom: $(inputs.input_vcf.basename + ".maf")
  ref_fasta:
    type: File
    inputBinding:
      position: 3
      prefix: --ref-fasta

outputs:
  maf-file:
    type: File
    outputBinding:
      glob: "*.maf"

arguments:
  ["/root/vcf2maf-1.6.17/vcf2maf.pl"]

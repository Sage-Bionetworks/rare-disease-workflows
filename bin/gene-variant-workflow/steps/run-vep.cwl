label: run-vep
id: run-vep
cwlVersion: v1.0
class: CommandLineTool
baseCommand: perl #/root/vcf2maf-1.6.17/vcf2maf.pl

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
    type: string
    inputBinding:
      position: 2
      prefix: --output-maf
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

#  --input-vcf /root/vcf2maf-1.6.17/tests/test.vcf --output-maf /root/vcf2maf-1.6.17/tests/test.vep.maf --ref-fasta /root/.vep/homo_sapiens/95_GRCh37/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa

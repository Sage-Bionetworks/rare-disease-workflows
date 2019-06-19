label: run-vep
id: run-vep
cwlVersion: v1.0
class: CommandLineTool
baseCommand: perl

requirements:
  - class: DockerRequirement
    dockerPull: sagebionetworks/genie:vcf2maf-develop

inputs:
  input-vcf:
    type: File
    inputBinding:
      position: 2
      prefix: --input-vcf
  output-maf:
    type: string
    inputBinding:
      position: 3
      prefix: --output-maf
  ref-fasta:
    type: File
    inputBinding:
      position: 4
      prefix: --ref-fasta

outputs:
  maf-file:
    type: File
    outputBinding:
      glob: "*.maf"

arguments:
  - /root/vcf2maf-1.6.17/vcf2maf.pl

#  --input-vcf /root/vcf2maf-1.6.17/tests/test.vcf --output-maf /root/vcf2maf-1.6.17/tests/test.vep.maf --ref-fasta /root/.vep/homo_sapiens/95_GRCh37/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa

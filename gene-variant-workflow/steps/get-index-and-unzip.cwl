id: get-index-and-unzip
label: get-index-and-unzip
cwlVersion: v1.0
class: Workflow


inputs:
  index-url:
    type: string

requirements:
  - class: StepInputExpressionRequirement

outputs:
  reference-fasta:
    type: File
    outputSource: unzip-fasta-file/index-file
  indexed-fasta:
    type: File
    outputSource: index-fasta/indexed_file

steps:
  get-index:
    run: ftp-get.cwl
    in:
      url: index-url
    out: [output]
  unzip-fasta-file:
    run: unzip-file.cwl
    in:
      infile: get-index/output
    out:
      [index-file]
  index-fasta:
    run: samtools-run.cwl
    in:
      fpath: unzip-fasta-file/index-file
      arg:
        valueFrom: faidx
    out:
      [indexed_file]

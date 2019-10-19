id: get-index-and-unzip
label: get-index-and-unzip
cwlVersion: v1.0
class: Workflow


inputs:
  index-url:
    type: string
  samtools-arg:
    type: string
    valueFrom: faindex

outputs:
  reference-fasta:
    type: File
    outputSource: index-fasta/indexed-file


steps:
  get-index:
    run: ftp-get.cwl
    in:
      url: index-url
    out: [filepath]
  unzip-fasta-file:
    run: unzip-file.cwl
    in:
      file: get-index/filepath
    out:
      [index-file]
  index-fasta:
    run: samtools-run.cwl
    in:
      filepath: unzip-fasta-file/index-file
      arg: samtools-arg
    out:
      [indexed-file]

id: get-index-and-unzip
label: get-index-and-unzip
cwlVersion: v1.0
class: Workflow


inputs:
  index-url:
    type: string

outputs:
  reference-fasta:
    type: File
    outputSource: unzip-fasta-file/index-file


steps:
  get-index:
    run:  ftp-get.cwl
    in:
      path: index-url
    out: [filepath]
  unzip-fasta-file:
    run: unzip-file.cwl
    in:
      file: get-index/filepath
    out:
      [index-file]

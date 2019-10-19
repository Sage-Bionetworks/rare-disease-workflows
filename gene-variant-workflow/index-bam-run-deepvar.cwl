cwlVersion: v1.0
label: index-bam-run-deepvar
id: index-bam-run-deepvar


inputs:
  synid:
    type: string
  synapse_config:
    type: File
  index-file:
    type: File
  samtools-arg:
    type: string
    valueFrom: index



outputs:
  vcffile:
    valueFrom: run-deepvar/vcf-file

steps:
  get-file:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-get-tool.cwl
    in:
      synapse_config: synapse_config
      synapseid: synid
    out:
      [filepath]
  index-file:
    run: steps/samtools-run.cwl
    in:
      path: index-file
    out:
      [indexed-file]
  run-deepvar:
    run: steps/run-deepvar.cwl
    in:
      bamfile:
      indexedbam:
      faindex:

    out:
      vcf-file

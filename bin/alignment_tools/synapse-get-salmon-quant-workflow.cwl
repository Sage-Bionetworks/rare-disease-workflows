class: Workflow
label: synapse-get-salmon-quant-workflow
id: synapse-get-salmon-quant-workflow
cwlVersion: v1.0

inputs:
  mate1-ids:
    type: File
  mate2-ids:
    type: File
#  index-dir:
 #   type: Directory
  synapse_config:
    type: File
  specimenId:
    type: string

outputs: []

requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement


steps:
  get-mate1-files:
    run: out-to-array-tool.cwl
    in:
      datafile: mate1-ids
    out: [anyarray]
  download-mate1-files:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-command-line-cwl-tools/master/synapse-get-tool.cwl
    scatter: synapseid
    in:
      synapseid: get-mate1-files/anyarray
      synapse_config: synapse_config
    out: [filepath]
  get-mate2-files:
    run: out-to-array-tool.cwl
    in:
      datafile: mate2-ids
    out: [anyarray]
  download-mate2-files:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-command-line-cwl-tools/master/synapse-get-tool.cwl
    scatter: synapseid
    in:
      synapseid: get-mate2-files/anyarray
      synapse_config: synapse_config
    out: [filepath]
  run-salmon:
    run: salmon-quant-tool.cwl
    in:
      mates1: get-mate-1-files/filepath
      mates2: get-mate-2-files/filepath
      index-dir: index-dir
    out:
      quants

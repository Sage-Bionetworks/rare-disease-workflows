class: Workflow
label: synapse-get-salmon-quant-workflow
id: synapse-get-salmon-quant-workflow
cwlVersion: v1.0

inputs:
  mate1-ids:
    type: string[]
  mate2-ids:
    type: string[]
  index-dir:
    type: Directory
  synapse_config:
    type: File
  specimenId:
    type: string

outputs:
  quants:
    type: File
    outputSource: run-salmon/quants
  dirname:
    type: string
    outputSource: specimenId

requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement

steps:
  download-mate1-files:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-get-tool.cwl
    scatter: synapseid
    in:
      synapseid: mate1-ids
      synapse_config: synapse_config
    out: [filepath]
  download-mate2-files:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-get-tool.cwl
    scatter: synapseid
    in:
      synapseid: mate2-ids
      synapse_config: synapse_config
    out: [filepath]
  run-salmon:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/sage-workflows-sandbox/master/tools/salmon-quant-tool.cwl
    in:
       mates1:
         source: download-mate1-files/filepath
       mates2:
         source: download-mate2-files/filepath
       index-dir: index-dir
       output: specimenId
    out:
       [quants]

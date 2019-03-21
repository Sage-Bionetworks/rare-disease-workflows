class: Workflow
label: synapse-get-salmon-quant-workflow
id: synapse-get-salmon-quant-workflow
cwlVersion: v1.0

inputs:
  mate1-ids:
    type: File
  mate2-ids:
    type: File
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
    type: Directory
    outputSource: run-salmon/dirname

requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement

steps:
  get-mate1-files:
    run: out-to-array-tool.cwl
    in:
      datafile: mate1-ids
    out: [anyarray]
  download-mate1-files:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-get-tool.cwl
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
    run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-get-tool.cwl
    scatter: synapseid
    in:
      synapseid: get-mate2-files/anyarray
      synapse_config: synapse_config
    out: [filepath]
  run-salmon:
    run: salmon-quant-tool.cwl
    in:
       mates1: 
         source: download-mate1-files/filepath
       mates2: 
         source: download-mate2-files/filepath
       index-dir: index-dir
       output: specimenId
    out:
       [quants,dirname]
     

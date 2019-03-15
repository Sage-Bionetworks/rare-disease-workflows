class: Workflow
label: synapse-get-salmon-quant-workflow
id: synapse-get-salmon-quant-workflow
cwlVersion: v1.0

inputs:
  mate1-ids: []
  mate2-ids: []
  index-dir: index-file
  synapse_config:
    type: File
  parent_id:
    type: string
  specimen_id:
    type: string

outputs: []

requirements:
  - class: ScatterFeatureRequirement

steps:
    download-mate1-files:
      run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-command-line-cwl-tools/master/synapse-get-tool.cwl
      in:
      out:
    download-mate2-files:
      run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-command-line-cwl-tools/master/synapse-get-tool.cwl
      in:
      out:
    run-salmon:
      run: salmon-quant-tool.cwl
      in:
        mates1: mate1-files
        mates2: mate2-files
        index-dir: index-dir
      out:

class: Workflow
label: salmon-alignment-from-synapse
id: salmon-alignment-from-synapse
cwlVersion: v1.0

inputs:
  index-type:
    type: string
  index-dir:
    type: string
  synapse_config:
    type: File
  indexid:
    type: string
  query:
    type: string

requirements:
  SubworkflowFeatureRequirement: {}

outputs:
  out:
    type: File
    outputBinding:
      glob: "*.sf"

steps:
    get-index:
      run:  https://raw.githubusercontent.com/Sage-Bionetworks/synapse-command-line-cwl-tools/master/synapse-get-tool.cwl
      in:
        synapseid: indexid
        synapse_config: synapse_config
      out: [filepath]
    run-index:
      run: salmon-index-tool.cwl
      in:
        index-file: []
        index-dir: index-dir
        index-type: index-type
      out: [indexDir]
    get-fv:
       run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-command-line-cwl-tools/master/synapse-query-tool.cwl
       in:
         synapse_config: synapse_config
         query: query
       out: [fileview.tsv]
    get-samples-from-fv:
      run:
      in: []
      out: [specimenIds]

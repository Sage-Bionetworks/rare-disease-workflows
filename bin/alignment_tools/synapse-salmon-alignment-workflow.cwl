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
  idquery:
    type: string
  sample_query:
    type: string
#three arrays - 1 for sample ids, 1 for mate1 synapse ids, 1 for mate2 synapse ids

requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement

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
         query: idquery
       out: [query_result]
    get-samples-from-fv:
      run: breakdownfile-tool.cwl
      in: []
      out: [specIds,mate1files,mate2files] 
    run-alignment-by-specimen:
      run: synapse-get-salmon-quant-workflow.cwl
      scatter: [specimenId,mate1-ids,mate2-ids]
      scatterMethod: dotproduct
      in:
        specimenId: get-samples-from-fv/specIds
        mate1-ids: get-samples-from-fv/mate1files
        mate2-ids: get-samples-from-fv/mate2files
        index-dir: run-index/indexDir
        synapse_config: synapse_config
      out: [quants]
    get-clinical:
       run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-command-line-cwl-tools/master/synapse-query-tool.cwl
       in:
         synapse_config: synapse_config
         query: sample_query
       out: [query_result]

   # store-files:
   #     run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-command-line-cwl-tools/master/synapse-store-tool.cwl
   #     in:
   #     out:

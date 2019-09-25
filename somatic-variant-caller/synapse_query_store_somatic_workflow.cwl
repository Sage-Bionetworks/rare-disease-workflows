cwlVersion: v1.0
class: Workflow
id: synapse_query_store_somatic_workflow
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  - idquery:
      type: string
  - synapse_config:
      type: File
  - sample_query:
      type: string
  - parentid:
      type: string
  - group_by:
      type: string

outputs:

steps:
  get-fv:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-query-tool.cwl
    in:
      synapse_config: synapse_config
      query: idquery
    out: [query_result]
  get-samples-from-fv:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/sage-workflows-sandbox/master/examples/tools/breakdown.cwl
    in:
      query_tsv: get-fv/query_result
      group_by_column: group_by
    out: [names,tumor_ids,normal_ids]
  run-wf-by-sample:
    run:
    scatter: [tumorId,tumorFiles,normalFiles]
    scatterMethod: dotproduct
    in:
      specimenId: get-samples-from-fv/names
      tumor-ids: get-samples-from-fv/tumor_ids
      normal-ids: get-samples-from-fv/normal_ids
      synapse_config: synapse_config
    out: [vars,dirname] ##figure out what the output is
  get-clinical:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-query-tool.cwl
    in:
      synapse_config: synapse_config
      query: sample_query
    out: [query_result]
  join-fileview-by-specimen:
    run: https://raw.githubusercontent.com/sgosline/synapse-workflow-cwl-tools/master/join-fileview-by-specimen-tool.cwl
    in:
      filelist: run-wf-by-sample/vars
      values: run-wf-by-sample/dirname
      manifest_file: get-clinical/query_result
      parentid: parentid
      key: group_by
    out:
      [newmanifest]

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
  parentid:
    type: string
  group_by:
    type: string
  tableparentid:
    type: string[]
  tablename:
    type: string[]

requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement

outputs:
  merged:
    type: File
    outputSource: harmonize-counts/merged
steps:
    get-index:
      run:  https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-get-tool.cwl
      in:
        synapseid: indexid
        synapse_config: synapse_config
      out: [filepath]
    run-index:
      run: https://raw.githubusercontent.com/Sage-Bionetworks/sage-workflows-sandbox/master/examples/tools/salmon-index-tool.cwl
      in:
        index-file: get-index/filepath
        index-dir: index-dir
        index-type: index-type
      out: [indexDir]
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
      out: [names,mate1_id_arrays,mate2_id_arrays]
    run-alignment-by-specimen:
      run: synapse-get-salmon-quant-workflow.cwl
      scatter: [specimenId,mate1-ids,mate2-ids]
      scatterMethod: dotproduct
      in:
        specimenId: get-samples-from-fv/names
        mate1-ids: get-samples-from-fv/mate1_id_arrays
        mate2-ids: get-samples-from-fv/mate2_id_arrays
        index-dir: run-index/indexDir
        synapse_config: synapse_config
      out: [quants,dirname]
    get-clinical:
       run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-query-tool.cwl
       in:
         synapse_config: synapse_config
         query: sample_query
       out: [query_result]
    join-fileview-by-specimen:
      run: https://raw.githubusercontent.com/sgosline/synapse-workflow-cwl-tools/master/join-fileview-by-specimen-tool.cwl
      in:
        filelist: run-alignment-by-specimen/quants
        values: run-alignment-by-specimen/dirname
        manifest_file: get-clinical/query_result
        parentid: parentid
        key: group_by
      out:
        [newmanifest]
#    store-files:
#        run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-sync-to-synapse-tool.cwl
#        in:
#          synapse_config: synapse_config
#          files: run-alignment-by-specimen/quants
#          manifest_file: join-fileview-by-specimen/newmanifest
#        out:
#          []
    harmonize-counts:
      run: steps/merge-counts-with-meta-tool.cwl
      in:
        synapse_config: synapse_config
        manifest: join-fileview-by-specimen/newmanifest
        files: run-alignment-by-specimen/quants
      out:
        [merged]
#    add-to-table:
#      run: https://raw.githubusercontent.com/Sage-Bionetworks/rare-disease-workflows/master/synapse-table-store/synapse-table-store-tool.cwl
 #     in:
 #       synapse_config: synapse_config
 #       tableparentid: tableparentid
 #       tablename: tablename
 #       file: harmonize-counts/merged
 #     out:
 #       []

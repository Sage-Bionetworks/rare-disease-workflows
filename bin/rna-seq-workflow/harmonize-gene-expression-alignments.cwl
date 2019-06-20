class: Workflow
label: harmonize-gene-expression-alignments
id: harmonize-gene-expression-alignments
cwlVersion: v1.0

inputs:
  id-query-array:
    type: string[]
  clinical-query-array:
    type: string[]
  #these are for the next step
  index-type:
    type: string
  index-dir:
    type: string
  synapse_config:
    type: File
  indexid:
    type: string
  parentid:
    type: string
  group_by:
    type: string

requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement

outputs:
   manifest-list:
     type: File[]
     outputSource: do-align/manifest
   file-list:
     type: File[]
     outputSource: do-align/files
  samp-list:
    type: string[]
    outputSource: do-align/sampnames
  #tidied-matrix:
  #  type: File
  #  outputSource: harmonize-counts/harmonized-df

steps:
  do-align:
    run: synapse-salmon-alignment-workflow.cwl
    scatter: [id-query-array,clinical-query-array]
    scatterMethod: dotproduct
    in:
      index-type: index-type
      index-dir: index-dir
      synapse_config: synapse_config
      indexid: indexid
      idquery: id-query-array
      sample_query: clinical-query-array
      parentid: parentid
      group_by: group_by
    out:
      [manifest,files,sampnames]
 # harmonize-counts:
 #   run: steps/merge-to-matrix-tool.cwl
 #   in:
 #     manifest: do-align/manifest
 #     files: do-align/files
 #     sampnames: do-align/sampnames
 #   out: [harmonized-df]

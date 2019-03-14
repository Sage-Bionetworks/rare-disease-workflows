class: Workflow
label: salmon-alignment-from_synapse
cwlVersion: v1.0

inputs: [index_id,fv_id,parent_id]

outputs:
  out:
    type: File
    outputBinding:
      glob: "*.sf"

requirements:
    ScatterFeatureRequirements {}

steps:
    get-index:
      run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-command-line-cwl-tools/master/synapse-get-tool.cwl
      in: [index_id]
      out: [indexfile]
    run-index:
      run: salmon-run-index.cwl
      in: [indexfile]
      out: [indexpath]
    get-fv:
        run: synapse-query-tool.cwl
        in: [fv_id,parent_id]
        out: [fv_file]
    scatter-aligns:
        run: salmon-align-syn-ids.cwl
        in:[sampids]
        out: []

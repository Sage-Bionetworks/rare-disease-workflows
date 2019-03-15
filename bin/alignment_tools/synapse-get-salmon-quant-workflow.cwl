class: Workflow
label: salmon-align-syn-ids
cwlVersion: v1.0

inputs: [samp_id,fv_id,index_path]

outputs: []

requirements: []

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
      run:
      in:
        out:
    store-files:
        run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-command-line-cwl-tools/master/synapse-store-tool.cwl
        in:
        out:

class: Workflow
cwlVersion: v1.0
id: dose_response_metrics_from_synapse
label: dose-response-metrics-from-synapse

inputs:
  - id: synapse_config
    type: File
  - id: synapseid
    type: string
  - id: parentid
    type: string
  - id: output
    type: string
outputs:
  - id: stdout
    outputSource:
      - store_data/stdout
    type: File
steps:
  - id: get_data
    in:
      - id: synapse_config
        source: synapse_config
      - id: synapseid
        source: synapseid
    out:
      - id: filepath
    run: >-
      https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-get-tool.cwl
  - id: dose_response_fitting_tool
    in:
      - id: data
        source: get_data/filepath
      - id: output
        source: output
      - id: synapseid
        source: synapseid
    out:
      - id: metrics
    run: dose-response-fitting-tool.cwl
    label: dose_response_fitting_tool
  - id: store_data
    in:
      - id: synapse_config
        source: synapse_config
      - id: file_to_store
        source: dose_response_fitting_tool/metrics
      - id: parentid
        source: parentid
    out:
      - id: stdout
    run: >-
      https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-store-tool.cwl
    label: Synapse command line client subcommand for storing a file.
requirements: []

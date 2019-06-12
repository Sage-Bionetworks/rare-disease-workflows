class: Workflow
cwlVersion: v1.0
id: dose_response_metrics_from_synapse
label: dose-response-metrics-from-synapse
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
inputs:
  - id: synapse_config
    type: File
    'sbg:x': -52.59514236450195
    'sbg:y': -75.76518249511719
  - id: synapseid
    type: string
    'sbg:x': -39.10121536254883
    'sbg:y': 186.10931396484375
  - id: parentid
    type: string
    'sbg:x': 268.4151916503906
    'sbg:y': -16.993213653564453
  - id: output
    type: string
    'sbg:x': 147.94091796875
    'sbg:y': 76.02075958251953
outputs:
  - id: stdout
    outputSource:
      - store_data/stdout
    type: File
    'sbg:x': 671.5242919921875
    'sbg:y': -6.417004108428955
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
    'sbg:x': 212
    'sbg:y': 289.6922912597656
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
    run: ./dose-response-fitting-tool.cwl
    label: dose-response-fitting-tool
    'sbg:x': 410.9230651855469
    'sbg:y': 147.76922607421875
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
    'sbg:x': 481
    'sbg:y': -162

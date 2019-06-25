class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
id: dose_response_fitting_tool
baseCommand:
  - Rscript
  - /usr/local/bin/dose-response-fit.R
inputs:
  - id: data
    type: File
    inputBinding:
      position: 1
  - id: output
    type: string
    inputBinding:
      position: 2
  - id: synapseid
    type: string
    inputBinding:
      position: 3
outputs:
  - id: metrics
    type: File
    outputBinding:
      glob: '*.csv'
label: dose-response-fitting-tool
requirements:
  - class: ResourceRequirement
    ramMin: 4000
  - class: DockerRequirement
    dockerPull: nfosi/dose-response-metrics

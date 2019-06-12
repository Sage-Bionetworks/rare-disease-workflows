class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
baseCommand:
  - synapse
inputs:
  - id: synapse_config
    type: File
  - id: synapseid
    type: string
outputs:
  - id: filepath
    type: File
    outputBinding:
      glob: '*'
arguments:
  - position: 0
    valueFrom: get
  - position: 0
    valueFrom: $(inputs.synapseid)
requirements:
  - class: InitialWorkDirRequirement
    listing:
      - entryname: .synapseConfig
        entry: $(inputs.synapse_config)
        writable: false
  - class: InlineJavascriptRequirement
hints:
  - class: DockerRequirement
    dockerPull: 'sagebionetworks/synapsepythonclient:v1.9.2'

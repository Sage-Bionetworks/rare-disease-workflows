cwlVersion: v1.0
class: CommandLineTool
id: google-cloud-get

hints:
  DockerRequirement:
    dockerPull: google/cloud-sdk:latest

baseCommand: [gsutil, cp]

arguments:
  - valueFrom: $(inputs.uri)
  - valueFrom: .

inputs:
  uri:
    type: string
    inputBinding:
      position: 1

outputs:
  []

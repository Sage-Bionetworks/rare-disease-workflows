cwlVersion: v1.0
class: Workflow
id: get-data-bundle-google


requirements:
  - class: ScatterFeatureRequirement

inputs:
  uri-list:
    type: string[]

outputs:
  file-list:
    type: File[]

steps:
  get-files:
    scatter: uri
    scatterMethod: dotproduct
    run: steps/google-cloud-get.cwl
    in:
      uri: uri-list
    out:
      []

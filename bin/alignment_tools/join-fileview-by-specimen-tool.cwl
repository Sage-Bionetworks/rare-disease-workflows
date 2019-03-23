#!/usr/bin/cwl-runner
class: CommandLineTool
label: join-fileview-by-specimen-tool
id: join-fileview-by-specimen-tool
cwlVersion: v1.0

baseCommand:
  - python
  - join-fileview-by-specimen.py

requirements:
- class: InitialWorkDirRequirement
  listing: $(inputs.scripts)
- class: DockerRequirement
  dockerPull: amancevice/pandas

inputs:
  scripts:
    type: File[]
  filelist:
    type: File[]
    inputBinding:
      prefix: --filelist
  specimenIds:
    type: string[]
    inputBinding:
      prefix: --specimenIds
  manifest_file:
    type: File
    inputBinding:
      prefix: --manifest_file
  parentid:
    type: string
    inputBinding:
      prefix: --parentId

outputs:
  newmanifest:
    type: File
    outputBinding:
      glob: '*.tsv'

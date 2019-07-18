label: merge-to-synapse-tool
id: merge-to-synapse-tool
cwlVersion: v1.0
class: CommandLineTool
baseCommand: Rscript

requirements:
   - class: DockerRequirement
     dockerPull: nfosi/merge-counts-to-synapse
   - class: InitialWorkDirRequirement
     listing:
        - entryname: .synapseConfig
          entry: $(inputs.synapse_config)
arguments:
  - /usr/local/bin/merge-files-to-syn-table.R 

inputs:
  synapse_config:
   type: File
  manifest:
    type: File
    inputBinding:
      position: 1
      prefix: --manifest
  files:
    type: File[]
    inputBinding:
      position: 2
      prefix: --files
      itemSeparator: ","
  tableparentid:
    type: string[]
    inputBinding:
      position: 3
      prefix: --tableparentid
      itemSeparator: ","
  tablename:
    type: string[]
    inputBinding:
      position: 4
      prefix: --tablename
      itemSeparator: ","

outputs:
  []

label: merge-to-synapse-tool
id: merge-to-synapse-tool
cwlVersion: v1.0
class: CommandLineTool
baseCommand: Rscript

requirements:
   - class: DockerRequirement
     dockerPull: nfosi/merge-files-with-meta
   - class: InitialWorkDirRequirement
     listing:
        - entryname: .synapseConfig
          entry: $(inputs.synapse_config)
arguments:
  - /usr/local/bin/merge-files-with-meta.R

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

outputs:
  merged:
    type: stdout

stdout:
  merged.txt

cwlVersion: v1.0
label: synapse-table-store-tool
id: synapse-table-store-tool
class: CommandLineTool
baseCommand: Rscript


requirements:
   - class: DockerRequirement
     dockerPull: nfosi/synapse-table-store
   - class: InitialWorkDirRequirement
     listing:
        - entryname: .synapseConfig
          entry: $(inputs.synapse_config)


arguments:
  - /usr/local/bin/synapse-table-store.R

outputs:
  []

inputs:
  synapse_config:
   type: File
  file:
    type: File
    inputBinding:
      position: 1
      prefix: --file
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

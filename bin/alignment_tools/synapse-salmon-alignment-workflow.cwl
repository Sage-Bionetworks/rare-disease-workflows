class: Workflow
label: salmon-alignment-from-synapse
id: salmon-alignment-from-synapse
cwlVersion: v1.0

inputs:
  index-type:
    type: string
  index-dir:
    type: string
  synapse_config:
    type: File
  indexid:
    type: string
  query:
    type: string

#three arrays - 1 for sample ids, 1 for mate1 synapse ids, 1 for mate2 synapse ids
  sample_ids:
    type: File[]
  mate1_ids:
    type: File[]
  mate2_ids:
    type: File[]

requirements:
  - class: SubworkflowFeatureRequirement
  - class: InlineJavascriptRequirement
    listing:
      - entryname: breakdownfiles.py
        entry:
          #!/usr/bin/env python
          import tsv
          with open('fileview.tsv','r') as tsv:
            lines=[line.strip().split('\t') for line in tsv]
          specId=[ind for ind in range(len(lines[0])) if lines[0][ind]=='specimenID'][0]
          all.s=l[set([l[i][specId] for i in range(len(lines)))]



outputs:
  out:
    type: File
    outputBinding:
      glob: "*.sf"

steps:
    get-index:
      run:  https://raw.githubusercontent.com/Sage-Bionetworks/synapse-command-line-cwl-tools/master/synapse-get-tool.cwl
      in:
        synapseid: indexid
        synapse_config: synapse_config
      out: [filepath]
    run-index:
      run: salmon-index-tool.cwl
      in:
        index-file: []
        index-dir: index-dir
        index-type: index-type
      out: [indexDir]
    get-fv:
       run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-command-line-cwl-tools/master/synapse-query-tool.cwl
       in:
         synapse_config: synapse_config
         query: id_query
       out: [query_result.tsv]
    get-samples-from-fv:
      run: breakdownfiles.py
      in: [query_result.tsv]
      out: [specIdFiles]
    run-alignment-by-specimen:
      run: synapse-get-salmon-quant-workflow.cwl
      in:
        specidfile: []
      out: [salmonfile]
    get-clinical:
       run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-command-line-cwl-tools/master/synapse-query-tool.cwl
       in:
         synapse_config: synapse_config
         query: sample_query
       out: [query_result.tsv]

    store-files:
        run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-command-line-cwl-tools/master/synapse-store-tool.cwl
        in:
        out:

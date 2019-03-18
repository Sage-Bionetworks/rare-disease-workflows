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
          #!/usr/bin/env python \
          import pandas as pd \
          res=pd.read_csv("query_result.tsv",delimiter='\t') \
          gdf=res.groupby('specimenID') \
          for key,value in gdf: \
            rps=gdf.get_group(key).groupby('readPair') \
            g1=[i for i in rps.get_group(1)['id']] \
            g2=[i for i in rps.get_group(2)['id']] \
            open(key+'mate1.txt','w').writelines(['\n'.join(g1)])
            open(key+'mate2.txt','w').writelines(['\n'.join(g2)])
          allspecs=set(res['specimenID'])
          {'specimens':allspecs, 'mate1files':[k+'mate1.txt' for k in allspecs],'mate2files': [k+'mate2.txt' for k in allspecs]}


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
      in: []
      out: [specIdNames, mate1files,mate2files]
    run-alignment-by-specimen:
      run: synapse-get-salmon-quant-workflow.cwl
      scatter: specID
      scatterMethod: dotproduct
      in:
        specID: specIdNames
        mate1files: mate1files
        mate2files: mate2files
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

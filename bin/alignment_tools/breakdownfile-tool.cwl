label: breakdwonfile-tool
cwlVersion: v1.0
class: CommandLineTool
baseCommand: python

requirements:
 - class: InlineJavascriptRequirement
 - class: DockerRequirement
   dockerPull: amancevice/pandas
 - class: InitialWorkDirRequirement
   listing:
     - entryname: breakdownfiles.py
       entry: |
         #!/usr/bin/env python
         import json
         import sys
         import pandas as pd
         fname=sys.argv[2]
         res = pd.read_csv(fname,delimiter='\t')
         gdf = res.groupby('specimenID')
         for key,value in gdf:
            rps = gdf.get_group(key).groupby('readPair')
            g1=[i for i in rps.get_group(1)['id']]
            g2=[i for i in rps.get_group(2)['id']]
            open(key+'mate1.txt','w').writelines(['\n'.join(g1)])
            open(key+'mate2.txt','w').writelines(['\n'.join(g2)])
         allspecs=set(res['specimenID'])
         res={'specimens':list(allspecs), 'mate1files':[k+'mate1.txt' for k in allspecs],'mate2files': [k+'mate2.txt' for k in allspecs]}
         with open('cwl.json','w') as outfile:
           json.dump(res,outfile)
inputs:
 fileName: File 
arguments:
  - valueFrom: breakdownfiles.py
  - valueFrom: $(inputs.fileName)
outputs:
  - id: specIds
    type: string[]
    outputBinding:
      glob: cwl.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['specimens'])
  - id: mate1files
    type: File[]
    outputBinding:
      glob: cwl.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['mate1files'])
  - id: mate2files
    type: File[]
    outputBinding:
      glob: cwl.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['mate2files'])

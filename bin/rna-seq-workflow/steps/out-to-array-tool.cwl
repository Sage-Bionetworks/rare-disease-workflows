#!/usr/bin/env cwl-runner

class: ExpressionTool
cwlVersion: v1.0
label: out-to-array-tool
id: out-to-array-tool

requirements:
  - class: InlineJavascriptRequirement

inputs:
  datafile:
    type: File
    inputBinding:
      loadContents: true

outputs:
  anyarray:
    type: string[]

expression: "${var lines = inputs.datafile.contents.split('\\n');
               var newlines = [] ;
               var i = 0;
               for (i=0; i<lines.length;i++){
                   if(lines[i]!== \"\"){
                        newlines.push(lines[i]);
                    }
                 }
               return { 'anyarray': newlines } ;
              }"

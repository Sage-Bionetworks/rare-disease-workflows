#!/usr/bin/env cwl-runner
class: CommandLineTool
id: run-salmon-index
label: run-salmon-index
cwlVersion: 1.0

requirements:
  -class: DockerRequirement
  dockerPull: combinelab/salmon

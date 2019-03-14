#!/usr/bin/env cwl-runner

class: CommandLineTool
id: get-fv-from-synapse
label: get-fv-from-synapse
cwlVersion: 1.0

s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0002-6534-4774
    s:email: mailto:sara.gosline@sagebionetworks.org
    s:name: Sara Gosline

#metadata!
$namespaces:
  s: https://schema.org/

$schemas:
 - https://schema.org/docs/schema_org_rdfa.html
requirements:
  -class: DockerRequirement
  dockerPull: sagebionetworks/synapsepythonclient

inputs:
  synapse_config:
    type: File
    inputBinding:
      position: 1
      prefix: --config-file
    doc: synapseConfig file
  fileview_id:
    type: string
    inputBinding:
      position: 2
      prefix: --input-fileview-id
    doc: The fileview from which to grab your fastq files with annotations
  parentFolder_id:
    type: string
    inputBinding:
      position: 3
      prefix: --parent-id
    doc: Optional parent id to restrict for file query

outputs:
  synapse_fv:
    type: File
    glob: fileview.tsv

arguments:
  - valueFrom: query
  - valueFrom: "SELECT specimenID,individualID,name,id,assay,dataType,sex,dataSubtype,consortium,study,diagnosis,tumorType,isMultiIndividual,isMultiSpecimen,isCellLine,species,fundingAgency,resourceType,nf1Genotype,nf2Genotype,studyName FROM syn11614202 WHERE ( ( \"assay\" = 'rnaSeq' ) AND ( \"fileFormat\" = 'fastq' ) AND ( \"parentId\" = 'syn7979306' ) ) order by specimenID"

baseCommand: synapse
doc:

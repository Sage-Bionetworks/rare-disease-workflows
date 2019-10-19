class: Workflow
cwlVersion: v1.0
id: synapse-query-deep-variant
label: synapse-query-deep-variant


inputs:
  - id: indexurl
    type: string
  - id: idquery
    type: string
  - id: sample_query
    type: string
  - id: parentid
    type: string
  - id: group_by
    type: string
  - id: tableparentid
    type: string[]
  - id: tablename
    type: string[]
  - id: dotvepdir
    type: Directory
  - id: indexfile
    type: File
  - id: synapse_config
    type: File
  - id: vcfid
    type: string
  - id: vepdir
    type: Directory

outputs:
  - id: merged
    type: File
    outputSource: harmonize-calls/merged
  - id: maffile
    outputSource:
      - vcf2maf/maf-file
    type: File
  - id: vcf-id
    outputSource:
      - vcfid
    type: string
steps:
  get-index:
    run: steps/get-index-and-unzip.cwl
    in:
      path: indexurl
    out:
      file
  get-fv:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-query-tool.cwl
    in:
      synapse_config: synapse_config
      query: idquery
    out: [query_result]
  get-samples-from-fv:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/sage-workflows-sandbox/master/examples/tools/breakdown.cwl
    in:
      query_tsv: get-fv/query_result
      group_by_column:
    out: [names]
  run-deepvar-by-specimen:
      run: single-file-deep-variant.cwl
      scatter: [synid]
      scatterMethod: dotproduct
      in:
        synid: get-samples-from-fv/names
        synapse_config: synapse_config
        index-file: get-index/file
      out: [synid,vcf]
  vcf2maf:
    run:

    out:
      maf-file
  get-clinical:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-query-tool.cwl
    in:
      synapse_config: synapse_config
      query: sample_query
    out: [query_result]
  join-fileview-by-specimen:
      run: https://raw.githubusercontent.com/sgosline/synapse-workflow-cwl-tools/master/join-fileview-by-specimen-tool.cwl
      in:
        filelist: run-deepvar-by-specimen/vcf
        values: run-deepvar-by-specimen/synid
        manifest_file: get-clinical/query_result
        parentid: parentid
        key:
      out:
        [newmanifest]
    store-files:
        run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-sync-to-synapse-tool.cwl
        in:
          synapse_config: synapse_config
          files: run-deepvar-by-specimen/vcf
          manifest_file: join-fileview-by-specimen/newmanifest
        out:
          []
    harmonize-counts:
      run: steps/merge-maf-with-meta-tool.cwl
      in:
        synapse_config: synapse_config
        manifest: join-fileview-by-specimen/newmanifest
        files: run-deepvar-by-specimen/vcf
      out:
        [merged]
    add-to-table:
      run: https://raw.githubusercontent.com/Sage-Bionetworks/rare-disease-workflows/master/synapse-table-store/synapse-table-store-tool.cwl
      in:
        synapse_config: synapse_config
        tableparentid: tableparentid
        tablename: tablename
        file: harmonize-counts/merged
      out:
        []

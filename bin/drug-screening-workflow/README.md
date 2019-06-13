# Drug Screening Workflow
This workflow ingests standardized drug screening information and calculates common dose-response metrics such as IC50, AUC, and max response using the `nplr` R library. It will provide analyzed data that can be added to Kairos/Drug-Gene Database. 

In order to use this workflow, you'll need a data file formatted with the following columns: 

"drug_screen_id": a unique identifier that can be used to group individual dose-response curves 
"drug_assay_id": a unique identifier that can be used to pinpoint a single dose-response value. Please do not use simple numeric indices, but rather synXXXXXXX.Y where synXXXXXXX is the source data synapse id, and Y is the row index in that file.  "experiment_synapse_id": the source data synapse id including version (eg. syn1234567.8 where 8 is the version). This should be the same for all data in a given file. (this is essentially provenance). 
"study_synapse_id": the Synapse ID of your Synapse Project/NF Portal Study
"funder": funder abbreviation (e.g. CTF, NTAP)
"model_name": the standardized modelSystemName from https://www.synapse.org/#!Synapse:syn16979992/tables/ 
"cellosaurus_id": the cellosaurus ID of the cell line if applicable
"organism_name": the name of the organism (following synapseAnnotations standard values)
"drug_name": the name of the tested drug
"DT_explorer_internal_id": the internal ID of the tested drug (from https://www.synapse.org/#!Synapse:syn17090820/tables/)
"dosage": the dosage of the drug in uM
"dosage_unit": uM
"response": preferably, the control normalized response value
"response_type": percent viability
"response_unit": %
"model_type": the type of model form 
"disease_name": the name of the disease
"disease_efo_id": the EFO ID of the disease
"symptom_name": the name of the symptom
"symptom_efo_id": the EFO ID of the symptom

This file should be on Synapse. 

Modify test.yml to input the correct data:

```{
    "synapseid": "synapse id of your data, e.g. syn12345678",
    "output": "name of experiment for output file, e.g. my_drug_screening_data",
    "parentid": "destination id on synapse for the stored data",
    "synapse_config": {
        "class": "File",
        "metadata": {},
        "path": "/path/to/.synapseConfig",
        "secondaryFiles": []
    }
}````

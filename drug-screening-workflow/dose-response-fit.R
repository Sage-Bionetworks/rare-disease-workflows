#!/usr/bin/env Rscript

library(dplyr)
library(nplr)

args <- commandArgs(trailingOnly=T)
data <- args[1] %>% read.csv()
  
dose_response_single <- data %>%
  group_by(drug_screen_id) %>% 
  filter(length(unique(DT_explorer_internal_id)) == 1) %>%
  select(drug_screen_id, drug_name, dosage, response) %>% 
  mutate(id= paste0(drug_screen_id, "_", drug_name)) %>% 
  ungroup

# dose_response_combo <- data %>%
#   group_by(drug_screen_id) %>% 
#   filter(length(unique(DT_explorer_internal_id)) > 1) %>%
#   select(drug_screen_id, drug_name, dosage, response) %>% 
#   mutate(id= paste0(drug_screen_id, "_", drug_name))

test <- dose_response_single %>%
  split(.$id)

res <- lapply(test, function(x){
  bar <- tryCatch({
    foo<-nplr(x$dosage, x$response, silent = T, useLog = T)
    simpson <- getAUC(foo)$Simpson
    trapezoid <- getAUC(foo)$trapezoid
    ic50_abs <- getEstimates(foo) %>% filter(y==0.5) %>% select(x) %>% purrr::set_names("IC50_absolute")
    min_viability <- min(getYcurve(foo))
    c("AUC_Simpson"=simpson,"AUC_Trapezoid"=trapezoid,"IC50_abs"=ic50_abs[1,1],"Min_viability"=min_viability)
  }, error = function(e) {
    return(c("AUC_Simpson"=NA,"AUC_Trapezoid"=NA,"IC50_abs"=NA,"Min_viability"=NA))
  })
  
  bar2 <- tryCatch({
    foo2 <- nplr(x$dosage, convertToProp(x$response), silent = T, useLog = T)
    ic50_rel <- getEstimates(foo2) %>% filter(y==0.5) %>% select(x) %>% purrr::set_names("IC50_relative")
    c('IC50_half_max' = ic50_rel[1,1])
  }, error = function(e) {
    return(c('IC50_half_max' = NA))
  })
  
  c(bar,bar2)
  
})


x2 <- plyr::ldply(res)

res_df <- data %>% 
  select(model_name, model_type, cellosaurus_id, organism_name, disease_name, disease_efo_id, symptom_name, 
         symptom_efo_id, experiment_synapse_id, study_synapse_id,
         funder, drug_name, DT_explorer_internal_id, dosage, dosage_unit, drug_screen_id) %>% 
  group_by(model_name, model_type, cellosaurus_id, organism_name, disease_name, disease_efo_id, symptom_name, 
           symptom_efo_id, experiment_synapse_id, study_synapse_id,
           funder, drug_name, DT_explorer_internal_id, dosage_unit, drug_screen_id) %>% 
  summarize(dosage = paste0("[",min(dosage),",",max(dosage),"]")) %>% 
  ungroup() %>% 
  distinct() %>% 
  mutate(.id= paste0(drug_screen_id, "_", drug_name)) %>% 
  right_join(x2) %>% 
  select(-.id) %>% 
  tidyr::gather(key = "response_type", value = "response", -model_name, -model_type, -cellosaurus_id, -organism_name, -disease_name, 
                -disease_efo_id, -symptom_name, 
                -symptom_efo_id, -experiment_synapse_id, -study_synapse_id,
                -funder, -drug_name, -DT_explorer_internal_id, -dosage, -dosage_unit, -drug_screen_id) %>% 
  filter(!is.na(response))


res_df %<>% mutate(response_unit = NA) %>% 
  mutate(response_unit = replace(response_unit, response_type %in% c("IC50_abs", "IC50_half_max"), 
                                 "uM")) %>% 
  mutate(response_unit = replace(response_unit, response_type %in% c("Min_viability"), 
                                 "%"))


write.csv(res_df, paste0(args[2],"_dose_response_metrics.csv"),row.names = F)


##plot drugs across cell culture

require(synapser)
synLogin()
synId='syn17462699'
require(tidyverse)
tab<-read.csv(synGet(synId)$path)%>%dplyr::rename(internal_id='DT_explorer_internal_id')

drug.map<-synTableQuery('SELECT distinct internal_id,std_name FROM syn17090819')$asDataFrame()

tab.with.id<-tab%>%left_join(drug.map,by='internal_id')

all.compounds<-unique(tab.with.id$std_name)
all.models<-unique(tab.with.id$model_name)
print(paste('Loaded',length(all.compounds),'compound response data over',length(all.models),'models'))

##plot cells by drug and cell and tumor type
plotDrugByCellAndTumor<-function(compoundName,tumorType){
  require(tidyverse)
  red.tab<-subset(tab.with.id,std_name==compoundName)%>%subset(response<300)%>%select(model_name,response,response_type,symptom_name,organism_name,disease_name)%>%unique()
  fname=NULL
  if(missing(tumorType)||tumorType%in%red.tab$symptom_name){
    if(nrow(red.tab)>0){
      ggplot(red.tab)+geom_jitter(aes(x=symptom_name,y=response,col=organism_name))+facet_grid(.~response_type)+ggtitle(paste(compoundName,'response across cells'))+theme(axis.text.x = element_text(angle = 45, hjust = 1))
      fname=paste('drugResponsesFrom',compoundName,'with',tumorType,'.png',sep='')
      ggsave(fname)
    }}
  return(fname)
  # ggplot(red.tab)+geom_violin(aes(x=symptom_name,y=response,col=organism_name))+facet_grid(.~response_type)+ggtitle(paste(compoundName,'response across cells'))+theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
}

screening_data_syn_id <- "syn17100888"

screening_data_with_id <- synGet(screening_data_syn_id)$path %>% 
  readr::read_csv(guess_max=100000) %>% 
  dplyr::rename(internal_id='DT_explorer_internal_id') %>% 
  dplyr::left_join(drug.map)

nplr_dosage_response <- function(df){
  foo <- tryCatch({nplr::nplr(df$dosage, df$response)},error = function(e) {
    return(NA)
  })
}

get_ic50 <- function(mod){
  nplr::getEstimates(mod)[5,3]
}

plotDoseResponseCurve<-function(compoundName,tumorTypes,scaleY = F, minLogDose = -6, minDosesPerGroup = 5){

    red.tab <- subset(screening_data_with_id,std_name==compoundName) %>% 
      dplyr::group_by(drug_screen_id) %>% 
      dplyr::filter(n() >= minDosesPerGroup) %>% #eliminate small dose-response groups with few points
      dplyr::filter(min(log10(dosage)) >= minLogDose) %>% 
      dplyr::ungroup() %>% 
      dplyr::filter(symptom_name %in% tumorTypes) %>% 
      tidyr::nest(-drug_screen_id, -symptom_name, -drug_name) %>% 
      dplyr::mutate(model = purrr::map(data, nplr_dosage_response)) %>% ##4 or 5 param logistic regression of curve
      dplyr::mutate(ic50 = purrr::map(model, get_ic50) )%>% 
      dplyr::mutate(x = purrr::map(model, nplr::getXcurve)) %>% ##extract x and y fitted curve values
      dplyr::mutate(y = purrr::map(model, nplr::getYcurve)) %>% 
      dplyr::mutate(y_scale = purrr::map(y, scale)) %>% ##scale y to clean up across d-rs 
      dplyr::select(-data, -model) %>% 
      tidyr::unnest(.preserve=ic50) %>% 
      dplyr::group_by(symptom_name) %>% 
      dplyr::mutate(mean_ic50 = signif(mean(unlist(ic50), na.rm = T),3)) %>% 
      ungroup()
    
  
    fname <- NULL
  
  if(missing(tumorTypes)||tumorTypes%in%red.tab$symptom_name){
    if(nrow(red.tab)>0){
      if(scaleY == F){
      plt <- ggplot(red.tab)+
        geom_path(aes(x=x,y=y,col=symptom_name, group=as.factor(drug_screen_id)))+
          labs(title = paste0(compoundName),
               x = expression("log10(["*mu*"M])"), 
               y = "% viability",
               col = "Tumor Type")  +
          theme_bw() +
          theme(axis.text = element_text(size = 12),
                axis.title = element_text(size = 15))
        tbl <- gridExtra::tableGrob(red.tab %>% 
                                      select(symptom_name, mean_ic50) %>% 
                                      set_names(c("Tumor Type", 'Mean IC50 ([uM])')) %>% 
          distinct())
        p <- gridExtra::arrangeGrob(plt, tbl, heights=c(3,1))
      }else{
       plt <- ggplot(red.tab)+
          geom_path(aes(x=x,y=y_scale,col=symptom_name, group=as.factor(drug_screen_id)))+
          labs(title = paste0(compoundName),
               x = expression("log10(["*mu*"M])"), 
               y = "scaled % viability",
               col = "Tumor Type") +
          theme_bw() +
          theme(axis.text = element_text(size = 12),
                axis.title = element_text(size = 15))
        tbl <- gridExtra::tableGrob(red.tab %>% 
                                        select(symptom_name, mean_ic50) %>% 
                                      set_names(c("Tumor Type", 'Mean IC50 ([uM])')) %>% 
                                        distinct())
        p <- gridExtra::arrangeGrob(plt, tbl, heights=c(3,1))
      }
      fname=paste0('drugResponsesFrom',compoundName,'with',paste0(tumorTypes, collapse = "_"),'.png')
      ggsave(fname, p)
    }
    }
  
  return(fname)
}

##examples:
#plotDoseResponseCurve("ENMD-2076", c("pNF"), scaleY = F, minDosesPerGroup = 2, minLogDose = -6)
#plotDoseResponseCurve("PF-3758309", c("pNF", "MPNST"), scaleY = F, minDosesPerGroup = 2, minLogDose = -6)


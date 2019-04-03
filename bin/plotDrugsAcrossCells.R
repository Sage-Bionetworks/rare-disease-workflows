##plot drugs across cell culture

require(synapser)
synLogin()
synId='syn17462699'

tab<-read.csv(synGet(synId)$path)%>%rename(internal_id='DT_explorer_internal_id')

drug.map<-synTableQuery('SELECT distinct internal_id,std_name FROM syn17090819')$asDataFrame()

tab.with.id<-tab%>%left_join(drug.map,by='internal_id')

all.compounds<-unique(tab$std_name)
all.models<-unique(tab$model_name)
print(paste('Loaded',length(all.compounds),'compound response data over',length(all.mdoels)))

##plot cells by drug and cell and tumor type
plotDrugByCellAndTumor<-function(compoundName){
  require(tidyverse)
  red.tab<-subset(tab.with.id,std_name==compoundName)%>%subset(response<300)%>%select(model_name,response,response_type,symptom_name,organism_name,disease_name)%>%unique()
  ggplot(red.tab)+geom_jitter(aes(x=symptom_name,y=response,col=organism_name))+facet_grid(.~response_type)+ggtitle(paste(compoundName,'response across cells'))+theme(axis.text.x = element_text(angle = 45, hjust = 1))
  fname=paste('drugResponsesFrom',compoundName,'.png',sep='')
  ggsave(fname)
  return(fname)
 # ggplot(red.tab)+geom_violin(aes(x=symptom_name,y=response,col=organism_name))+facet_grid(.~response_type)+ggtitle(paste(compoundName,'response across cells'))+theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
}

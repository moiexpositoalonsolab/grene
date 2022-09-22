## generate GrENE-net records data ()
## Author: Tati
## Date: April 25 2022

##### this should b deleted soon
# cleandates will be used so we need functions from grene
#load_all()
cleandates<-function(mydate){
  newdate<-paste0(substr(mydate,1,4), "-",
                  substr(mydate,5,6), "-",
                  substr(mydate,7,8)
  )
  return(as.Date(newdate))
}
###############################

####
## Preprocess of GrENE-net samples sent for sequencing (the ones preprocessed by Ru will be used) in https://drive.google.com/drive/folders/1Unx3cb5WYUtxUQ0ETlNO9j6dz6FsHPKt
###

library(tidyverse)
library(readxl)

# Load sample dataset
samples = read_csv("data-raw/samples_sorted.csv")
samples

# create sample id and select relevant columns
samples <-  samples %>%
  filter(is.na(TO_SKIP)) %>%
  dplyr::mutate(
     SAMPLE_ID=paste('ML',SAMPLE_ID, '01', sep=''), # add ML (moi lab) and 01 based on seq or reseq
     SAMPLE_ID=str_remove_all(SAMPLE_ID, "-"),
     DATE=cleandates(DATE), # to make it R understandable
     ) %>%
  dplyr::rename('sampleid'='SAMPLE_ID',
                'code'='CODES',
                'site'='SITE',
                'plot'='PLOT',
                'date'='DATE',
                'flowerscollected'='NUMBER_FLOWERS_COLLECTED') %>%
  dplyr::select(sampleid, code, site, plot, date, flowerscollected)

# Write out
write.table(census,file = "data/samples_test.csv",quote = T,col.names = T,row.names = F)
#usethis::use_data(recordssorted,overwrite = T)





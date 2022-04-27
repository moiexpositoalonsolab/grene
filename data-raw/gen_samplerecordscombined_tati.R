## generate GrENE-net records data ()
## Author: Tati
## Date: April 25 2022

####
## Takes data from GrENE-net_records_2017-2021 which includes sample and census datasets
## - For samples dataset the ones preprocessed by Ru will be used (the ones send for sequencing)
## - For census datasets the ones from  GrENE-net_records_2017-2021 will be used
## This script process samples and census data and dumps r data files to be used in the package
###

library(tidyverse)
library(readxl)

################################################################################
cleandates<-
function(mydate){
  newdate<-paste0(substr(mydate,1,4), "-",
                  substr(mydate,5,6), "-",
                  substr(mydate,7,8)
  )
  return(as.Date(newdate))
}
################################################################################
# Load census spreadsheets
# import census sheets ######################

filename = "data-raw/census_samples.xlsx"
sheets <- openxlsx::getSheetNames(filename)

census_sheets = sheets %>%
  str_subset(pattern = "Census*")

sheetlist_census <- lapply(census_sheets,readxl::read_excel,path=filename,
                           col_types = c("guess", "guess", "text", "guess", "text","text", "text","text", "text","guess", "guess"))

names(sheetlist_census) <- census_sheets
census = bind_rows(sheetlist_census, .id = "column_label")

#census <-  census %>%
#           dplyr::mutate(
#                         D=cleandates(DATE)) # to make it R understandable

write.table(census,file = "data/census.tsv",quote = F,col.names = T,row.names = F)
usethis::use_data(census,overwrite = T)


################################################################################
##### Load sorted flower records by RU ####
samples_sorted = read_csv("data-raw/samples_sorted.csv")
samples_sorted

# create sample id including formatting dicussed as  MLFH-01-01-20180518-01
samples_sorted <-  samples_sorted %>%
  filter(is.na(TO_SKIP)) %>%
  dplyr::mutate(
     SAMPLE_ID=paste('ML',SAMPLE_ID, '-01', sep=''), # add ML (moi lab) and 01 based on seq or reseq
     DATE=cleandates(DATE), # to make it R understandable
   )

# Add day of year
samples_sorted <- samples_sorted %>%
  dplyr::mutate(year=substr(DATE,start = 1,4)) %>%
  dplyr::mutate(startyear=as.Date(paste0(year,"0101"),format="%Y%m%d")) %>%
  dplyr::mutate(doy= as.numeric(D- startyear))

# Write out
write.table(census,file = "data/recordssorted",quote = F,col.names = T,row.names = F)
usethis::use_data(recordssorted,overwrite = T)





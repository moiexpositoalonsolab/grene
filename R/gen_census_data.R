## generate GrENE-net census_data
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
## Preprocess of GrENE-net census datasets from  GrENE-net_records_2017-2021 google drive doc
####

library(tidyverse)
library(readxl)

# load census/samples spreadsheets
filename = "data-raw/census_samples.xlsx"
sheets <- openxlsx::getSheetNames(filename)

# get only the sheets that are census data
census_sheets = sheets %>%
  str_subset(pattern = "Census*")

sheetlist_census <- lapply(census_sheets,readxl::read_excel,path=filename,
                           col_types = c("guess", "guess", "numeric", "guess", "text","text", "text","text", "text","guess", "guess"))

names(sheetlist_census) <- census_sheets
census = bind_rows(sheetlist_census)

# select only relevant columns,
# add leading 0 to rich common width ,
# rename for format and consistency purposes
# and create census_id (site-plot-date)

census = census %>%
  dplyr::select('SITE', 'PLOT', 'DATE', 'DIAGONAL_PLANT_NUMBER', 'OFF-DIAGONAL_PLANT_NUMBER',
                'TOTAL_PLANT_NUMBER\n(OPTIONAL)', 'MEAN_FRUITS_PER_PLANT\n(OPTIONAL)', 'SD_FRUITS_PER_PLANT\n(OPTIONAL)',
                'COMMENTS') %>%
  dplyr::mutate(DATE=cleandates(DATE)) %>%
  dplyr::rename('site'='SITE',
                'plot'='PLOT',
                'date'='DATE',
                'diagonalplantnumber'='DIAGONAL_PLANT_NUMBER',
                'offdiagonalplantnumber'='OFF-DIAGONAL_PLANT_NUMBER',
                'totalplantnumber'='TOTAL_PLANT_NUMBER\n(OPTIONAL)',
                'meanfruitsperplant'='MEAN_FRUITS_PER_PLANT\n(OPTIONAL)',
                'sdfruitsperplant'='SD_FRUITS_PER_PLANT\n(OPTIONAL)',
                'comments'='COMMENTS') %>%
  dplyr::mutate(site = sprintf("%02d",site),
                plot = sprintf("%02d",plot)) %>%
  dplyr::mutate(censusid=paste(site,plot,date, sep = ''))

census

## creating a sampleid that matches the censusid

write.table(census,file = "data/census_test.csv",quote = T,col.names = T,row.names = F)
#usethis::use_data(census,overwrite = T)






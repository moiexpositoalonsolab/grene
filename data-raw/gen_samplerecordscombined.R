## generate GrENE-net records data
## Author: Moi
## Date: Mar 22 2020
library(tidyverse)

library(readxl)
filename = "data-raw/census_samples.xlsx"
sheets <- openxlsx::getSheetNames(filename)

sample_sheets = sheets %>%
  str_subset(pattern = "Samples*")

census_sheets = sheets %>%
  str_subset(pattern = "Samples*")

SheetList_samples <- lapply(sample_sheets,readxl::read_excel,path=filename,
                            col_types = c("guess", "guess", "text", "guess", "guess","text", "guess","guess", "guess"))

names(SheetList_samples) <- sample_sheets

samples = bind_rows(SheetList_samples, .id = "column_label")

samples



records_list = list.files(path="./data-raw", pattern = 'GrENE-net_records_2017-2020-Samples_\\d{4}.csv$', full.names = TRUE)
records = str_remove_all(toString(records_list), ',')
system(sprintf('cat %s | sed s/,,/,na,/g | sed s/,,/,na,/g > ./data-raw/records_raw.csv', records))

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
# Load joint spreadsheets
records<-read.csv("data-raw/records_raw.csv",stringsAsFactors = F)

# Fix known errors
library(dplyr)
records <- records %>%
  dplyr::filter(!is.na(SAMPLE_ID)) %>%
  dplyr::mutate(
                D=cleandates(DATE) , # to make it R understandable
                RECODE=str_sub(SAMPLE_ID,1,2) # Some people collected soil but added FH in the column code
                )
records$SAMPLE_ID[grepl("2012", records$SAMPLE_ID)] # some samples were mistakenly coded as 2012 when they were 2020
records$SAMPLE_ID[grepl("2012", records$SAMPLE_ID)] <- gsub(records$SAMPLE_ID[grepl("2012", records$SAMPLE_ID)], pattern = "2012",replacement = "2020",fixed = T)

# Save in data
write.table(records,file = "data/records.tsv",quote = F,col.names = T,row.names = F)
usethis::use_data(records,overwrite = T)

################################################################################
# Load census spreadsheets

records_list = list.files(path="./data-raw", pattern = 'GrENE-net_records_2017-2020-Census_\\d{4}.csv$', full.names = TRUE)
records = str_remove_all(toString(records_list), ',')
system(sprintf('cat %s > ./data-raw/census_raw.csv', records))

census<-read.csv("data-raw/census_raw.csv",stringsAsFactors = F)

# View(census)
census <-  census %>%
           dplyr::mutate(
                         D=cleandates(DATE)) # to make it R understandable


write.table(census,file = "data/census.tsv",quote = F,col.names = T,row.names = F)
usethis::use_data(census,overwrite = T)


################################################################################
##### Load sorted flower records by RU ####
d2018<-read.csv("data-raw/GrENE-net_records_2018_SORTED.txt.csv",stringsAsFactors = F,header=T, fill = T)
d2019<-read.csv("data-raw/GrENE-net_records_2019_SORTED.txt.csv",stringsAsFactors = F,header=T, fill = T)
    # 2020 to be sorted
recordssorted<-rbind(d2018,d2019)

recordssorted <-  recordssorted %>%
                  dplyr::mutate(
                    D=cleandates(DATE),
                    RECODE=str_sub(SAMPLE_ID,1,2) # Some people collected soil but added FH in the column code
                    ) # to make it R understandable


# Correct those records that were missing, but Ru read
recordssorted <- recordssorted %>%
                    mutate(SAMPLE_ID=paste(sep='-',CODES,SITE,PLOT,DATE))
                    # mutate(SAMPLE_ID= ifelse(SAMPLE_ID=="", paste(sep='-',CODES,SITE,PLOT,DATE), SAMPLE_ID))
# dplyr::filter(recordssorted_, Notes.by.Ru=='Missing record')

# Clean IDS
# cleansampleid<-function(libnames=c("MLFH130320180405","MLFH13_1_20190122")){ # this does not work
#   mytmp<-tempfile(pattern = "file", tmpdir = tempdir(), fileext = "")
#   write.table(file = mytmp, x=libnames,quote = F,row.names = F,col.names = F)
#   mytmp2<-tempfile(pattern = "file", tmpdir = tempdir(), fileext = "")
#   system(paste('./data-raw/homogenizesampleID.sh', mytmp, mytmp2))
#   cleanid<-read.table(mytmp2,stringsAsFactors = F,header = F)$V1
#   return(cleanid)
# }
cleansampleid<-function(libnames=
                          c("MLFH130320180405","MLFH-13-1-20190122","MLFH-54-11-20180427","FH-1-6-20180409","FH-10-1-20180130","FH-10-1-20180130")
                        ){
  libnames %>%
    gsub("-", "_", .) %>% #
    gsub("FH", "MLFH", .) %>% # fix start with FH
    gsub("MLML", "ML", .) %>%
    gsub("_0", "_", .) %>%
    gsub("FH_1_", "FH01_", .) %>%
    gsub("FH_2_", "FH02_", .) %>%
    gsub("FH_3_", "FH03_", .) %>%
    gsub("FH_4_", "FH04_", .) %>%
    gsub("FH_5_", "FH05_", .) %>%
    gsub("FH_6_", "FH06_", .) %>%
    gsub("FH_7_", "FH07_", .) %>%
    gsub("FH_8_", "FH08_", .) %>%
    gsub("FH_9_", "FH09_", .) %>%
    gsub("_1_", "01", .) %>%
    gsub("_2_", "02", .) %>%
    gsub("_3_", "03", .) %>%
    gsub("_4_", "04", .) %>%
    gsub("_5_", "05", .) %>%
    gsub("_6_", "06", .) %>%
    gsub("_7_", "07", .) %>%
    gsub("_8_", "08", .) %>%
    gsub("_9_", "09", .) %>%
    gsub("_10_", "10", .) %>%
    gsub("_11_", "11", .) %>%
    gsub("_12_", "12", .) %>%
    gsub("_13_", "13", .) %>%
    gsub("_14_", "14", .) %>%
    gsub("_15_", "15", .) %>%
    gsub("_16_", "16", .) %>%
    gsub("_17_", "17", .) %>%
    gsub("_18_", "18", .) %>%
    gsub("_", "", .) #%>%
    #as.matrix
}

recordssorted$id <- cleansampleid(recordssorted$SAMPLE_ID)

# Add day of year
recordssorted <- recordssorted %>%
  dplyr::mutate(year=substr(DATE,start = 1,4)) %>%
  dplyr::mutate(startyear=as.Date(paste0(year,"0101"),format="%Y%m%d")) %>%
  dplyr::mutate(D=cleandates(DATE)) %>%
  dplyr::mutate(doy= as.numeric(D- startyear))

# Write out
write.table(census,file = "data/recordssorted",quote = F,col.names = T,row.names = F)
usethis::use_data(recordssorted,overwrite = T)


##### >>>>>>>> TO MERGE BOTH RECOREDS WE WILL NEED TO MANUALLY CURATE A LOT! <<<<<<<<<,####
# there are many exception cases, as participants did a number of random things

# ################################################################################
# # Merge original records and Ru's sorted records
#
# ## Clean the original records
# load("data/records.rda")
# # Start cleaning records are correct but badly formatted
# records <- records %>%
#   # change delimiters
#   dplyr::mutate(SAMPLE_ID= gsub(SAMPLE_ID,pattern = "_",replacement = '-')) %>% # some used _ as separator instead of -
#   dplyr::mutate(SAMPLE_ID= gsub(SAMPLE_ID,pattern = " ",replacement = '-')) %>% # some used _ as separator instead of -
#   # fix records that have flower counts but were labeled as SB-
#   dplyr::mutate(SAMPLE_ID= ifelse(as.numeric(NUMBER_FLOWERS_COLLECTED)>0 & RECODE=="SB" & CODES =="FH", paste("FH",SITE,PLOT,DATE,sep='-'), SAMPLE_ID) ) %>%
#   dplyr::mutate(SAMPLE_ID= ifelse(as.numeric(NUMBER_FLOWERS_COLLECTED)>0 & RECODE=="FH" & CODES =="SB", paste("FH",SITE,PLOT,DATE,sep='-'), SAMPLE_ID) ) %>%
#   # Fix records where they did not add in front FH or any record
#   dplyr::mutate(SAMPLE_ID= ifelse(RECODE != "FH" & as.numeric(NUMBER_FLOWERS_COLLECTED)>0, paste("FH",SITE,PLOT,DATE,sep='-'), SAMPLE_ID) ) %>%
#   # recreate the RECODE column which just indicates the first two positions of the ID, easy way to get the FH value
#   dplyr::mutate(RECODE=str_sub(SAMPLE_ID,1,2))
# # Start removing everything is not a record
# records<-records %>%
#   dplyr::filter(SAMPLE_ID != "",
#                 SAMPLE_ID != "none",
#                 SAMPLE_ID != "na",
#                 SAMPLE_ID != "-"
#                 ) # people reported records despite not collecting samples
# records<-records %>%
#   # Finally fix again the sample id name because people did not merge correctly FH, site, plot, but repeated incorrectly the same plot
#   dplyr::mutate(SAMPLE_ID=paste(CODES,SITE,PLOT,DATE,sep='-') )
#
# # Remove remaining duplicates (likely due to copying in the online spreadsheet in two year sheets the same data, which then combining spreadsheets gave )
# records<- records[!duplicated(records$SAMPLE_ID),]
#
# # And remove what is not FH as Ru only worked with FH
# records<-dplyr::filter(records, RECODE=="FH")
#
# ## Clean Ru's records
# load("data/recordssorted.rda")
# recordssorted <- recordssorted %>%
#   # recreate recode column
#   dplyr::mutate(RECODE=str_sub(SAMPLE_ID,1,2)) %>%
#   # Not necessary to try to merge tubes that were missing
#   dplyr::filter(!(Notes.by.Ru  %in% c("TrayLost", "Missing tube", "Unknownsample")))
#
# recordssorted <- recordssorted %>%
#   # Fix records where they did not add in front FH or any record
#   dplyr::mutate(SAMPLE_ID= ifelse(RECODE != "FH" & as.numeric(NUMBER_FLOWERS_COLLECTED)>0, paste("FH",SITE,PLOT,DATE,sep='-'), SAMPLE_ID) )
#
# ######
# # Merge
# records$SAMPLE_ID <- as.character(records$SAMPLE_ID)
# recordssorted$SAMPLE_ID <- as.character(recordssorted$SAMPLE_ID)
#
# # Remove the G variable that Ru manually removed
# records<- dplyr::mutate(SAMPLE_ID= gsub(SAMPLE_ID,pattern = "G",replacement = '')) %>% # Martjin site 57 added a G to some records
#   # >>>>>>
#
# # merge
# recordsmerged<-merge(
#                      records, # only need FH to merge with Ru, as Ru only looked through FH
#                      dplyr::select(recordssorted,SAMPLE_ID,Notes.by.Ru ,NUMBER_FLOWERS_COLLECTED),
#                      by="SAMPLE_ID",
#                      all=T) # If all.y, I will exclude the 2020 samples which are not in Carnegie yet
#
# # Because some tubes were not registered in the online records, codes, site plot, date are NA in merged records. Fix programmatically
# parsegrenenetsample<-function(mystring="FH-1-3-20180518 ", position=1){
#   mystring<-gsub(mystring,pattern = "_",replacement = "-",fixed = T) # some used _ instead of - as separator
#   sapply(mystring,function(i) strsplit(i,split = "-",fixed = T)[[1]][position])
# }
# recordsmerged <-
#   recordsmerged %>%
#   # dplyr::filter(recordsmerged, is.na(CODES)) %>%
#       dplyr::mutate(
#         CODES=ifelse(is.na(CODES),parsegrenenetsample(SAMPLE_ID,1), CODES),
#         SITE=ifelse(is.na(SITE),parsegrenenetsample(SAMPLE_ID,2), SITE),
#         PLOT=ifelse(is.na(PLOT),parsegrenenetsample(SAMPLE_ID,3), PLOT),
#         DATE=ifelse(is.na(DATE),parsegrenenetsample(SAMPLE_ID,4), DATE)
#       ) %>%
#       dplyr::mutate(
#         D=cleandates(DATE),
#         RECODE=str_sub(SAMPLE_ID,1,2)
#         )
#
# # Remove records as long as there is NA in Sample ID, CODES, SITE, PLOT, DATE, NUMBER of flowers, all together.
# recordsmerged$
#
# ##
#
# write.table(census,file = "data/recordsmerged",quote = F,col.names = T,row.names = F)
# usethis::use_data(recordsmerged,overwrite = T)


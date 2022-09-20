## generate GrENE-net participant data
## Author: Moi
## Date: Mar 22 2020

## Take table sitesinfo and filter it by the sites sites that haven't been reported or started
## Create table of sites with no success
## Dump sitesinfo (filtered), sites_not_reported_or_started and sites_with_no_success in /data

################################################################################

# samplerec<-read.delim("data-raw/GrENE-net_records_sheet1.tsv",fill=T)
# demorec<-read.delim("data-raw/GrENE-net_records_sheet2.tsv",fill=T)
# samplerec<-read.delim("/data-raw/GrENE-net_records_2017-2018 - Samples.tsv",fill=T)
# demorec<-read.delim("data-raw/GrENE-net_records_2017-2018 - Census .tsv",fill=T)

sitesinfo<-read.csv("data-raw/GrENE-sites_info-CuratedParticipants.csv",fill=T) #%>%
# dplyr::filter(NAME!="Moises Exposito-Alonso") #%>%
# dplyr::filter(NAME!="Marcelo Sternberg")

sites_with_no_success<-matrix(
  c("Mohamed Abdelaziz",	20,
    "Mohamed Abdelaziz",	21,
    "Jasmin Joshi",	19,
    "Martijn Herber",	30,
    "Paula Kover",	35,
    "Zuzana Münzbergova",	41,
    "Anne Muola",	56,
    "Karin Koehl",	47,
    "John Stinchcombe",	50,
    "John Stinchcombe",	51,
    "Rob Colautti",	3,
    "Joy Bergelson",	7
  ),ncol=2,byrow=T
)

sites_not_reported_or_started<-matrix(
  c(
    "Svante Holm"	,44,
    "Angela Hancock",	59,
    "Marcelo Sternberg",	31,
    "David Salt", 36
  ),ncol=2,byrow=T
)

# sitesinfo <- dplyr::filter(sitesinfo,!(SITE_CODE %in% sites_not_reported_or_started)) # Sites that failed to start remove
sitesinfo %>% dplyr::filter(SITE_CODE %in% sites_not_reported_or_started)


# what does this do??
## sitesinfo$NAME<-fc(sitesinfo$NAME)

rownames(sitesinfo)<-sitesinfo$SITE_CODE

usethis::use_data(sitesinfo,overwrite = T)
usethis::use_data(sites_not_reported_or_started,overwrite = T)
usethis::use_data(sites_with_no_success,overwrite = T)

# # samplerec$NAME<-sitesinfo[samplerec$Site,"NAME"]
# # samplerec$LONGITUDE<-sitesinfo[samplerec$Site,"LONGITUDE"]
# # samplerec$LATITUDE<-sitesinfo[samplerec$Site,"LATITUDE"]
# #
# # demorec$NAME<-sitesinfo[demorec$Site,"NAME"]
# # demorec$LONGITUDE<-sitesinfo[demorec$Site,"LONGITUDE"]
# # demorec$LATITUDE<-sitesinfo[demorec$Site,"LATITUDE"]
#
#
# samplerec$D<- paste0(substr(samplerec$Date,1,4), "-",
#                      substr(samplerec$Date,5,6), "-",
#                      substr(samplerec$Date,7,8)
# )
# samplerec$D<- as.Date(samplerec$D)
#
# demorec$D<- paste0(substr(demorec$Date,1,4), "-",
#                    substr(demorec$Date,5,6), "-",
#                    substr(demorec$Date,7,8)
# )
# demorec$D<- as.Date(demorec$D)
#
# Create a table eith information about all the ecotypes used in the experiment (seedmix)
# author Moi+Tati
# date oct 4 2022

library(dplyr)

## import dataset of all Arabidopsis accessions
ac=read.csv("data-raw/AccessionsIDs.csv",fill = T,header=T)

## create accessions_clean dataframe where all accessions wil be placed
accessions_clean=data.frame(id=ac$ID)
accessions_clean$latitude = NA
accessions_clean$longitude = NA
accessions_clean$country = NA
accessions_clean$name = NA
accessions_clean$CS = NA
accessions_clean$dataset=NA

latcols=grep("latitude", colnames(ac))
loncols=grep("longitude", colnames(ac))
councols=grep("country", colnames(ac))
namecols=grep("name", colnames(ac))
cscols=grep("CS", colnames(ac))

fc<-function (data.frame)
{
  as.character(as.matrix(data.frame))
}
fn<-function (data.frame)
{
  as.numeric(as.matrix(data.frame))
}
rm.empty=function(x){
  x[x!="" & x!=" "]
}
 null2na=function(x){
   ifelse(is.null(x),NA,x)
 }

for( i in 1:nrow(accessions_clean) ){

nrow(accessions_clean)

myid=accessions_clean$id[i]
sub=filter(ac, ID==myid)

# Find which dataset each acession comes from
ex=sub[,latcols[-4]] %>% fn()
ex=which(!is.na(ex))
dataset=""
if( any(ex %in% 1 )) {
  dataset="1001G"
}else if( any(ex %in% c(2,3) & ex %in% 1 ) ){
  dataset=paste(dataset, "RegMap", sep="_")
}else if( any(ex %in% c(2,3 )) ){
  dataset="RegMap"
}

## add all the information to the accessions_clean dataset
accessions_clean$dataset[i] = dataset
accessions_clean$latitude[i] = sub[,latcols] %>% fn() %>% na.omit() %>% fn() %>% rm.empty() %>% unique() %>% head(1) %>% null2na()
accessions_clean$longitude[i] =sub[,loncols] %>% fn() %>% na.omit() %>% fn() %>% rm.empty() %>% unique() %>% head(1) %>% null2na()
accessions_clean$country[i] = sub[,councols] %>% fc() %>% na.omit() %>% fc() %>% rm.empty() %>% unique() %>% head(1) %>% null2na()
accessions_clean$name[i] = sub[,namecols] %>% fc() %>% na.omit() %>% fc() %>% rm.empty() %>% unique() %>% head(1) %>% null2na()
accessions_clean$CS[i] =sub[,cscols] %>% fc() %>% na.omit() %>% fc() %>% rm.empty() %>% unique() %>% head(1) %>% null2na()
}

# import country names accessions_clean
country=read.table(header=F, "data-raw/country_ISO_codes.tsv",sep = "\t", stringsAsFactors = FALSE)

country2iso=function(x){
  sapply(x, function(x){
  x=gsub(x,pattern = " ", replacement = "_")
  ifelse(x %in% country[,2] , country[ which(country[,2] ==x ) ,1], x )
  })
}

accessions_clean$country=accessions_clean$country %>% country2iso()

## import the dataset including all the ecotypes and corresponding weights used in the seedmix (founder seeds of the experiment!)
ecotypes_seedmix <- read.csv("data-raw/ecotypes_seedmix.csv",header=T,stringsAsFactors = F)

ecotypes<- merge(accessions_clean,
                  ecotypes_seedmix[ , c("ecotypeid", "weightmasterseed", "estimatedseednumber", "seedsperplot")],
                  by.x = 'id',
                  by.y = "ecotypeid", all.y=T
)
#head(ecotypes_seedmix)
#head(accessions_clean)
#head(ecotypes)

write.csv(file="data/ecotypes_data_test.csv",ecotypes)
#devtools::use_data(grenelist,overwrite = T)


## here, we should add theGrene-Net ecotypes - GrENE-net_final_list to actaully generate the ecotypes dataframe
library(dplyr)

ac=read.csv("data-raw/AccessionsIDs.csv",fill = T,header=T)
head(ac)

clean=data.frame(id=ac$ID)
clean$latitude = NA
clean$longitude = NA
clean$country = NA
clean$name = NA
clean$CS = NA
clean$dataset=NA



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

for( i in 1:nrow(clean) ){

myid=clean$id[i]
sub=filter(ac, ID==myid)

# Find which dataset it come from
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
clean$dataset[i] = dataset

clean$latitude[i] = sub[,latcols] %>% fn() %>% na.omit() %>% fn() %>% rm.empty() %>% unique() %>% head(1) %>% null2na()
clean$longitude[i] =sub[,loncols] %>% fn() %>% na.omit() %>% fn() %>% rm.empty() %>% unique() %>% head(1) %>% null2na()
clean$country[i] = sub[,councols] %>% fc() %>% na.omit() %>% fc() %>% rm.empty() %>% unique() %>% head(1) %>% null2na()
clean$name[i] = sub[,namecols] %>% fc() %>% na.omit() %>% fc() %>% rm.empty() %>% unique() %>% head(1) %>% null2na()
clean$CS[i] =sub[,cscols] %>% fc() %>% na.omit() %>% fc() %>% rm.empty() %>% unique() %>% head(1) %>% null2na()


}

# country names clean
country=read.table(header=F, "data-raw/country_ISO_codes.tsv",sep = "\t", stringsAsFactors = FALSE)
head(country)
tail(country)

country2iso=function(x){
  sapply(x, function(x){
  x=gsub(x,pattern = " ", replacement = "_")
  ifelse(x %in% country[,2] , country[ which(country[,2] ==x ) ,1], x )
  })
}

clean$country=clean$country %>% country2iso()

write.table(clean,"data/Arabidopsis_thaliana_world_accessions_list.tsv",quote = F,row.names = F)
Arabidopsis_thaliana_world_accessions_list=clean
usethis::use_data(Arabidopsis_thaliana_world_accessions_list)


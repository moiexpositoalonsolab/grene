# Create a master table from all the GrENE net releases in SRA
# author Moi+Tati
# date Mar 30 2021

library(dplyr)
########
## Because the seq company was changed, there are two types of files:
## - From release 01-08: release folders will have a folder inside (raw_data) where the files are named
## with the sample_id provided by us
## - From release 09-on: release folder will have folders with the files names with codes assigned by
## the company and a key folder that will relate their keys with ou sample_ids
########
# Find releasess
releases<- list.files("/Carnegie/DPB/Data/Shared/Labs/Moi/Everyone/SRA/grenenet-phase1", pattern = "ath-release",full.names = T)
releases

### only select releases 01 to 08
pattern = paste(sprintf(paste("ath-release-0",seq(1:8), sep=''),seq(1:8)), collapse="|")
first_releases = releases[stringr::str_detect(releases,pattern)]

# Find fastq files under each release
fastqfiles_firstreleases <-lapply(first_releases, function(x) {
        tmp<-list.files(x, pattern = "*.fq.gz",recursive = T,full.names = T)
        tmp<-tmp[!grepl("Undeter",tmp)]
        tmp<-tmp[!grepl("CYCLE",tmp)]
        #tmp<-tmp[!grepl("_2.fq",tmp)] # Do not report the read two, as everything would be duplicated
        tmp<-tmp[grepl("MLFH",tmp)] # This is our golden code of libraries produced in grene net by Moi Lab ML
})

fastqfiles_firstreleases<-unlist(fastqfiles_firstreleases)

# Clean names for table
#cleanfq<- as.character(sapply(fastqfiles_firstreleases, function(x) tail(strsplit(x,split = "/",fixed = T)[[1]],1)))

#cleanfq
sampleid<- as.character(sapply(fastqfiles_firstreleases, function(x) head(tail(strsplit(x,split = "/",fixed = T)[[1]],2),1)))
#cleanrelease<- as.character(sapply(fastqfiles, function(x) head(tail(strsplit(x,split = "/",fixed = T)[[1]],4),1)))

# Build table, providing some useful columns
tableseq<-data.frame(fastq=fastqfiles_firstreleases,sample_id=sampleid, stringsAsFactors = F)

### there are >10 special cases where the samples were sent twice to seq and they have an A or B at the end
### only if they have a B is a second unit so will be named like that, in any opther case is the first unit
tableseq = tableseq %>%
  mutate(unit = ifelse(str_detect(sample_id, 'B'),2,1)) %>%
  mutate(sample_id = str_remove_all(sample_id, 'A|B'))

tableseq = tableseq %>%
  mutate(date_released = substr(sample_id, nchar(sample_id)-8+1, nchar(sample_id))) %>% ## create separete column for date
  mutate(test = str_remove_all(sample_id,paste(c(date_released), collapse = '|'))) %>% ## remove dates
  mutate(test = str_remove_all(test,'MLFH')) %>% ## remove general code
  mutate(read = substr(fastq, nchar(fastq)-7+1, nchar(fastq)-6)) #left or right read

## this set of samples, the site and plot is separeted by _ so will be treated separetly
tableseq1 = tableseq %>%
  filter(str_detect(test, '_')) %>%
  mutate(site = as.numeric(str_remove_all(substr(test, 1, 2), '_')))  %>%
  mutate(plot = as.numeric(str_remove_all(substr(test, nchar(test)-2+1, nchar(test)), '_')))

## this set of samples, the site and plot is not separeted by _ and there are leading 0 in the values so will ve treated sep
tableseq[is.na(tableseq)]
tableseq2 = tableseq %>%
  filter(!str_detect(test, '_'))  %>%
  mutate(site = as.numeric(substr(test, 1, 2))) %>%
  mutate(plot = as.numeric(substr(test, nchar(test)-2+1, nchar(test))))


tableseq = rbind(tableseq1, tableseq2)
tableseq$test = NULL

tableseq = tableseq %>%
  mutate(sample_id = paste0('MLFH', sprintf("%02d", site), sprintf("%02d", plot), date_released))

##########################################################
## releases 09 on

# Store
seqtable=tableseq
write.table(seqtable,file = "data-raw/seqtable.csv",quote = F,col.names = T,row.names = F)
#usethis::use_data(seqtable,overwrite = T)

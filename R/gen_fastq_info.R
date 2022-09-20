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

#cleaning becuase relseas contain the same files (release 5 in particular)
files =  as.character(sapply(fastqfiles_firstreleases, function(x) strsplit(x,split = "/",fixed = T)[[1]][14]))
#nrow(table_files)
table_files<-data.frame(fastq=fastqfiles_firstreleases,files=files, stringsAsFactors = F)
table_files = table_files %>% distinct(files, .keep_all = TRUE)
nrow(table_files)


fastqfiles_firstreleases = table_files$fastq
# Clean names for table
#cleanfq<- as.character(sapply(fastqfiles_firstreleases, function(x) tail(strsplit(x,split = "/",fixed = T)[[1]],1)))

#cleanfq
sampleid = as.character(sapply(fastqfiles_firstreleases, function(x) head(tail(strsplit(x,split = "/",fixed = T)[[1]],2),1)))
file_for_seqcer = as.character(sapply(fastqfiles_firstreleases, function(x) strsplit(x,split = "/",fixed = T)[[1]][13]))

#cleanrelease<- as.character(sapply(fastqfiles, function(x) head(tail(strsplit(x,split = "/",fixed = T)[[1]],4),1)))

# Build table, providing some useful columns
tableseq<-data.frame(fastq=fastqfiles_firstreleases,sample_id=sampleid, file_for_seqcer = file_for_seqcer, stringsAsFactors = F)



tableseq
### there are >10 special cases where the samples were sent twice to seq and they have an A or B at the end
### only if they have a B is a second unit so will be named like that, in any opther case is the first unit
tableseq = tableseq %>%
  mutate(special_replicate = if_else(str_detect(sample_id, 'B'), 'B', '')) %>%
  mutate(special_replicate = if_else(str_detect(sample_id, 'A'), 'A', '')) %>%
  mutate(sample_id = str_remove_all(sample_id, 'A|B'))

tableseq = tableseq %>%
  mutate(date_released = substr(sample_id, nchar(sample_id)-8+1, nchar(sample_id))) %>% ## create separete column for date
  mutate(test = str_remove_all(sample_id,paste(c(date_released), collapse = '|'))) %>% ## remove dates
  mutate(test = str_remove_all(test,'MLFH')) %>% ## remove general code
  mutate(read = as.numeric(substr(fastq, nchar(fastq)-7+1, nchar(fastq)-6))) #left or right read

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



tableseq1 = rbind(tableseq1, tableseq2)

## drop intermediate columns
tableseq1$sample_id_test = NULL
tableseq1$test = NULL

tableseq1 = tableseq1 %>%
  mutate(sample_id = paste0('MLFH', sprintf("%02d", site), sprintf("%02d", plot), date_released, special_replicate))

##########################################################
## releases 09 on
### only select releases 01 to 08
second_releases = releases[!stringr::str_detect(releases,pattern)]
second_releases

##find the keys
key_files = list.files(second_releases, pattern = "*Key.csv",recursive = T,full.names = T)
## read the keys and make one dataframe of them
keys <-lapply(key_files, function(x) {read_csv(x)})
keys = bind_rows(keys)

## fint he fastqfiles
fastqfiles_secondreleases <-lapply(second_releases, function(x) {
  tmp<-list.files(x, pattern = "*.fastq.gz",recursive = T,full.names = T)
})

fastqfiles_secondreleases<-unlist(fastqfiles_secondreleases)

#21093FL-01-01-01
example= "/Carnegie/DPB/Data/Shared/Labs/Moi/Everyone/SRA/grenenet-phase1/2021-12-06-ath-release-11/21093-02/21093FL-02-01-28_S28_L001_R2_001.fastq.gz"
strsplit(example,split = "/",fixed = T)[[1]]
strsplit(strsplit(example,split = "/",fixed = T)[[1]][13],split = "_",fixed = T)[[1]][4][1]

file_for_seqcer = as.character(sapply(fastqfiles_secondreleases, function(x) strsplit(strsplit(x,split = "/",fixed = T)[[1]][13],split = "_",fixed = T)[[1]][1]))
read = as.numeric(sapply(fastqfiles_secondreleases, function(x) str_replace(strsplit(strsplit(x,split = "/",fixed = T)[[1]][13],split = "_",fixed = T)[[1]][4], 'R', '')))

# Build table, providing some useful columns
tableseq2 = data.frame(fastq=fastqfiles_secondreleases,sample_id=file_for_seqcer, read= read, file_for_seqcer=file_for_seqcer, stringsAsFactors = F)
names(tableseq2)
## drop duplciated files (generated by the way seq were sent)
tableseq2 = merge(tableseq2, keys, by.x = "file_for_seqcer",
      by.y = "Admera Health Library ID", all.x = TRUE, all.y = FALSE)


names(tableseq2)
names(tableseq2)
names(tableseq2)[5]= 'sample_id'
head(tableseq1)
head(tableseq2)
names(tableseq2)
names(tableseq1)

## bind all reads
tableseq <- rbind(tableseq1[ , c("sample_id", "fastq", "file_for_seqcer", "read")], tableseq2[, c("sample_id", "fastq","file_for_seqcer", "read")])
head(tableseq)

tableseq = tableseq %>%
  mutate(file_for_seqcer = paste0(file_for_seqcer, sprintf("%02d", read)))

## some samples might be reseq so they might be present in one release and the in other release
head(tableseq)
tableseq = tableseq %>%
  group_by(file_for_seqcer) %>%
  mutate(unit = as.integer(paste0(row_number())))

#for adding the reseq in the sampleid
#tableseq
#tableseq = tableseq %>%
#  mutate(sample_id = paste0(sample_id, sprintf("%02d", resequenced)))

tableseq$file_for_seqcer = NULL
head(tableseq)
result = pivot_wider(tableseq, names_from = read, values_from = fastq)
result

hola = result %>% filter(unit == 3)
hola
nrow(tableseq)


hola = c("/Carnegie/DPB/Data/Shared/Labs/Moi/Everyone/SRA/grenenet-phase1/2021-01-29-ath-release-01/raw_data/MLFH_1_1_20180409/MLFH_1_1_20180409_CKDL210000711-1a-AK11638-AK9050_HFLJFCCX2_L6_1.fq.gz", "/Carnegie/DPB/Data/Shared/Labs/Moi/Everyone/SRA/grenenet-phase1/2021-02-18-ath-release-03/raw_data/MLFH_1_1_20180409/MLFH_1_1_20180409_CKDL210000711-1a-AK11638-AK9050_HFLHHCCX2_L2_1.fq.gz")
hola[1]
hola[2]
table(tableseq1$fastq)
n_occur <- data.frame(table(tableseq1$fastq))
n_occur
n_occur[n_occur$Freq > 1,]
MLFH570120181003

sub = result %>% filter(sample_id == 'MLFH570120181003')
sub
sub$'1'
sub$'2'

head(tableseq)
dim(tableseq)
# Store
seqtable=tableseq
write.table(seqtable,file = "data-raw/seqtable.csv",quote = F,col.names = T,row.names = F)
#usethis::use_data(seqtable,overwrite = T)

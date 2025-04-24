# Title: A record of surveying the SRA file directory and find all fastq files
# Author: Meixi Lin
# Date: Sat Mar  9 10:45:32 2024

# preparation --------
rm(list = ls())
cat("\014")
options(echo = TRUE, stringsAsFactors = FALSE)

library(dplyr)
date()
sessionInfo()

## old fastqdir
# fastqdir = "/Carnegie/DPB/Data/Shared/Labs/Moi/Everyone/SRA/grenenet-phase1"
fastqdir = "/Carnegie/DPB/Data/Shared/Labs/Moi/Everyone/BERKELEY/raw/SRA/grenenet-phase1"
workdir = "/Carnegie/DPB/Data/Shared/Labs/Moi/Everyone/ath_evo/grenephase1"
setwd(workdir)

# function --------
extract_nth_element <- function(stringv,ii) {
    out <- sapply(stringv, function(string) strsplit(string, '/')[[1]][ii])
    return(out)
}

# find release folders --------
## Because the seq company was changed, there are two types of files:
## - From release 01-08: release folders will have a folder inside (raw_data) where the files are named
## with the sample_id provided by us
## - From release 09-on: release folder will have folders with the files names with codes assigned by
## the company and a key folder that will relate their keys with our sample_ids
## - release 10 need to be skipped. Not for main grene-net analyses

releases <- list.files(fastqdir, pattern = "ath-release",full.names = T)
print(releases)

# releases 01-08 --------
first_releases = releases[1:8]
first_releases
# Find fastq files under each release
fastqfiles_firstreleases <- lapply(first_releases, function(x) {
    tmp <- list.files(x, pattern = ".fq.gz",recursive = TRUE,full.names = TRUE)
    # This is our golden code of libraries produced in grene net by Moi Lab ML
    out <- tmp[grepl('MLFH', tmp)]
    # print the removed files
    print(paste0('Release ', x, ': the following Fastq files not considered'))
    print(gsub(x, "", setdiff(tmp,out)))
    return(out)
})
lapply(fastqfiles_firstreleases, length)
fastqfiles_firstreleases <- unlist(fastqfiles_firstreleases)
length(fastqfiles_firstreleases) # 3948 elements
# remove the fastqdir header
fastqfiles_firstreleases <- gsub(fastqdir, ".", fastqfiles_firstreleases)

# releases 09, 11 --------
# MLFH570120190821 had two sequences: 21093FL-02-02-03 and 21093FL-02-02-08
# There is one file called "21093FL-02-04-32_S320_L004_R1_001_broken.fastq.gz"
# all other files were correctly formatted
second_releases = releases[c(9,10)]
second_releases

## find the keys
key_files = list.files(second_releases, pattern = "*Key.csv",recursive = TRUE,full.names = TRUE)
## read the keys and make one dataframe of them
keys <- lapply(key_files, function(x) {
    y = read.csv(x)
    colnames(y) = c('seqid','sampleid')
    return(y)
})
keys <- dplyr::bind_rows(keys) # 914 rows

# 2023-01-27 note: interestingly, this is also the sampleid not processed by grenepipe
keys$sampleid[duplicated(keys$sampleid)] # MLFH570120190821

## find the fastqfiles
fastqfiles_secondreleases <-lapply(second_releases, function(x) {
    tmp <- list.files(x, pattern = ".fastq.gz",recursive = TRUE,full.names = TRUE)
})
fastqfiles_secondreleases <- unlist(fastqfiles_secondreleases)
length(fastqfiles_secondreleases) # 1829 elements
# remove the fastqdir header
fastqfiles_secondreleases <- gsub(fastqdir, ".", fastqfiles_secondreleases)

# data frame for releases 01-08 --------
# data frame generation is required in this step because the keys information again depends on existing file structures
filesdt1 <- data.frame(
    fullpath = fastqfiles_firstreleases,
    datereleased = extract_nth_element(fastqfiles_firstreleases, 2),
    sampleid = extract_nth_element(fastqfiles_firstreleases, 4),
    filename = extract_nth_element(fastqfiles_firstreleases, 5),
    row.names = NULL
) %>%
    dplyr::mutate(fileprefix = substring(filename,1, nchar(filename)-8)) %>%
    dplyr::mutate(direction = dplyr::case_when(grepl('_1.fq.gz',filename) ~ 'R1',
                                               grepl('_2.fq.gz',filename) ~ 'R2',
                                               TRUE ~ NA_character_))
length(unique(filesdt1$sampleid)) # 1502 unique ids

table(substring(filesdt1$filename,nchar(filesdt1$filename)-7, nchar(filesdt1$filename)))

# data frame for releases 09,11 --------
filesdt2 <- data.frame(
    fullpath = fastqfiles_secondreleases,
    datereleased = extract_nth_element(fastqfiles_secondreleases, 2),
    filename = extract_nth_element(fastqfiles_secondreleases, 4),
    row.names = NULL
) %>%
    # match sequence id with sample id
    dplyr::mutate(seqid = gsub("_(.*?)$", "", filename)) %>%
    dplyr::full_join(., y = keys, by = "seqid") %>%
    dplyr::select(fullpath, datereleased, filename, sampleid) %>%
    dplyr::mutate(fileprefix = substring(filename,1, nchar(filename)-16)) %>%
    dplyr::mutate(direction = dplyr::case_when(grepl('_R1_001.fastq.gz',filename) ~ 'R1',
                                               grepl('_R2_001.fastq.gz',filename) ~ 'R2',
                                               TRUE ~ NA_character_))
length(unique(filesdt2$sampleid)) # 913 unique ids
table(substring(filesdt2$filename,nchar(filesdt2$filename)-15, nchar(filesdt2$filename)))

# output files --------
filesdt = rbind(filesdt1, filesdt2)
write.table(filesdt, file = "data-raw/fastq_info_raw.tsv", sep = "\t", row.names = FALSE)

# cleanup --------
date()
closeAllConnections()

# Rscript --vanilla data-raw/python_scripts/gen_fastq_info_raw.R &> logs/gen_fastq_info_raw.log



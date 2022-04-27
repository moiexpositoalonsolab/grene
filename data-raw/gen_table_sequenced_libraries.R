# Create a master table from all the GrENE net releases in SRA
# author Moi
# date Mar 30 2021

library(dplyr)

# Find release
releases<- list.files("/Carnegie/DPB/Data/Shared/Labs/Moi/Everyone/SRA/", pattern = "ath-grene",full.names = T)

# Find fastq files under each release
fastqfiles<-lapply(releases, function(x) {
        tmp<-list.files(x, pattern = "*.fq.gz",recursive = T,full.names = T)
        tmp<-tmp[!grepl("Undeter",tmp)]
        tmp<-tmp[!grepl("CYCLE",tmp)]
        tmp<-tmp[!grepl("_2.fq",tmp)] # Do not report the read two, as everything would be duplicated
        tmp<-tmp[grepl("MLFH",tmp)] # This is our golden code of libraries produced in grene net by Moi Lab ML
})
fastqfiles<-unlist(fastqfiles)

# Clean names for table
cleanfq<- as.character(sapply(fastqfiles, function(x) tail(strsplit(x,split = "/",fixed = T)[[1]],1)))
cleanlibrary<- as.character(sapply(fastqfiles, function(x) head(tail(strsplit(x,split = "/",fixed = T)[[1]],2),1)))
cleanrelease<- as.character(sapply(fastqfiles, function(x) head(tail(strsplit(x,split = "/",fixed = T)[[1]],4),1)))

# Build table, providing some useful columns
tableseq<-data.frame(fastq=cleanfq,sample_id=cleanlibrary,sra_folder=cleanrelease)

# Add date column
tableseq<-dplyr::mutate(tableseq, date_released=substr(sra_folder,1,10))

# Clean sample ID names to standardize
cleansampleid<-function(libnames=c("MLFH130320180405","MLFH13_1_20190122")){
  mytmp<-tempfile(pattern = "file", tmpdir = tempdir(), fileext = "")
  write.table(file = mytmp, x=libnames,quote = F,row.names = F,col.names = F)
  mytmp2<-tempfile(pattern = "file", tmpdir = tempdir(), fileext = "")
  system(paste('../data-raw/homogenizesampleID.sh', mytmp, mytmp2))
  cleanid<-read.table(mytmp2,stringsAsFactors = F,header = F)$V1
  return(cleanid)
}
tableseq$id=as.character(cleansampleid(tableseq$sample_id))

# Add the unit
tableseq<-
  tableseq %>%
      dplyr::arrange(sample_id) %>%
      group_by(id) %>%
      dplyr::mutate(unit_seq_run=as.numeric(duplicated(id))+1)

# Add the lane within data release
extractlane<-function(fastqnames=c("MLFH13_1_20181128_CKDL210000711-1a-AK7838-AK24534_HFLJFCCX2_L6_1.fq.gz")) {
  sapply(fastqnames, function(x){
        head(tail(strsplit(x,split = "_",fixed = T)[[1]],2),1)
  })
}
tableseq<-
  tableseq %>%
  dplyr::ungroup() %>%
  dplyr::mutate(release_lane= extractlane(fc(fastq)))


# Store
seqtable=tableseq
write.table(seqtable,file = "../data/seqtable.tsv",quote = F,col.names = T,row.names = F)
usethis::use_data(seqtable,overwrite = T)

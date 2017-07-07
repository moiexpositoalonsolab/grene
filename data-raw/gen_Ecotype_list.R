library(moiR)

# g1001 <- read.csv("~/ath_1001G_history/p1001_MOTHER_DATABASE_DOWNSAMPLING/1001_Master_List_May2013.csv")
g1001 <- read.csv("data-raw/1001genomes-accessions.csv",header = T)

# gn <- read.table("data-raw/Ecotype_list.txt")
gn <- read.table("data-raw/Ecotype_list_final.txt")

grenelist<- merge(g1001[,colnames(g1001) %in% c("id","country","latitude","longitude")], by.x="id",
      gn, by.y = "V1", all.y=T
      )
dim(gn)
dim(grenelist)

# write.tsv(file="Ecotype_list_info.tsv",gn.info)
write.tsv(file="data/Ecotype_list_info_final.tsv",grenelist)
devtools::use_data(grenelist,overwrite = T)

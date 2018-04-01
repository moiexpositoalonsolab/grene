library(moiR)
library(dplyr)

# g1001 <- read.csv("~/ath_1001G_history/p1001_MOTHER_DATABASE_DOWNSAMPLING/1001_Master_List_May2013.csv")
# g1001 <- read.csv("data-raw/1001genomes-accessions.csv",header = T)
# g1001_regmap <- read.csv("data-raw/AccessionsIDs.csv",header = T)

Ath=Arabidopsis_thalina_world_accessions_list()
head(Ath)

grene <- read.delim("data-raw/Grene-Net ecotypes - aliquote.tsv",header=T,stringsAsFactors = F)
head(grene)
dim(grene)

grenelist<- merge(Ath,
      data.frame(id=grene[,1]),
      by = "id", all.y=T
      )
head(grenelist)
dim(grenelist)

# write.tsv(file="Ecotype_list_info.tsv",gn.info)
write.tsv(file="data/Ecotype_list_info_final.tsv",grenelist)
devtools::use_data(grenelist,overwrite = T)

View(grenelist)

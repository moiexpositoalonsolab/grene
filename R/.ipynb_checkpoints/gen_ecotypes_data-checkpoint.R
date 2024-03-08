# Create a table with information about all the ecotypes used in the experiment (seedmix)
# author Tati
# date oct 11 2022

rm(list = ls())
library(dplyr)

## import dataset with all the accessions used in the experiment
our_acc=read.csv("data-raw/ecotypes_seedmix.csv",fill = T,header=T)

## import dataset with accessions from 1001g project
g1001_acc=read.csv("data-raw/accessions_1001g.csv",fill = T,header=T)

## import dataset with accessions from arapheno project
arapheno_acc=read.csv("data-raw/accessions_arapheno.csv",fill = T,header=T)

# bring info from 1001g
our_acc = merge(our_acc, g1001_acc[c("id", "Lat", "Long", 'CS.Number')], all.x = TRUE, by.x = 'ecotypeid', by.y = 'id')

# some accessions did not come from the 1001g project
missing_acc = subset(our_acc, is.na(our_acc$Lat))$ecotypeid

#take info for those accessions from arapheno project
arapheno_acc = subset(arapheno_acc, arapheno_acc$pk %in% missing_acc)
our_acc = merge(our_acc, arapheno_acc[c('pk', 'latitude','longitude')], all.x = TRUE, by.x = 'ecotypeid', by.y = 'pk')

# replace missing lat and long
our_acc$Lat[is.na(our_acc$Lat)] <- our_acc$latitude[is.na(our_acc$Lat)]
our_acc$Long[is.na(our_acc$Long)] <- our_acc$longitude[is.na(our_acc$Long)]

# correct the 2 israeli accessions that are not in arapheno
our_acc[our_acc$ecotypeid == 100001, "Long"]  = 35.797398
our_acc[our_acc$ecotypeid == 100001, "Lat"]  = 33.093931
# Corrected ecotype ID for the second accession
our_acc[our_acc$ecotypeid == 100002, "Long"]  = 35.788213
our_acc[our_acc$ecotypeid == 100002, "Lat"]  = 33.176177

# select only relevant variables
myvars <- c("ecotypeid", "Long", "Lat", 'CS.Number', 'name', 'country' , 'weightmasterseed',
            'estimatedseednumber', 'seedsperplot')

# Use select() with any_of() to select columns without causing an error if some columns are missing
our_acc <- our_acc %>% select(any_of(myvars))

# rename those variables
cnames = c("ecotypeid", "longitude", "latitude", 'csnumber', 'name', 'country' , 'weightmasterseed',
  'estimatedseednumber', 'seedsperplot')

names(our_acc) = cnames

# Modification: Add CS number for the ones that were missing according to Xing's edits
# And comparison with previous versions
# Date: Mon Feb 13 14:39:20 2023
ecotypes_data = our_acc
ecotypes_data[ecotypes_data$ecotypeid == 9940, c('csnumber', 'name')] <- c('CS76348', 'Toufl-1 / ice50')
ecotypes_data[ecotypes_data$ecotypeid == 9977, c('csnumber', 'name')] <- c('CS76349', 'Vezzano2-1 / ice226')
ecotypes_data[ecotypes_data$ecotypeid == 9992, 'csnumber'] <- 'CS76386'
ecotypes_data[ecotypes_data$ecotypeid == 6939, 'csnumber'] <- 'CS22642'

# Add dataset source
ecotypes_data = ecotypes_data %>%
    dplyr::mutate(source = case_when(ecotypeid %in% c(100001, 100002) ~ 'israel',
                                     ecotypeid %in% c(9940, 9977, 9992) ~ '80-pilot',
                                     ecotypeid %in% c(6939) ~ 'regmap',
                                     TRUE ~ '1001G')) %>%
    dplyr::relocate(source, .after = ecotypeid) %>%
    dplyr::arrange(ecotypeid)

################
source('R/use_grene_data.R')
################

use_grene_data(ecotypes_data)
#write.csv(our_acc,"data/ecotypes_data.csv", row.names = FALSE, quote = T)


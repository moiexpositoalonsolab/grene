# Create a table with information about all the ecotypes used in the experiment (seedmix)
# author Tati
# date oct 11 2022

library(dplyr)

## import dataset with all the accessions used in the experiment
our_acc=read.csv("data-raw/ecotypes_seedmix.csv",fill = T,header=T)

## import dataset with accessions from 1001g project
g1001_acc=read.csv("data-raw/accessions_1001g.csv",fill = T,header=T)

## import dataset with accessions from arapheno project
arapheno_acc=read.csv("data-raw/accessions_arapheno.csv",fill = T,header=T)

## import dataset with isocodes
iso_codes=read.csv("data-raw/country_isocodes.csv",fill = T,header=T)

# bring info from 1001g
our_acc = merge(our_acc, g1001_acc[c("id", "Lat", "Long", 'CS.Number')], all.x = TRUE, by.x = 'ecotypeid', by.y = 'id')
names(g1001_acc)

# some accessions did not come from the 1001g project
missing_acc = subset(our_acc, is.na(our_acc$Lat))$ecotypeid

#take info for those accessions from arapheno project
arapheno_acc = subset(arapheno_acc, arapheno_acc$pk %in% missing_acc)
our_acc = merge(our_acc, arapheno_acc[c('pk', 'latitude','longitude')], all.x = TRUE, by.x = 'ecotypeid', by.y = 'pk')

# replace missing lat and long
our_acc$Lat[is.na(our_acc$Lat)] <- our_acc$latitude[is.na(our_acc$Lat)]
our_acc$Long[is.na(our_acc$Long)] <- our_acc$longitude[is.na(our_acc$Long)]

# use isocodes to get actual country names
our_acc = merge(our_acc, iso_codes, all.x = TRUE, by.x = 'country', by.y = 'code')

# select only relevant variables
myvars <- c("ecotypeid", "Long", "Lat", 'CS.Number', 'name', 'country.y' , 'weightmasterseed',
            'estimatedseednumber', 'seedsperplot')
our_acc <- our_acc[myvars]

# rename those variables
cnames = c("ecotypeid", "longitude", "latitude", 'csnumber', 'name', 'country' , 'weightmasterseed',
  'estimatedseednumber', 'seedsperplot')
names(our_acc) = cnames

#save dataset ecotypes
write.csv(our_acc,"data/ecotypes_data.csv", row.names = FALSE, quote = T)


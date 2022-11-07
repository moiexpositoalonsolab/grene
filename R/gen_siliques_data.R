# Create table with all the info about siliques counting uploaded by thte aprticipants
# author Tati
# date nov 1 2022

library(dplyr)

## import dataset with siliques raw data
siliques_data=read.csv("data-raw/siliques_data_raw.csv",fill = T,header=T)
names(siliques_data)

# rename columns
cnames = c("Measurement", "site", "plot", 'date', 'transect', 'individual' , 'plantid',
           'siliquesnumber', 'comments')
names(siliques_data) = cnames

# select only relevant variables
myvars <- c('plantid',"site", "plot", 'date', 'transect', 'individual' ,
            'siliquesnumber', 'comments')
siliques_data <- siliques_data[myvars]

#save dataset siliques

################
source('R/use_grene_data.R')
################
use_grene_data(siliques_data)
#write.csv(our_acc,"data/ecotypes_data.csv", row.names = FALSE, quote = T)


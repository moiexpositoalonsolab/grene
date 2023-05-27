# Title: generate a matrix of reconstructed ecotype frequencies per sample
# Author: Moi Exposito-Alonso
# Date: May 27 2023 023
#

require(tidyverse)

gen_ecotype_frequency_data<-function(folder="/NOBACKUP/scratch/xwu/grenet/hapFE/ecotype_frequency/"){
    require(dplyr)
    # list all sample files of ecotype frequencies
    # myfiles<-list.files(folder)[1:10]
    myfiles<-list.files(folder)
    x=myfiles[1]
    # iterate over all, read
    # name a column with sample names
    # merge all files
    readall<-lapply(myfiles,FUN = function(x){
        samplename<-strsplit(x,split = "_",fixed = T)[[1]][1]
        paste0(folder,myfiles[1]) %>% read.table %>%
            dplyr::rename(ecotype=V1, freq=V2) %>%
            mutate(sample=samplename)
    }) %>% do.call(rbind,.)

}

ecofreq<-gen_ecotype_frequency_data(folder="/NOBACKUP/scratch/xwu/grenet/hapFE/ecotype_frequency/")

# Make a long and a wide version of the data
ecotypes_frequencies_long=ecofreq
ecotypes_frequencies_wide = ecotypes_frequencies_long

ecotypes_frequencies_wide <- ecofreq %>%
    spread(key = sample, value = freq)

# ecotypes_frequencies_wide[1:5,1:5]

# require(usethis)
# save into R file
use_data(ecotypes_frequencies_wide)
use_data(ecotypes_frequencies_long)

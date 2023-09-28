# Title: Migrate Xing's merged_sample_table.csv and add a column for the sampleids that were inputted in the merge
# Author: Meixi Lin
# Date: Fri Jun  2 18:05:23 2023

gen_merged_samples_data <- function() {
    # preparation --------
    rm(list = ls())
    options(echo = TRUE, stringsAsFactors = FALSE)

    source('R/use_grene_data.R') # these needs to be removed
    library(diffdf)

    # load data --------
    load('./data/samples_data.rda')
    # sort the site generation and plot
    merged_samples = read.csv('/Carnegie/DPB/Data/Shared/Labs/Moi/Everyone/ath_evo/grenephase1-data/meta_table/merged_sample_table.csv') %>%
        dplyr::arrange(site, generation, plot)

    # find samples that pass filters and needs merging --------
    out_samples_data = samples_data %>%
        dplyr::filter(usesample) %>%
        dplyr::mutate(newvar = paste(site, generation_merge57, plot, sep = '_'),
                      generation_merge57 = as.integer(generation_merge57)) %>%
        dplyr::group_by(newvar, site, generation_merge57, plot, weighted_mean_coverage) %>%
        dplyr::summarise(nruns = n(),
                         nflowers = as.integer(sum(flowerscollected)),.groups = 'drop',
                         sampleidlist = paste(sampleid, collapse = ';')) %>%
        dplyr::rename(sample_name = newvar,
                      total_flower_counts = nflowers,
                      sample_times = nruns) %>%
        dplyr::arrange(site, generation_merge57, plot)

    # check with merged_sample_table.csv using the current data --------
    merged_samples_data = out_samples_data[,c(1,7,5,6,2:4,8)]
    colnames(merged_samples_data) = c(colnames(merged_samples), 'sampleidlist')
    # everything matches
    diffdf(merged_samples_data[,-8], merged_samples)

    # output files --------
    use_grene_data(merged_samples_data)
    return(invisible())
}

gen_merged_samples_data()

# Title: generate weatherstation summary data (bioclim variables)
# Author: Meixi Lin
# Date: Fri Feb  3 17:49:10 2023
# Modification: Fix the bug that precipitation should be summed but were averaged in previous version
# Date: Fri Feb  2 21:27:18 2024


options(echo = TRUE, stringsAsFactors = FALSE)

gen_weatherstation_bioclim <- function() {
    print(date())
    rm(list = ls())

    require(dplyr)
    require(lubridate)
    # install.packages('dismo') # only works with R 4.2.1 version
    source('R/custom_biovars.R')
    source('R/use_grene_data.R')

    #######################################################################
    # define variables

    #######################################################################
    # load data
    # weather station data
    # version: require precipitation data. Maximum distance 50 km. needs at least 250 days.
    load('data/weatherstation_data.rda') # md5: 46851497fe96ea995264eb9010f57515
    # load('data/worldclim_sitesdata.rda')

    #######################################################################
    # get monthly summary
    ws_month = weatherstation_data %>%
        dplyr::mutate(weatheryear = lubridate::year(weatherdate),
                      weathermonth = lubridate::month(weatherdate),
                      siteyear = paste(site, weatheryear, sep = '_')) %>%
        dplyr::group_by(site, siteyear, stationid, weatheryear, weathermonth) %>%
        dplyr::summarise(temp = mean(temp, na.rm = T),
                         # although it is max temp, need to use mean here to match bioclim results. i.e. average max temperature in a month
                         maxt = mean(max, na.rm = T),
                         # although it is min temp, need to use mean here to match bioclim results. i.e. average min temperature in a month
                         mint = mean(min, na.rm = T),
                         prcp = sum(prcp, na.rm = T), # need to sum since precipitation is summed over BUGFIX 2024-02-02
                         ndata = n())

    ws_monthl = base::split(ws_month, ws_month$siteyear)

    #######################################################################
    # calculate bioclim
    bioclim_l = sapply(ws_monthl, custom_biovars)
    dimnames(bioclim_l)[[1]] = paste0('bio',1:19)
    # format things better
    bioclimdt = bioclim_l %>%
        t() %>%
        as.data.frame() %>%
        tibble::rownames_to_column(var = 'siteyear')
    siteyear = reshape2::colsplit(bioclimdt$siteyear, '_', c('site','year')) %>%
        dplyr::mutate_all(., as.integer)
    weatherstation_bioclim = cbind(siteyear, bioclimdt) %>%
        dplyr::select(-siteyear) %>%
        dplyr::arrange(site, year)

    #######################################################################
    # output the files
    use_grene_data(weatherstation_bioclim)
    return(invisible())
}

# Rscript --vanilla R/gen_weatherstation_bioclim.R &> ./logs/gen_weatherstation_bioclim.log

gen_weatherstation_bioclim()

# VERSION INFO:
# Previous buggy files are now in data/ARCHIVE/data-versions/weatherstation_bioclimBUGNOTUSE.csv[rda]
# mv ./logs/gen_weatherstation_bioclim.log data/ARCHIVE/data-versions/gen_weatherstation_bioclimBUGNOTUSE.log

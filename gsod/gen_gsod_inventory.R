# Title: Generate an inventory of the GSOD locations by each year
# Author: Meixi Lin
# Date: Fri Nov 18 14:24:00 2022

# preparation --------
rm(list = ls())
cat("\014")
options(echo = TRUE, stringsAsFactors = FALSE)

setwd("/Carnegie/DPB/Data/Shared/Labs/Moi/Everyone/ath_evo/grenephase1")
date()
sessionInfo()

require(dplyr)

# def functions --------
get_locations <- function(year) {
    mypath = paste0('./gsod/noaa-ftp/', year, '/')
    weatherfiles = list.files(path = mypath)
    # get locations using lapply
    weather_locsl = lapply(weatherfiles, function(xx) {
        dt = read.csv(file = paste0(mypath, xx),
                      colClasses = c(rep("character", 4), rep("NULL", 24)))
        dt = dt[,c('STATION', 'LATITUDE', 'LONGITUDE')]
        dt = dt[!duplicated(dt), ]
        if (nrow(dt) != 1) {
            stop('Wrong weather station location format.')
        }
        return(dt)
    })
    # combine all the lists
    weather_locs0 = dplyr::bind_rows(weather_locsl) %>%
        dplyr::mutate(LATITUDE = as.numeric(LATITUDE),
                      LONGITUDE = as.numeric(LONGITUDE))
    # remove the ones without long/lat info
    weather_locs = weather_locs0 %>%
        tidyr::drop_na()
    saveRDS(weather_locs, file = paste0(outdir, 'stations_loc_nona_', year, '.rds'))
    write.table(weather_locs, file = paste0(outdir, 'stations_locc_nona_', year, '.tsv'), sep = '\t')
    return(weather_locs)
}

multi_intersect <- function(varl) {
    outvar = base::intersect(varl[[1]], varl[[2]])
    for (ii in 3:length(varl)) {
        outvar = base::intersect(outvar, varl[[ii]])
    }
    return(outvar)
}

# def variables --------
years = seq(2017, 2021)
outdir = './gsod/noaa-ftp/inventory/'
dir.create(outdir)

# load data --------

# main --------
stations_byyear = lapply(years, get_locations)

# only keep the locations that have been available throughout five years
stations_name = lapply(stations_byyear, function(xx) {
    out = xx$STATION
    print(length(out))
    return(out)
})
# The number of stations
# [2017] 12299
# [2018] 12387
# [2019] 12348
# [2020] 12260
# [2021] 12238

# intersect the stations
stations_all5 = multi_intersect(stations_name) # 11531 stations
# get their locations
stations_all5_locs = stations_byyear[[1]] %>%
    dplyr::filter(STATION %in% stations_all5)

# output files --------
saveRDS(stations_all5_locs, file = paste0(outdir, 'stations_loc_nona_2017-2021.rds'))
write.table(stations_all5_locs, file = paste0(outdir, 'stations_loc_nona_2017-2021.tsv'), sep = '\t')

# cleanup --------
date()
closeAllConnections()

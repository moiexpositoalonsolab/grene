# Title: Generate an inventory of the GSOD locations by each year
# Author: Meixi Lin
# Date: Fri Nov 18 14:24:00 2022
# Modification: Add precipitation availability
# Date: Thu Feb  2 12:55:52 2023
# README for GSOD: https://www.ncei.noaa.gov/data/global-summary-of-the-day/doc/readme.txt
# Usage: Rscript --vanilla gsod/gen_gsod_inventory.R logs/gen_gsod_inventory.log

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
    # Modification: Get precipitation data availability and number of observations
    # Date: Thu Feb  2 12:44:24 2023
    weather_locsl = lapply(weatherfiles, function(xx) {
        dt = read.csv(file = paste0(mypath, xx),
                      colClasses = c('character','NULL','character','character', rep("NULL", 20),
                                     'character','character','NULL','NULL'))
        dt1 = dt[,c('STATION', 'LATITUDE', 'LONGITUDE')]
        dt1 = dt1[!duplicated(dt1), ]
        if (nrow(dt1) != 1) {
            stop('Wrong weather station location format.')
        }
        # check for the precipitation format
        prcpt = apply(dt, 1, function(xx){
            out = unname(xx['PRCP'] == ' 0.00' & xx['PRCP_ATTRIBUTES'] == 'I') | (xx['PRCP'] == '99.99')
            return(out)
        })
        # PRCPAVAIL = Availability of Precipitation data
        if (all(prcpt)) {
            dt1$PRCPAVAIL=FALSE
        } else {
            dt1$PRCPAVAIL=TRUE
        }
        dt1$NOBS = nrow(dt)
        return(dt1)
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

multi_fulljoin <- function(dtl, years) {
    outdt = dplyr::full_join(dtl[[1]],dtl[[2]], by = c('STATION','LATITUDE','LONGITUDE'), suffix = paste0('_',years[1:2]))
    for (ii in 3:length(dtl)) {
        outdt = dplyr::full_join(outdt, dtl[[ii]], by = c('STATION','LATITUDE','LONGITUDE'))
        colnames(outdt)[(ncol(outdt)-1):ncol(outdt)] = paste0(c('PRCPAVAIL_','NOBS_'), years[ii])
    }
    return(outdt)
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
# get their locations and precipitation availability data
stations_all5_locs = multi_fulljoin(dtl = stations_byyear, years = years) %>%
    dplyr::filter(STATION %in% stations_all5)

# output files --------
saveRDS(stations_all5_locs, file = paste0(outdir, 'stations_loc_nona_2017-2021.rds'))
write.table(stations_all5_locs, file = paste0(outdir, 'stations_loc_nona_2017-2021.tsv'), sep = '\t')

# dim(stations_all5_locs) is 12445 obs of 13 variables. There are duplicated station ids due to differences in their lat long

# cleanup --------
date()
closeAllConnections()

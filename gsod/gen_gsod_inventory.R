# Title: Generate an inventory of the GSOD locations by each year
# Author: Meixi Lin
# Date: Fri Nov 18 14:24:00 2022
# Modification: Add precipitation availability
# Date: Thu Feb  2 12:55:52 2023
# README for GSOD: https://www.ncei.noaa.gov/data/global-summary-of-the-day/doc/readme.txt
# Usage: Rscript --vanilla gsod/gen_gsod_inventory.R logs/gen_gsod_inventory.log
# Modification: Add start and end date of the record
# Date: Tue Feb  7 13:40:27 2023

# preparation --------
rm(list = ls())
cat("\014")
options(echo = TRUE, stringsAsFactors = FALSE)

setwd("/Carnegie/DPB/Data/Shared/Labs/Moi/Everyone/ath_evo/grenephase1")
date()
sessionInfo()

require(dplyr)
require(lubridate)

# def functions --------
get_locations <- function(year) {
    mypath = paste0('./gsod/noaa-ftp/', year, '/')
    weatherfiles = list.files(path = mypath)
    # get locations using lapply
    # Modification: Get precipitation data availability and number of observations
    # Date: Thu Feb  2 12:44:24 2023
    weather_locsl = lapply(weatherfiles, function(xx) {
        dt = read.csv(file = paste0(mypath, xx),
                      colClasses = c('character','character','character','character', rep("NULL", 20),
                                     'character','character','NULL','NULL')) %>%
            dplyr::mutate(DATE = as.Date(DATE))
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

        # check for the start and end date of record
        dt1$STARTDATE = min(dt$DATE)
        dt1$ENDDATE = max(dt$DATE)
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
        colnames(outdt)[(ncol(outdt)-3):ncol(outdt)] = paste0(c('PRCPAVAIL_','STARTDATE_','ENDDATE_','NOBS_'), years[ii])
    }
    return(outdt)
}

merge_rows <- function(df) {
    outdf = data.frame(matrix(nrow = 1, ncol = ncol(df)+1))
    df = df %>%
        dplyr::mutate(across(.cols = starts_with('STARTDATE'), .fns = as.character),
                      across(.cols = starts_with('ENDDATE'), .fns = as.character))
    for (ii in 1:ncol(df)) {
        if (colnames(df)[ii] %in% c('LONGITUDE','LATITUDE')) {
            outdf[1,ii] = df[1,ii]
        } else {
            outdf[1,ii] = unique(df[which(!is.na(df[,ii])), ii])
        }
    }
    outdf[1,ncol(outdf)] = paste0('Lat:',df[2,'LATITUDE'],'; Lon:',df[2,'LONGITUDE'])
    colnames(outdf) = c(colnames(df),'ALTLATLONG')
    outdf = outdf %>%
        dplyr::mutate(across(.cols = starts_with('STARTDATE'), .fns = as.Date),
                      across(.cols = starts_with('ENDDATE'), .fns = as.Date))
    return(outdf)
}

check_durations <- function(finaldf) {
    dfmonths = finaldf %>%
        dplyr::mutate(across(.cols = starts_with('STARTDATE'), .fns = lubridate::month),
                      across(.cols = starts_with('ENDDATE'), .fns = lubridate::month))
    dfmonths$passstart = (rowSums(dfmonths %>% dplyr::select(starts_with('STARTDATE')) < 2) == 5)
    dfmonths$passend = (rowSums(dfmonths %>% dplyr::select(starts_with('ENDDATE')) > 11) == 5)
    dfmonths$passnobs = (rowSums(dfmonths %>% dplyr::select(starts_with('NOBS')) > 250) == 5)
    passdurations = dfmonths$passstart & dfmonths$passend & dfmonths$passnobs
    return(passdurations)
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
print(length(stations_all5))
# get their locations and precipitation availability data
stations_all5_locs = multi_fulljoin(dtl = stations_byyear, years = years) %>%
    dplyr::filter(STATION %in% stations_all5) %>%
    dplyr::arrange(STATION)
print(dim(stations_all5_locs))

# remove duplicates in stations_all5_locs
stations_dups = stations_all5_locs %>%
    dplyr::filter(STATION %in% stations_all5_locs$STATION[duplicated(stations_all5_locs$STATION)])
stations_dups = base::split(stations_dups, stations_dups$STATION)
stations_dedup = dplyr::bind_rows(lapply(stations_dups, merge_rows))

stations_notdups = stations_all5_locs %>%
    dplyr::filter(!(STATION %in% stations_all5_locs$STATION[duplicated(stations_all5_locs$STATION)])) %>%
    dplyr::mutate(ALTLATLONG = NA_character_)
stations_all5_locs_dedup = dplyr::bind_rows(stations_dedup, stations_notdups) %>%
    dplyr::arrange(STATION)
print(dim(stations_all5_locs_dedup))

# get some statistics (most have precipitation data)
table(rowSums(stations_all5_locs_dedup %>% dplyr::select(starts_with('PRCPAVAIL'))))
# get the ones that have more than 250 days and start before 02-01 ends after 11-31
stations_all5_locs_dedup$NOBS_FULL = check_durations(stations_all5_locs_dedup)
table(stations_all5_locs_dedup$NOBS_FULL)

# output files --------
saveRDS(stations_all5_locs_dedup, file = paste0(outdir, 'stations_loc_nona_2017-2021.rds'))
write.table(stations_all5_locs_dedup, file = paste0(outdir, 'stations_loc_nona_2017-2021.tsv'), sep = '\t')


# cleanup --------
date()
closeAllConnections()

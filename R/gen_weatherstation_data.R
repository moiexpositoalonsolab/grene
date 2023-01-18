# Title: generate weatherstation data by location_data
# Author: Meixi Lin
# Date: Fri Nov 18 16:29:59 2022
# Data source: Global Surface Summary of the Day

gen_weatherstation_data <- function() {
    print(date())
    rm(list = ls())
    options(echo = TRUE, stringsAsFactors = FALSE)
    source('R/load_gsod_csv.R')
    source('R/nearest_weatherstation.R') # these needs to be removed
    source('R/use_grene_data.R')

    require(dplyr)
    require(stringr)

    #######################################################################
    # define variables
    # variables
    ws_vars = c("site","stationid","weatherdate","temp","dewp","slp","stp","visib",
                "wdsp","mxspd","gust","max","min","prcp","sndp","frshtt")
    ws_info = c("stationid", "dist2site", "station_longitude", "station_latitude",
                "station_altitude", "station_name")

    #######################################################################
    # load data
    load('data/locations_data.rda')
    longlat = locations_data[,c('site','longitude','latitude')]

    # read weather station locations
    stations_all5 = readRDS(file = './gsod/noaa-ftp/inventory/stations_loc_nona_2017-2021.rds')

    #######################################################################
    # get weather stations
    stations_near = nearest_weatherstation(longlat, stations_all5)
    hist(stations_near$dist2site)
    #######################################################################
    # get weather for each of these sites
    # 16 sites only reported the tempature
    noprcp = 0
    weatherstation_datal = vector('list', length = nrow(locations_data))
    weatherstation_infol = vector('list', length = nrow(locations_data))
    for (ii in 1:nrow(stations_near)) {
        stationid = stations_near[ii, 'stationid']
        dt = load_gsod_csv(file_list = paste0('./gsod/noaa-ftp/', 2017:2021, '/', stationid, '.csv'))
        prcp_tb = table(dt$prcp, useNA = 'always')
        if (all(is.na(names(prcp_tb)))) {
            noprcp = noprcp + 1
        }
        dt = dt %>%
            dplyr::mutate(site = stations_near[ii, 'site'],
                          dist2site = stations_near[ii, 'dist2site'])
        # weather station data
        ws_data = dt[,ws_vars]
        ws_infod = dt[,ws_info] %>% dplyr::distinct()
        if (nrow(ws_infod) != 1) {
            warning('Bad weather station info. Keeping only the first row')
            print(ws_infod)
            ws_infod = ws_infod[1,]
        }
        weatherstation_datal[[ii]] = ws_data
        weatherstation_infol[[ii]] = ws_infod
    }
    print(noprcp)

    #######################################################################
    # combine each site's info
    weatherstation_data = dplyr::bind_rows(weatherstation_datal)
    weatherstation_info = dplyr::bind_rows(weatherstation_infol)
    use_grene_data(weatherstation_data)
    use_grene_data(weatherstation_info)
    return(invisible())
}

# Rscript --vanilla R/gen_weatherstation_data.R &> ./logs/gen_weatherstation_data.log

gen_weatherstation_data()





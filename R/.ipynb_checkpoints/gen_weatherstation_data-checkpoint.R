# Title: generate weatherstation data by location_data
# Author: Meixi Lin
# Date: Fri Nov 18 16:29:59 2022
# Data source: Global Surface Summary of the Day
# Modification: Enforce precipitation data
# Date: Fri Feb  3 12:45:24 2023

options(echo = TRUE, stringsAsFactors = FALSE)

gen_weatherstation_data <- function() {
    print(date())
    rm(list = ls())
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
                "station_altitude", "station_name",
                "nobs_2017","nobs_2018","nobs_2019","nobs_2020","nobs_2021", "nobs_full", "prcp_avail")

    #######################################################################
    # load data
    load('data/locations_data.rda')
    longlat = locations_data[,c('site','longitude','latitude')]

    # read weather station locations (will have duplicated stationid due to differences in latlong reports)
    stations_all5 = readRDS(file = './gsod/noaa-ftp/inventory/stations_loc_nona_2017-2021.rds')

    #######################################################################
    # get weather stations
    stations_near0 = nearest_weatherstation(longlat, stations_all5)
    # Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
    # 495.3  7935.8 13063.3 17801.5 25363.8 46687.5
    # require precipitation data
    stations_near0.1 = nearest_weatherstation(longlat, stations_all5, precipitation = TRUE)
    stations_near = nearest_weatherstation(longlat, stations_all5, precipitation = TRUE, fullyear = TRUE)
    # Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
    # 495.3  8511.4 15177.5 19890.6 31155.1 46687.5
    # site 1, 19, 20, 25, 47, 52, 53, 54 did not have any weather station within 50 km with precipitation data
    # site 58 did not have any weather station within 50 km with > 250 days & 12 months data.
    # hist(stations_near$dist2site)
    # plot(stations_near0$dist2site, stations_near$dist2site,type = 'n')
    # text(stations_near0$dist2site, stations_near$dist2site, stations_near$site, col = 'red')
    # text(stations_near0$dist2site, stations_near0.1$dist2site, stations_near0.1$site, col = 'green')

    #######################################################################
    # get weather for each of these sites
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
            dplyr::mutate(site = stations_near[ii,'site']) %>%
            dplyr::arrange(site, weatherdate)
        # weather station data
        ws_data = dt[,ws_vars]
        ws_infod = cbind(unique(dt[, colnames(dt) %in% ws_info]),
                         stations_near[ii, colnames(stations_near) %in% ws_info])[,ws_info]
        if (nrow(ws_infod) != 1) {
            warning('Bad weather station info. Keeping only the first row.')
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





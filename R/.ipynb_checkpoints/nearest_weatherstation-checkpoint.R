# Title: find nearest weather station within given length cutoff
# Author: Meixi Lin
# Date: Fri Nov 18 16:29:59 2022
# Data source: Global Surface Summary of the Day
# Input: longlat, a data frame of site longitude and latitude
# weather_locs, the data frame of weather locations stored in `./gsod/noaa-ftp/inventory`
# Modification: Add support for accessing precipitation data
# Date: Fri Feb  3 09:14:12 2023
# Modification: Add requirement for data availability
# Date: Tue Feb  7 13:39:05 2023


nearest_weatherstation <- function(longlat, weather_locs, dcut = 50*1e+3, precipitation = FALSE, fullyear = FALSE) {
    require(sf)
    require(dplyr)
    site_sf <- sf::st_as_sf(longlat, coords = c('longitude','latitude'), crs = 4326)
    site_buf <- sf::st_buffer(site_sf, dist = dcut)
    weather_sf <- st_as_sf(weather_locs, coords = c('LONGITUDE','LATITUDE'), crs = 4326)
    # for each site, filter for the weather stations that are within the given distance cutoff
    dtlist = vector('list', length = nrow(site_buf))
    for(ii in 1:nrow(site_buf)) {
        dt = st_filter(x = weather_sf, y = site_buf[ii,])
        if (nrow(dt) < 1) {
            stop('No weather station within given dcut. (default 50 km)')
        } else {
            if (precipitation) {
                # require precipitation data
                prcpa = sf::st_drop_geometry(dt) %>%
                    dplyr::select(starts_with('PRCPAVAIL'))
                prcpa = apply(prcpa, 1, all)
                if (all(prcpa == FALSE)) {
                    warning(paste0('No weather station within given dcut has precipitation data. (default 50 km) for site', site_buf$site[ii]))
                    # keep as it is
                } else {
                    dt = dt[prcpa,]
                }
            }
            # require full year data
            if (fullyear) {
                if(sum(dt$NOBS_FULL) == 0) {
                    warning(paste0('No weather station within given dcut has > 250 days & 12 months data. (default 50 km) for site', site_buf$site[ii]))
                } else {
                    dt = dt %>%
                        dplyr::filter(NOBS_FULL == TRUE)
                }
            }
            dtlist[[ii]] = dt
        }
    }
    names(dtlist) = site_buf$site
    # find the closest station
    mindistdfnames = c('site','stationid', 'dist2site', 'altlatlong', 'nobs_2017','nobs_2018','nobs_2019','nobs_2020','nobs_2021', 'nobs_full', 'prcp_avail')
    mindistdf = data.frame(matrix(nrow = nrow(site_buf), ncol = length(mindistdfnames)))
    colnames(mindistdf) = mindistdfnames
    # iterate to get the minimum distances
    for (ii in 1:length(dtlist)) {
        # get the distance within cutoff
        mydist = st_distance(x = dtlist[[ii]], y = site_sf[ii,])
        mindist = min(mydist)
        mindistdt = sf::st_drop_geometry(dtlist[[ii]][which(mydist == mindist), ])
        myprcpa = mindistdt %>% dplyr::select(starts_with('PRCPAVAIL'))
        myprcpa = apply(myprcpa, 1, all)
        # get the minimum distance
        mindistdf[ii,'site'] = names(dtlist)[ii]
        mindistdf[ii,'dist2site'] = mindist
        mindistdf[ii, c('stationid','altlatlong','nobs_2017','nobs_2018','nobs_2019','nobs_2020','nobs_2021', 'nobs_full')] =
            mindistdt[,c('STATION','ALTLATLONG','NOBS_2017','NOBS_2018','NOBS_2019','NOBS_2020','NOBS_2021', 'NOBS_FULL')]
        mindistdf[ii,'prcp_avail'] = unname(myprcpa)
    }
    # hist(mindistdf$dist2site)
    print(summary(mindistdf$dist2site))
    return(mindistdf)
}




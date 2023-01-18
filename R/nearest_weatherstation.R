# Title: find nearest weather station within given length cutoff
# Author: Meixi Lin
# Date: Fri Nov 18 16:29:59 2022
# Data source: Global Surface Summary of the Day
# Input: longlat, a data frame of site longitude and latitude
# weather_locs, the data frame of weather locations stored in `./gsod/noaa-ftp/inventory`
nearest_weatherstation <- function(longlat, weather_locs, dcut = 100*1e+3) {
    require(sf)
    site_sf <- sf::st_as_sf(longlat, coords = c('longitude','latitude'), crs = 4326)
    site_buf <- sf::st_buffer(site_sf, dist = dcut)
    weather_sf <- st_as_sf(weather_locs, coords = c('LONGITUDE','LATITUDE'), crs = 4326)
    # for each site, filter for the weather stations that are within the given distance cutoff
    dtlist = vector('list', length = nrow(site_buf))
    for(ii in 1:nrow(site_buf)) {
        dt = st_filter(x = weather_sf, y = site_buf[ii,])
        if (nrow(dt) < 1) {
            stop('No weather station within given dcut. (default 100 km)')
        } else {
            dtlist[[ii]] = dt
        }
    }
    names(dtlist) = site_buf$site
    # find the closest station
    mindistdf = data.frame(matrix(nrow = nrow(site_buf), ncol = 3))
    colnames(mindistdf) = c('site','stationid', 'dist2site')
    # iterate to get the minimum distances
    for (ii in 1:length(dtlist)) {
        # get the distance within cutoff
        mydist = st_distance(x = dtlist[[ii]], y = site_sf[ii,])
        mindist = min(mydist)
        mindiststation = dtlist[[ii]]$STATION[which(mydist == mindist)]
        # get the minimum distance
        mindistdf[ii,'site'] = names(dtlist)[ii]
        mindistdf[ii,'stationid'] = mindiststation
        mindistdf[ii,'dist2site'] = mindist
    }
    # print(summary(mindistdf$dist2site))
    return(mindistdf)
}




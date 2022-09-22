# get elevation/altitude
# a dirty fix on the latitude since only lat >= -60 & lat <= 60 is available
download_altitude <- function(longitude,latitude) {
    require(raster)
    require(sp)
    mycrs <- "+proj=longlat +datum=WGS84"
    dir.create(path = 'srtm', showWarnings = FALSE)
    # if latitude is more than 60, convert to 60
    if (latitude > 60) {latitude = 60}
    # download raster if not exist
    elev <- tryCatch({
        raster::getData(name = 'SRTM', path = 'srtm', lon = longitude, lat = latitude, download = FALSE)
    }, error = {
        raster::getData(name = 'SRTM', path = 'srtm', lon = longitude, lat = latitude, download = TRUE)
    })
    pt <- sp::SpatialPoints(coords = data.frame(longitude = longitude,latitude = latitude),
                            proj4string = CRS(mycrs))
    # extract from the elev raster
    altitude_value <- unname(raster::extract(x = elev, y = pt, method = 'simple', buffer=NULL))
    return(altitude_value)
}

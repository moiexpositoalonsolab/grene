# extract worldclim data (v2.1) at 0.5 resolution
# author: meixi lin
# date: Wed Nov 16 14:07:26 2022
# longlat:a data frame with two columns: longitude and latitude
# assuming WGS84 projection
extract_worldclim <- function(longlat,
                              myvar = c('bio','tmin','tmax', 'tavg', 'prec', 'srad', 'wind', 'vapr'),
                              datadir = './wc2-0.5/geotiff/') {
    require(raster)
    require(sp)
    mycrs <- "+proj=longlat +datum=WGS84"
    tifffiles <- list.files(path = datadir, pattern = myvar)
    tifffiles <- sort(tifffiles[grepl('.tif', tifffiles)])
    wc <- raster::stack(x = paste0(datadir, tifffiles))
    print(wc)
    print(names(wc))
    pt <- sp::SpatialPoints(coords = longlat,
                            proj4string = CRS(mycrs))
    # extract from the given worldclim raster
    wc_value <- raster::extract(x = wc, y = pt, method = 'simple', buffer=NULL)
    dimnames(wc_value)[[1]] = rownames(longlat) # append site names
    return(wc_value)
}

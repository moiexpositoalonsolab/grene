read.kml <- function(file, layers) {
    require(sp)
    require(rgdal)
    read.layer <- function (layer_name) {
        spobj <- rgdal::readOGR(dsn=file, layer=layer_name)
        coords <- coordinates(spobj)
        colnames(coords) <- c('x', 'y', 'z')[1:ncol(coords)]
        df <- data.frame(coords, spobj@data)
        transform(df, layer=layer_name)
    }
    Reduce(rbind, lapply(layers, read.layer))
}

write.kml <- function (spobj, dsn, layer, var.name, col=bpy.colors(20)) {
    require(maptools)
    dir.create(dsn)
    old_wd <- setwd(dsn)
    ge_grid <- GE_SpatialGrid(spobj)
    layer <- str_replace(layer, ".kml$", "")
    png(
        file = str_c(layer, ".png"),
        width = ge_grid$width,
        height = ge_grid$height,
        bg = "transparent"
    )
    par(mar = c(0, 0, 0, 0), xaxs = "i", yaxs = "i")
    image(spobj, var.name)
    dev.off()
    kml <- kmlOverlay(ge_grid, str_c(layer, ".kml"), str_c(layer, ".png"))
    setwd(old_wd)
    return(kml)
}
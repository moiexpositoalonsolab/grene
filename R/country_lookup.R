country_lookup <- function(longitude,latitude) {
    require(maps)
    out <- lapply(1:length(longitude), function(ii) {
        if(is.na(longitude[ii])) {yy = NA_character_}
        else {yy = maps::map.where(database="world", longitude[ii], latitude[ii])}
        return(yy)
    })
    out = unlist(out)
    # remove the sub region categories
    out = unlist(lapply(out, function(xx) {strsplit(xx, ':')[[1]][1]}))
    return(out)
}

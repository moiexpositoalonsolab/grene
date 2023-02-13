# Title: generate worldclim data by location_data
# Author: Meixi Lin
# Adapted from Moi's previous script
# Date: Wed Nov 16 13:37:45 2022
options(echo = TRUE, stringsAsFactors = FALSE)

gen_worldclim_sitesdata <- function() {
    print(date())
    rm(list = ls())
    source('R/extract_worldclim.R') # these needs to be removed
    source('R/use_grene_data.R')

    require(dplyr)
    require(stringr)

    #######################################################################
    # define variables
    # variables
    wc_vars = c('bio','tmin','tmax', 'tavg', 'prec', 'srad', 'wind', 'vapr')

    #######################################################################
    # small function to rename the header
    new_colnames <- function(oldname,
                             myvar = c('bio','tmin','tmax', 'tavg', 'prec', 'srad', 'wind', 'vapr')) {
        out = reshape2::colsplit(oldname, pattern = '_', names = c('ver','res','var','sub')) %>%
            dplyr::mutate(sub0 = as.integer(sub))
        if (myvar == 'bio') {
            out = out %>%
                dplyr::mutate(out = paste0(var, sub))
        } else {
            out = out %>%
                dplyr::mutate(out = paste0(var, stringr::str_pad(sub, width = 2, side = 'left', pad = '0')))
        }
        return(out$out)
    }

    #######################################################################
    # load data
    load('data/locations_data.rda')
    longlat = locations_data[,c('longitude','latitude')]
    rownames(longlat) = locations_data$site

    #######################################################################
    # extract worldclim
    wc_dtlist0 = lapply(wc_vars, extract_worldclim, longlat = longlat)
    names(wc_dtlist0) = wc_vars
    wc_dtlist = lapply(wc_vars, function(xx) {
        wcdt = wc_dtlist0[[xx]]
        oldname = dimnames(wcdt)[[2]]
        newname = new_colnames(oldname, myvar = xx)
        dimnames(wcdt)[[2]] = newname
        wcdt = data.frame(wcdt, row.names = NULL) # drops dimnames[[1]]
        return(wcdt)
    })
    # Modification: BUG FIXED the bio10 were falsely labeled as bio2 in the previous version
    # Date: Mon Feb 13 14:58:00 2023
    worldclim_sitesdata = dplyr::bind_cols(wc_dtlist) %>%
        dplyr::mutate(site = as.integer(dimnames(wc_dtlist0[[1]])[[1]])) %>% # append the dimnames for sanity check
        dplyr::relocate(., site) %>%
        dplyr::relocate(bio10,bio11,bio12,bio13,bio14,bio15,bio16,bio17,bio18,bio19, .after = bio9)

    # reorder worldclim data
    worldclim_sitesdata = worldclim_sitesdata
    # sanity check that the site names is the same as locations data
    if (!all.equal(worldclim_sitesdata$site, locations_data$site)) {
        stop('Mismatched sites')
    }
    use_grene_data(worldclim_sitesdata)
    print(date())
    return(invisible())
}

gen_worldclim_sitesdata()

# Rscript --vanilla R/gen_worldclim_sitesdata.R &> logs/gen_worldclim_sitesdata.log







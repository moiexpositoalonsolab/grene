# Title: generate worldclim data by ecotypes_data
# Author: Meixi Lin
# Adapted from Moi's previous script
# Date: Wed Nov 16 13:37:45 2022

gen_worldclim_ecotypesdata <- function() {
    print(date())
    rm(list = ls())
    options(echo = TRUE, stringsAsFactors = FALSE)
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
        out = reshape2::colsplit(oldname, pattern = '_', names = c('ver','res','var', 'sub')) %>%
            dplyr::mutate(sub0 = as.integer(sub)) %>%
            dplyr::arrange(sub0)
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
    load('data/ecotypes_data.rda')

    library(leaflet)
    leaflet(data = ecotypes_data) %>%
        addTiles() %>%
        addCircleMarkers(~longitude, ~latitude)
    # compare previous version
    load('./data/ecotypes.clim.rda')
    old_ecotypes = ecotypes.clim[,c(1,3,2,4,6,8,9)]
    comp_ecotypes_data = ecotypes_data[,c(1,2,3,4,5,7,8)]
    colnames(old_ecotypes) = colnames(comp_ecotypes_data)
    old_ecotypes = old_ecotypes %>% dplyr::arrange(ecotypeid) %>%
        dplyr::mutate(ecotypeid = as.integer(ecotypeid),
                      estimatedseednumber = as.integer(estimatedseednumber))
    comp_ecotypes_data = comp_ecotypes_data %>% dplyr::arrange(ecotypeid)
    diffdf::diffdf(comp_ecotypes_data, old_ecotypes)

    #######################################################################


    longlat = locations_data[,c('longitude','latitude')]
    rownames(longlat) = locations_data$ecotype


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
    worldclim_ecotypesdata = dplyr::bind_cols(wc_dtlist) %>%
        dplyr::mutate(ecotype = as.integer(dimnames(wc_dtlist0[[1]])[[1]])) %>% # append the dimnames for sanity check
        dplyr::relocate(., ecotype)
    # sanity check that the ecotype names is the same as locations data
    if (!all.equal(worldclim_ecotypesdata$ecotype, locations_data$ecotype)) {
        stop('Mismatched ecotypes')
    }
    use_grene_data(worldclim_ecotypesdata)
    print(date())
    return(invisible())
}

# sink(file = './logs/gen_worldclim_ecotypesdata.log')
# gen_worldclim_ecotypesdata()
# sink()

load('data/fastq_info.rda')






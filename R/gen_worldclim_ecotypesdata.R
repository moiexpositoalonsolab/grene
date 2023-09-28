# Title: generate worldclim data by ecotypes_data
# Author: Meixi Lin
# Adapted from Moi's previous script
# Date: Mon Feb 13 15:29:54 2023
# For sanity check with previous worldclim, see data/ARCHIVE/scripts/check_worldclim_ecotypes.R
options(echo = TRUE, stringsAsFactors = FALSE)

gen_worldclim_ecotypesdata <- function() {
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
    load('data/ecotypes_data.rda')
    longlat = ecotypes_data[,c('longitude','latitude')]
    rownames(longlat) = ecotypes_data$ecotypeid

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
        dplyr::mutate(ecotypeid = as.integer(dimnames(wc_dtlist0[[1]])[[1]])) %>% # append the dimnames for sanity check
        dplyr::relocate(., ecotypeid) %>%
        dplyr::relocate(bio10,bio11,bio12,bio13,bio14,bio15,bio16,bio17,bio18,bio19, .after = bio9)

    # sanity check that the ecotypeid is the same as ecotypes_data
    if (!all.equal(worldclim_ecotypesdata$ecotypeid, ecotypes_data$ecotypeid)) {
        stop('Mismatched ecotypes')
    }
    #######################################################################
    # confirm the missing data
    missingecotypes = c(6184,9371,9394,9481)
    ecotypes_m = ecotypes_data %>%
        dplyr::filter(ecotypeid %in% missingecotypes)

    plot(rr, xlim = c(13.8,13.9), ylim = c(55.3,55.5))
    points(ecotypes_m$longitude, ecotypes_m$latitude)


    use_grene_data(worldclim_ecotypesdata)
    print(date())
    return(invisible())
}

gen_worldclim_ecotypesdata()

# Rscript --vanilla R/gen_worldclim_ecotypesdata.R &> logs/gen_worldclim_ecotypesdata.log






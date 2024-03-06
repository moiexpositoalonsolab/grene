## generate GrENE-net participant data
## Author: Moi
## Date: Mar 22 2020
## Adapted by Meixi on Wed Sep 21 19:50:12 2022 for a package

## Take table sitesinfo, remove the sites that haven't been reported or started, rename columns
## Include a field for the sites with no success
## Dump sitesinfo (filtered), sites_not_reported_or_started and sites_with_no_success in /data
# add in information newly confirmed in Oct 2022
gen_locations_data <- function() {
    rm(list = ls())
    options(stringsAsFactors = FALSE)
    source('R/download_altitude.R') # these needs to be removed
    source('R/timezone_lookup.R')
    source('R/use_grene_data.R')
    source('R/country_lookup.R')
    require(dplyr)
    require(stringr)
    #######################################################################
    # define a function for locations data
    date_fixer <- function(DATE) {
        # fix the semicolon separated field
        outDATE = sapply(DATE, function(xx) {
            if (xx == "") {
                yy = NA_character_
            } else {
                yy = format(as.Date(xx, format = '%d.%m.%Y', optional = FALSE), '%Y%m%d')
            }
        })
        outDATE = unname(outDATE)
        return(outDATE)
    }

    outcols = c('site','contactname','experimentstartdate','sitename','longitude',
                'latitude','altitude','timezone','survivalyear', 'country')

    #######################################################################
    # load data
    locations_raw <- read.csv(file = "data-raw/locations_dataraw.csv")
    locations_noreport_nostart <- read.csv(file = "data-raw/locations_dataraw_noreport_nostart.csv")
    locations_nosuccess <- read.csv(file = 'data-raw/locations_dataraw_nosuccess.csv')
    # get info
    print(dim(locations_raw)) # 45 25
    setdiff(locations_noreport_nostart$SITE_CODE, locations_raw$SITE_CODE) # 59 31
    setdiff(locations_nosuccess$SITE_CODE, locations_raw$SITE_CODE) # should be none
    #######################################################################
    # remove the sites that failed to start
    # add a field for number of years survived
    locations_data <- locations_raw %>%
        dplyr::filter(!(SITE_CODE %in% locations_noreport_nostart$SITE_CODE)) %>%
        dplyr::mutate(survivalyear = ifelse(SITE_CODE %in% locations_nosuccess$SITE_CODE, 0, NA))
    print(dim(locations_data)) # 43 26
    table(locations_data$survivalyear, useNA = 'always') # 11 sites not survived ; 32 sites survived
    #######################################################################
    # format for the output locations data
    locations_data <- locations_data %>%
        dplyr::select(SITE_CODE,NAME,STARTED_EXPERIMENT,SITE_NAME,LONGITUDE,
                      LATITUDE,ALTITUDE,TIME_ZONE,survivalyear,COUNTRY)
    # get new colnames
    colnames(locations_data) <- outcols

    #######################################################################
    # Add new info
    # site3
    site3data = data.frame(list(3,'Robert I. Colautti','yes','QUBS (Queen’s University Biological Station)',-76.326395,
                                44.568512,129,'Eastern EST', 1, 'Canada'))
    colnames(site3data) = colnames(locations_data)
    locations_data = rbind(locations_data, site3data)
    # site24
    locations_data[locations_data$site==24,c('longitude','latitude')] = c(12.261756, 47.470432)
    # site28
    # force set the altitude to NA
    locations_data[locations_data$site==28,c('longitude','latitude', 'altitude')] = c(-79.018746, 36.009169, NA_real_)
    #######################################################################
    # format experimentstartdate
    locations_data$experimentstartdate <- date_fixer(locations_data$experimentstartdate)
    #######################################################################
    # format altitude using the raster package
    altitude_new <- sapply(1:nrow(locations_data), function(ii) {
        # print(locations_data[ii,'site'])
        elev <- download_altitude(locations_data[ii,'longitude'],locations_data[ii,'latitude'])
    })
    locations_data$altitude_new <- altitude_new
    locations_data = locations_data %>%
        dplyr::mutate(altitude_out = ifelse(is.na(altitude),altitude_new, altitude)) %>%
        dplyr::mutate(altitude_diff = altitude - altitude_new)
    # check the match between older elevation data and this new one
    locations_data[!is.na(locations_data$altitude),c('site','altitude','altitude_new','altitude_diff')]

    #######################################################################
    # format timezone
    timezone_new <- timezone_lookup(longitude = locations_data$longitude,
                                    latitude = locations_data$latitude)
    locations_data$timezone_new <- timezone_new
    locations_data[locations_data$timezone != "",c('site','timezone','timezone_new')]
    #######################################################################
    # country info
    locations_data$country_new <- country_lookup(locations_data$longitude, locations_data$latitude)
    # View(locations_data[, c('country', 'country_new')])
    locations_data = locations_data %>%
        dplyr::mutate(country_out = ifelse(is.na(country_new), country, country_new))

    #######################################################################
    # output data
    locations_data = locations_data %>%
        dplyr::select(-timezone, -altitude, -altitude_new, -country, country_new) %>%
        dplyr::rename(altitude = altitude_out, timezone = timezone_new, country = country_out) # new_name = old_name
    locations_data = locations_data[,outcols] %>%
        dplyr::arrange(site)
    print(str(locations_data))
    # # check with previous version (see logs/ folder for info)
    # locations_data2 = locations_data
    # load('./data/ARCHIVE/locations_data_20221006.rda')
    # diffdf::diffdf(locations_data, locations_data2)
    use_grene_data(locations_data)
    return(invisible())
}

gen_locations_data()





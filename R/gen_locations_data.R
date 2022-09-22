## generate GrENE-net participant data
## Author: Moi
## Date: Mar 22 2020
## Adapted by Meixi on Wed Sep 21 19:50:12 2022 for a package

## Take table sitesinfo, remove the sites that haven't been reported or started, rename columns
## Include a field for the sites with no success
## Dump sitesinfo (filtered), sites_not_reported_or_started and sites_with_no_success in /data
# install.packages('lutz')
gen_locations_data <- function() {
    options(stringsAsFactors = FALSE)
    require(dplyr)
    #######################################################################
    # define a function for locations data
    date_fixer <- function(DATE) {
        # fix the semicolon separated field
        DATE[which(DATE == 'yes; 15.11.2017')] = '15.11.2017'
        outDATE = sapply(DATE, function(xx) {
            if (xx == "") {
                yy = NA_character_
            } else {
                if (xx == "yes") {
                    yy = "started"
                } else {
                    yy = format(as.Date(xx, format = '%d.%m.%Y', optional = FALSE), '%Y%m%d')
                }
            }
        })
        outDATE = unname(outDATE)
        return(outDATE)
    }
    outcols = c('site','contactname','experimentstartdate','sitename','longitude',
                'latitude','altitude','timezone','survivalyear')
    #######################################################################
    # load data
    locations_raw <- read.csv(file = "data-raw/locations_dataraw.csv")
    locations_noreport_nostart <- read.csv(file = "data-raw/locations_dataraw_noreport_nostart.csv")
    locations_nosuccess <- read.csv(file = 'data-raw/locations_dataraw_nosuccess.csv')
    # get info
    print(dim(locations_raw))
    setdiff(locations_noreport_nostart$SITE_CODE, locations_raw$SITE_CODE) # 59 31
    setdiff(locations_nosuccess$SITE_CODE, locations_raw$SITE_CODE) # 3
    #######################################################################
    # remove the sites that failed to start
    # add a field for number of years survived
    locations_data <- locations_raw %>%
        dplyr::filter(!(SITE_CODE %in% locations_noreport_nostart$SITE_CODE)) %>%
        dplyr::mutate(survivalyear = ifelse(SITE_CODE %in% locations_nosuccess$SITE_CODE, 0, NA))
    #######################################################################
    # format for the output locations data
    locations_data <- locations_data %>%
        dplyr::select(SITE_CODE,NAME,STARTED_EXPERIMENT,SITE_NAME,LONGITUDE,
                      LATITUDE,ALTITUDE,TIME_ZONE,survivalyear)
    # get new colnames
    colnames(locations_data) <- outcols
    #######################################################################
    # format experimentstartdate
    locations_data$experimentstartdate <- date_fixer(locations_data$experimentstartdate)
    #######################################################################
    # format altitude using the raster package
    altitude_new <- sapply(1:nrow(locations_data), function(ii) {
        elev <- download_altitude(locations_data[ii,'longitude'],locations_data[ii,'latitude'])
    })
    # cleanup raw data altitude that was provided
    altitude_clean <- c("52","329","709","164","1600","1900","1400","450",
                        "477","381","198","20","60","651","68","118",
                        "90","37","750","10","0","2100")
    locations_data[locations_data$altitude != "", 'altitude'] <- altitude_clean
    locations_data$altitude_new <- altitude_new
    locations_data = locations_data %>%
        dplyr::mutate(altitude = ifelse(altitude == "", NA_integer_, as.integer(altitude))) %>%
        dplyr::mutate(altitude_out = ifelse(is.na(altitude),altitude_new, altitude))
    # check the match between older elevation data and this new one
    locations_data[!is.na(locations_data$altitude),c('site','altitude','altitude_new','altitude_out')]
    #######################################################################
    # format timezone
    timezone_new <- timezone_lookup(latitude = locations_data$latitude,
                                    longitude = locations_data$longitude)
    locations_data$timezone_new <- timezone_new
    locations_data[locations_data$timezone != "",c('site','timezone','timezone_new')]
    # output data
    locations_data = locations_data %>%
        dplyr::select(-timezone, -altitude, -altitude_new) %>%
        dplyr::rename(altitude = altitude_out, timezone = timezone_new) # new_name = old_name
    locations_data = locations_data[,outcols]
    print(str(locations_data))
    use_grene_data(locations_data)
    return(invisible())
}


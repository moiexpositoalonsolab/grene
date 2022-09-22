timezone_lookup <- function(latitude, longitude) {
    require(lutz)
    require(dplyr)
    tzdt = lutz::tz_list()
    tzs = lutz::tz_lookup_coords(lat = latitude, lon = longitude, method = 'accurate')
    # not use the daylight savings time for all
    tzout = data.frame(tz_name = tzs) %>%
        dplyr::left_join(., y = tzdt[tzdt$is_dst == FALSE,c('tz_name', 'utc_offset_h')], by = 'tz_name') %>%
        dplyr::mutate(output = ifelse(utc_offset_h >=0 ,
                                      paste0('(UTC+', sprintf("%02d", utc_offset_h), ':00) ', tz_name),
                                      paste0('(UTC-', sprintf("%02d", abs(utc_offset_h)), ':00) ', tz_name))
                      )
    # check dimension
    if (length(tzout$output) != length(latitude)) {
        stop('timezone duplicated')
    } else {
        return(tzout$output)
    }
}

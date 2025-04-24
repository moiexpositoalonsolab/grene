# Title: Load and reformat GSOD csv file list
# Author: Meixi Lin
# Date: Sun Nov 20 16:45:56 2022
# Adapted from GSODR::reformat_GSOD() function
# Cannot use that because of unexpected NAs https://github.com/ropensci/GSODR/issues/109

.read_gsod_csv <- function(x) {
    require(data.table)
    # Import data from the website for individual stations or tempdir() for all --
    DT <-
        fread(x,
              colClasses = c("STATION" = "character"),
              strip.white = TRUE)

    # Replace 99.99 et al. with NA
    set(DT, j = "PRCP", value = as.character(DT[["PRCP"]]))
    set(DT,
        i = which(DT[["PRCP"]] == "99.99"),
        j = "PRCP",
        value = NA)

    # Replace 999.9 with NA
    for (col in names(DT)[names(DT) %in% c("VISIB",
                                           "WDSP",
                                           "MXSPD",
                                           "GUST",
                                           "SNDP",
                                           "STP")]) {
        set(DT, j = col, value = as.character(DT[[col]]))
        set(DT,
            i = which(DT[[col]] == "999.9"),
            j = col,
            value = NA)
    }

    # Replace 9999.99 with NA
    for (col in names(DT)[names(DT) %in% c("TEMP",
                                           "DEWP",
                                           "SLP",
                                           "MAX",
                                           "MIN")]) {
        set(DT, j = col, value = as.character(DT[[col]]))
        set(DT,
            i = which(DT[[col]] == "9999.9"),
            j = col,
            value = NA)
    }

    # Replace " " with NA
    for (col in names(DT)[names(DT) %in% c("PRCP_ATTRIBUTES",
                                           "MIN_ATTRIBUTES",
                                           "MAX_ATTRIBUTES")]) {
        set(DT,
            i = which(DT[[col]] == " "),
            j = col,
            value = NA)
    }

    # MY OWN ADDITION: Replace PRCP == 0 and PRCP_ATTRIBUTES == I with NA
    set(DT,
        i = which(DT[["PRCP"]] == " 0.00" & DT[["PRCP_ATTRIBUTES"]] == "I"),
        j = "PRCP",
        value = NA)

    # Convert date related columns ---------------------------------------
    DT[, DATE := as.Date(DATE, format = "%Y-%m-%d")]

    # Convert *_ATTRIBUTES cols to integer ---------------------------------------
    for (col in names(DT)[names(DT) %in% c("TEMP_ATTRIBUTES",
                                           "DEWP_ATTRIBUTES",
                                           "SLP_ATTRIBUTES",
                                           "STP_ATTRIBUTES",
                                           "VISIB_ATTRIBUTES",
                                           "WDSP_ATTRIBUTES")]) {
        set(DT, j = col, value = as.integer(DT[[col]]))
    }

    # Convert numeric cols to be numeric -----------------------------------------
    for (col in c(
        "TEMP",
        "DEWP",
        "SLP",
        "STP",
        "WDSP",
        "MXSPD",
        "GUST",
        "VISIB",
        "WDSP",
        "MAX",
        "MIN",
        "PRCP",
        "SNDP"
    )) {
        set(DT, j = col, value = as.numeric(DT[[col]]))
    }

    # Convert data to Metric units -----------------------------------------------
    DT[, TEMP := round(0.5556 * (TEMP - 32), 1)]
    DT[, DEWP := round(0.5556 * (DEWP - 32), 1)]
    DT[, WDSP := round(WDSP * 0.514444444, 1)]
    DT[, MXSPD := round(MXSPD * 0.514444444, 1)]
    DT[, GUST := round(GUST * 0.514444444, 1)]
    DT[, VISIB := round(VISIB * 1.60934, 1)]
    DT[, MAX := round((MAX - 32) * 0.5556, 1)]
    DT[, MIN := round((MIN - 32) * 0.5556, 1)]
    DT[, PRCP := round(PRCP * 25.4, 2)]
    DT[, SNDP := round(SNDP * 25.4, 1)]

    # MY OWN ADDITION: Remove attribute fields ---------------------------------------
    DT[, grep("_ATTRIBUTES$", colnames(DT)):=NULL]

    # Convert colnames to lower
    colnames(DT) = tolower(colnames(DT))
    # Convert some column names
    setnames(DT, 'station', 'stationid')
    setnames(DT, 'date', 'weatherdate')
    setnames(DT, 'latitude', 'station_latitude')
    setnames(DT, 'longitude', 'station_longitude')
    setnames(DT, 'elevation', 'station_altitude')
    setnames(DT, 'name', 'station_name')
    return(DT)
}

load_gsod_csv <- function(file_list) {
    x <- lapply(X = file_list,
                FUN = .read_gsod_csv)
    out <- data.table::rbindlist(x)
    setDF(out)
    return(out)
}



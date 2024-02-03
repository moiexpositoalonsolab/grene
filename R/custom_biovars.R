# Adapted from https://rdrr.io/cran/dismo/src/R/biovars.R
# Add input for mean temperature. Original biovars only used tmin, tmax and prcp.
# Add tolerance for no precipitation data.
# Only tested on one row and no missing data

custom_biovars <- function(df) {
    require(raster)
    p <- matrix(nrow=1, ncol=19)
    prec = t(as.matrix(df$prcp))
    tavg = t(as.matrix(df$temp))
    tmin = t(as.matrix(df$mint))
    tmax = t(as.matrix(df$maxt))
    # 1. there is no NA 2. there is all NA, both pass missingness filter
    missingpass <- sapply(list(prec,tavg,tmin,tmax), function(xx) {
        !(any(is.na(xx)) & !all(is.na(xx))) | (all(is.na(xx)))
    })
    if (any(!missingpass) | ncol(prec) != 12 | ncol(tavg) != 12 | ncol(tmin) != 12 | ncol(tmax) != 12) {
        print(as.data.frame(df))
        warning('Uncomplete 12 months data')
    }
    # P1. Annual Mean Temperature
    p[,1] <- apply(tavg,1,mean)
    # P2. Mean Diurnal Range(Mean(period max-min))
    p[,2] <- apply(tmax-tmin, 1, mean)
    # P4. Temperature Seasonality (standard deviation)
    p[,4] <- 100 * apply(tavg, 1, sd)
    # P5. Max Temperature of Warmest Period
    p[,5] <- apply(tmax,1, max)
    # P6. Min Temperature of Coldest Period
    p[,6] <- apply(tmin, 1, min)
    # P7. Temperature Annual Range (P5-P6)
    p[,7] <- p[,5] - p[,6]
    # P3. Isothermality (P2 / P7)
    p[,3] <- 100 * p[,2] / p[,7]
    # P12. Annual Precipitation
    p[,12] <- apply(prec, 1, sum)
    # P13. Precipitation of Wettest Period
    p[,13] <-  apply(prec, 1, max)
    # P14. Precipitation of Driest Period
    p[,14] <-  apply(prec, 1, min)
    # P15. Precipitation Seasonality(Coefficient of Variation)
    # the "1 +" is to avoid strange CVs for areas where mean rainfaill is < 1)
    p[,15] <- apply(prec+1, 1, raster::cv)

    # precip by quarter (3 months) (windowed months overlapping)
    window <- function(x)  {
        lng <- length(x)
        x <- c(x,  x[1:3])
        m <- matrix(ncol=3, nrow=lng)
        # 12 rows by 3 cols. first col is 1-12, second col is 2-12,1, third col is 3-12,1,2
        for (i in 1:3) { m[,i] <- x[i:(lng+i-1)] }
        apply(m, MARGIN=1, FUN=sum)
    }
    wet <- t(apply(prec, 1, window))
    # P16. Precipitation of Wettest Quarter
    p[,16] <- apply(wet, 1, max)
    # P17. Precipitation of Driest Quarter
    p[,17] <- apply(wet, 1, min)
    # average temperature of the 3 months (not summed up)
    tmp <- t(apply(tavg, 1, window)) / 3

    if (all(is.na(wet))) {
        p[,8] <- NA
        p[,9] <- NA
    } else {
        # P8. Mean Temperature of Wettest Quarter
        # 1:nrow(p): process each site separatedly
        wetqrt <- cbind(1:nrow(p), as.integer(apply(wet, 1, which.max)))
        p[,8] <- tmp[wetqrt] # access the values
        # P9. Mean Temperature of Driest Quarter
        dryqrt <- cbind(1:nrow(p), as.integer(apply(wet, 1, which.min)))
        p[,9] <- tmp[dryqrt]
    }
    # P10 Mean Temperature of Warmest Quarter
    p[,10] <- apply(tmp, 1, max)

    # P11 Mean Temperature of Coldest Quarter
    p[,11] <- apply(tmp, 1, min)

    if (all(is.na(tmp)) | all(is.na(wet))) {
        p[,18] <- NA
        p[,19] <- NA
    } else {
        # P18. Precipitation of Warmest Quarter
        hot <- cbind(1:nrow(p), as.integer(apply(tmp, 1, which.max)))
        p[,18] <- wet[hot]
        # P19. Precipitation of Coldest Quarter
        cold <- cbind(1:nrow(p), as.integer(apply(tmp, 1, which.min)))
        p[,19] <- wet[cold]
    }

    # convert all the NaN to NA
    p[is.nan(p)] = NA
    return(p)
}




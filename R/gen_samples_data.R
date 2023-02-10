# Title: generate samples_data for grenephase1
# Author: Tati Bellagio; Meixi Lin
# Adapted from Moi's previous data
# Date: Wed Nov 16 22:54:49 2022

gen_samples_data <- function() {
    rm(list = ls())
    options(stringsAsFactors = FALSE)
    source('R/use_grene_data.R') # these needs to be removed
    require(dplyr)
    require(stringr)
    #######################################################################
    # define functions
    update_sampleid <- function(df, oldid, newid) {
        for (ii in 1:nrow(df)) {
            if(is.na(df[ii, 'sampleid'])) {
                next
            } else {
                if (df[ii, 'sampleid'] == oldid) {
                    df[ii, 'sampleid'] = newid
                    df[ii, 'sampleid_alternative'] = oldid
                }
            }
        }
        return(df)
    }
    #######################################################################
    # define columns
    outcols = c('sampleid', 'code', 'site', 'plot', 'date', 'year', 'flowerscollected',
                'isreplicate', 'isfailedlabwork', 'isdispersion','sampleid_alternative')
    # sites with 18 plots
    dispersion_siteplots = paste0('MLFH',c('0213','0214','0215','0216','0217','0218',
                             '2801', '2805','2809','2810','2814','2818',
                             '5702','5705','5708','5711','5714','5717'))
    #######################################################################
    # load data-raw
    # last modified Sep 20, 2022
    samples_datar = read.csv(file = './data-raw/samples_sorted.csv')
    dim(samples_datar) # [1] 2415    8
    samples_data = samples_datar %>%
        dplyr::mutate(TO_SKIP = ifelse(TO_SKIP == 'True', TRUE, FALSE),
                      REPLICATES = ifelse(REPLICATES == 'True', TRUE, FALSE),
                      DATE= as.character(DATE),
                      year = str_sub(DATE, end = 4),
                      sampleid = paste0('ML',CODES,
                                        str_pad(SITE, width = 2, side = 'left', pad = '0'),
                                        str_pad(PLOT, width = 2, side = 'left', pad = '0'),
                                        DATE),
                      sampleid_alternative = NA_character_,
                      isdispersion = str_detect(sampleid, paste(dispersion_siteplots,collapse = '|'))) %>%
        dplyr::rename(code = CODES, site = SITE, plot = PLOT, date = DATE,
                      flowerscollected = NUMBER_FLOWERS_COLLECTED,
                      isreplicate = REPLICATES, isfailedlabwork = TO_SKIP)
    # select only the data wanted
    samples_data = samples_data[,outcols]

    #######################################################################
    # Add A/B notations for the replicates
    replicate_data0 = samples_data %>%
        dplyr::filter(isreplicate == TRUE) %>%
        dplyr::mutate(sampleid_alternative = sampleid)
    replicate_data = rbind(replicate_data0, replicate_data0)
    replicate_data$sampleid = paste0(replicate_data$sampleid_alternative, rep(c('A', 'B'), each = 3))

    #######################################################################
    # Add annotations for the samples with alternative id
    insample_notfastq = c("MLFH010720200323","MLFH240320180521","MLFH240420180521",
                          "MLFH430320180328","MLFH570320190821","MLFH580420190607")
    fastq_sampleid = c("MLFH010720200329","MLFH240320180527","MLFH240420180527",
                       NA, NA, NA)
    for (ii in 1:length(insample_notfastq)) {
        samples_data = update_sampleid(samples_data, insample_notfastq[ii], fastq_sampleid[ii])
    }

    #######################################################################
    # Add notes for the dispersal study sites
    # table(samples_data[samples_data$site == 57,'plot'])

    #######################################################################
    # Merge the replicate data
    samples_data = samples_data %>%
        dplyr::filter(isreplicate == FALSE)
    samples_data = rbind(samples_data, replicate_data) %>%
        dplyr::arrange(sampleid, sampleid_alternative)

    #######################################################################
    # Add a column for sampleid selection
    samples_data = samples_data %>%
        dplyr::mutate(usesample = case_when(isdispersion ~ FALSE,
                                            isfailedlabwork ~ FALSE,
                                            isreplicate & str_ends(sampleid,'B') ~ FALSE,
                                            is.na(sampleid) ~ FALSE,
                                            TRUE ~ TRUE))
    table(samples_data[,c('usesample')])
    # 80 = 63 (isdispersion) + 3(isreplicate/2) + 13(isfailedlabwork) + 1 (is.na(sampleid))
    # FALSE  TRUE
    # 80  2338
    #######################################################################
    # Output data
    dim(samples_data) # [1] 2418    12
    use_grene_data(samples_data)
    return(invisible())
}

gen_samples_data()

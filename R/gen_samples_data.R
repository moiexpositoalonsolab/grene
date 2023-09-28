# Title: generate samples_data for grenephase1
# Author: Tati Bellagio; Meixi Lin
# Adapted from Moi's previous data
# Date: Wed Nov 16 22:54:49 2022
# Modification: Updated to include coverage and some other fixes
# Date: Fri Feb 10 16:26:54 2023
# Modification: Update to force site 57 have 3 generations
# Date: Fri Jun  2 16:53:22 2023


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

    calc_weighted_coverage <- function(samples_data) {
        df = samples_data %>%
            dplyr::filter(usesample) %>%
            dplyr::mutate(spg = paste(site,plot,generation_merge57))
        dfl = base::split(df, df$spg)
        wc = lapply(dfl, function(xx) {
            xx$weighted_mean_coverage = stats::weighted.mean(xx$coverage, xx$flowerscollected)
            return(xx)
        })
        wc = dplyr::bind_rows(wc)[,c('sampleid', 'weighted_mean_coverage')]
        outdf = dplyr::left_join(samples_data, wc, by = 'sampleid')
        return(outdf)
    }

    #######################################################################
    # define columns
    outcols = c('sampleid', 'code', 'site', 'plot', 'date', 'year', 'month', 'day', 'flowerscollected',
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
        dplyr::mutate(TO_SKIP = TO_SKIP == 'True',
                      REPLICATES = REPLICATES == 'True',
                      DATE= as.character(DATE),
                      year = as.integer(str_sub(DATE, end = 4)),
                      month = as.integer(str_sub(DATE, start = 5, end = 6)),
                      day = as.integer(str_sub(DATE, start = 7, end = 8)),
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
    # load the mapped reads
    mreads = read.table(file = './data-raw/mapped_reads.txt')
    mreadsid = read.table(file = './data-raw/sample_ids.txt')
    mreadsdt = cbind(mreadsid,mreads)
    colnames(mreadsdt) = c('sampleid', 'mapped_reads')
    mreadsdt = mreadsdt %>%
        dplyr::mutate(coverage = mapped_reads/1e+6)

    #######################################################################
    # Add A/B notations for the replicates
    replicate_data0 = samples_data %>%
        dplyr::filter(isreplicate == TRUE) %>%
        dplyr::mutate(sampleid_alternative = sampleid) %>%
        dplyr::arrange(sampleid)
    replicate_data = rbind(replicate_data0, replicate_data0)
    replicate_data$sampleid = paste0(replicate_data$sampleid_alternative, rep(c('A', 'B'), each = 3))

    # the replicate data's flower numbers were incorrect
    repnames = c("MLFH230520180609A","MLFH320320190214A","MLFH490620181101A",
                 "MLFH230520180609B","MLFH320320190214B","MLFH490620181101B")
    repnflowers = c(50, 23, 7,
                    44, 34, 6)
    if (all(replicate_data$sampleid == repnames)) {
        replicate_data$flowerscollected = repnflowers
    } else {
        stop('Wrong replicate names')
    }

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
    # Merge the replicate data
    samples_data = samples_data %>%
        dplyr::filter(isreplicate == FALSE)
    samples_data = rbind(samples_data, replicate_data) %>%
        dplyr::arrange(sampleid, sampleid_alternative)

    #######################################################################
    # Add annotations for generations
    # All the experiments started in 2017, so the generation, unless otherwise noted, should be year - 2017
    # site 58 did not collect samples in year 2018 but according to the diary, there were flowering
    # site 13, 25, 27, 28, 49, 57 had samples collected from September to December.
    # After checking the diary, Oct is a good cutoff for late flowering vs new generation
    samples_data = samples_data %>%
        dplyr::mutate(generation = ifelse(month >= 10, year - 2017 + 1, year - 2017))
    # for site 57, different generation was reported
    # Fri Jun  2 17:28:30 PDT 2023: but this generation setup was not used, so adding another one that merges things
    site57 = samples_data[samples_data$site == 57, ]
    # this covers all the generations
    site57 = site57 %>%
        dplyr::mutate(generation = case_when(
            year == 2018 & month >= 3 & month <= 6 ~ 1,
            year == 2018 & month >= 9 & month <= 12 ~ 2,
            year == 2019 & month >= 1 & month <= 6 ~ 3,
            year == 2019 & month >= 7 & month <= 11 ~ 4,
            year == 2020 & month >= 2 & month <= 5 ~ 5,
            year == 2020 & month >= 7 & month <= 12 ~ 6,
            TRUE ~ -1
        ))
    samples_data[samples_data$site == 57, 'generation'] = site57$generation

    # add anther generation scheme
    samples_data = samples_data %>%
        dplyr::mutate(generation_merge57 = generation,
                      generation_merge57 = ifelse(site == 57, ceiling(generation_merge57/2), generation_merge57))

    #######################################################################
    # Merge the read coverage
    samples_data = dplyr::full_join(samples_data, mreadsdt, by = 'sampleid')

    #######################################################################
    # Add a column for sampleid selection
    samples_data = samples_data %>%
        dplyr::mutate(usesample = case_when(isdispersion ~ FALSE,
                                            isfailedlabwork ~ FALSE,
                                            isreplicate & str_ends(sampleid,'B') ~ FALSE,
                                            is.na(sampleid) ~ FALSE,
                                            year > 2020 ~ FALSE,
                                            coverage < 1 ~ FALSE,
                                            TRUE ~ TRUE))
    table(samples_data[,c('usesample')])
    # 249 = 63 (isdispersion) + 3(isreplicate/2) + 13(isfailedlabwork) + 3 (is.na(sampleid)) + 1 (year > 2020) + 194 (coverage < 1)
    #       - overlapping stuff
    # FALSE  TRUE
    # 249  2169

    #######################################################################
    # Calculate weighted coverage (by flowers)
    samples_data = calc_weighted_coverage(samples_data)

    #######################################################################
    # compare with another meta_data
    # the samples_data now matched the /Carnegie/DPB/Data/Shared/Labs/Moi/Everyone/ath_evo/grenephase1-data/meta_table/merged_sample_table.csv
    # see gen_merged_samples_data for details

    # compare with older data that the mergingworked
    # samples_data_new = samples_data
    # load('./data/ARCHIVE/data-versions/samples_data_20230210.rda')
    # mydiffrows = diffdf(samples_data_new, samples_data)$VarDiff_weighted_mean_coverage$..ROWNUMBER..
    # View(cbind(samples_data_new[mydiffrows,c('site', 'plot', 'generation', 'date','generation_merge57')],
    #            samples_data[mydiffrows,c('site', 'plot', 'generation')]))

    #######################################################################
    # Output data
    colnames(samples_data) # [1] 2418    19
    # # keep only the old tables for test
    # samples_data = samples_data %>%
    #     dplyr::select(-month, -day, -generation, -mapped_reads, -coverage, -weighted_mean_coverage) %>%
    #     dplyr::mutate(year = as.character(year))
    use_grene_data(samples_data)
    return(invisible())
}

gen_samples_data()

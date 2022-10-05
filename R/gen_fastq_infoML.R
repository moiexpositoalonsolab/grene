# Create a master table from all the GrENE net releases in SRA
# author Moi+Tati+Meixi
# date Thu Sep 22 15:18:55 2022

gen_fastq_info <- function() {
    options(stringsAsFactors = FALSE)
    require(dplyr)
    source('./R/use_grene_data.R')
    #######################################################################
    # define functions
    # fix sampleid
    fix_sampleid <- function(x) {
        y = strsplit(x,'_')[[1]]
        out = ifelse(length(y) == 1, y,
                     ifelse(length(y) == 3,paste0(y[1], sprintf("%02d", as.integer(y[2])), y[3]),
                            ifelse(length(y) == 4, paste0(y[1], sprintf("%02d", as.integer(y[2])), sprintf("%02d", as.integer(y[3])), y[4]),
                                   NA_character_)))
        return(out)
    }
    fix_sampleid <- base::Vectorize(fix_sampleid)
    # srafolder == fullpath
    outcols = c('r1filename','r2filename','sampleid','r1srafolder','r2srafolder','unit','platform','datereleased')

    #######################################################################
    # Find releases
    ########
    ## Because the seq company was changed, there are two types of files:
    ## - From release 01-08: release folders will have a folder inside (raw_data) where the files are named
    ## with the sample_id provided by us
    ## - From release 09-on: release folder will have folders with the files names with codes assigned by
    ## the company and a key folder that will relate their keys with our sample_ids
    ## - release 10 need to be skipped. Not for main grene-net analyses
    ########
    releases<- list.files("/Carnegie/DPB/Data/Shared/Labs/Moi/Everyone/SRA/grenenet-phase1", pattern = "ath-release",full.names = T)
    releases

    #######################################################################
    # Releases 01 to 08
    first_releases = releases[1:8]

    # Find fastq files under each release
    fastqfiles_firstreleases <- lapply(first_releases, function(x) {
        tmp <- list.files(x, pattern = ".fq.gz",recursive = T,full.names = T)
        # This is our golden code of libraries produced in grene net by Moi Lab ML
        out <- tmp[grepl('MLFH', tmp)]
        # # print the removed files
        # print(paste0('Release ',x, 'Fastq files not considered'))
        # print(setdiff(tmp,out))
        return(out)
    })
    lapply(fastqfiles_firstreleases, length)
    fastqfiles_firstreleases <- unlist(fastqfiles_firstreleases)

    # form a data frame
    filesdt1 <- sapply(fastqfiles_firstreleases, function(x) strsplit(x,split = "/",fixed = T)[[1]][c(11,13,14)]) %>%
        t() %>%
        as.data.frame(stringsAsFactors = FALSE) %>%
        tibble::rownames_to_column(var = 'fullpath')
    colnames(filesdt1) = c('fullpath','datereleased', 'sampleid', 'filename')
    filesdt1 = filesdt1 %>%
        dplyr::mutate(fileprefix = substring(filename,1, nchar(filename)-8)) %>%
        dplyr::mutate(direction = ifelse(grepl('_1.fq.gz',filename), 'R1','R2'))
    length(unique(filesdt1$sampleid)) # 1502

    #######################################################################
    # Releases 09 and 11
    #####
    # MLFH570120190821 had two sequences: 21093FL-02-02-03 and 21093FL-02-02-08
    # There is one file called "21093FL-02-04-32_S320_L004_R1_001_broken.fastq.gz"
    # all other files were correctly formatted
    #####
    second_releases = releases[c(9,10)]
    second_releases

    ## find the keys
    key_files = list.files(second_releases, pattern = "*Key.csv",recursive = T,full.names = T)
    ## read the keys and make one dataframe of them
    keys <- lapply(key_files, function(x) {
        y = read.csv(x)
        colnames(y) = c('seqid','sampleid')
        return(y)
    })
    keys <- dplyr::bind_rows(keys) # 914 rows
    keys$sampleid[duplicated(keys$sampleid)] # MLFH570120190821

    ## find the fastqfiles
    fastqfiles_secondreleases <-lapply(second_releases, function(x) {
        tmp <- list.files(x, pattern = ".fastq.gz",recursive = TRUE,full.names = TRUE)
    })
    fastqfiles_secondreleases <- unlist(fastqfiles_secondreleases)

    # form a data frame
    filesdt2 <- sapply(fastqfiles_secondreleases, function(x) strsplit(x,split = "/",fixed = T)[[1]][c(11,13)]) %>%
        t() %>%
        as.data.frame(stringsAsFactors = FALSE) %>%
        tibble::rownames_to_column(var = 'fullpath')
    colnames(filesdt2) = c('fullpath','datereleased', 'filename')
    filesdt2$seqid = unname(sapply(filesdt2$filename, function(x) strsplit(x, '_')[[1]][1]))
    filesdt2 <- filesdt2 %>%
        dplyr::left_join(., y = keys, by = 'seqid') %>%
        dplyr::select(fullpath, datereleased, filename, sampleid)
    length(unique(filesdt2$sampleid)) # 913
    filesdt2 = filesdt2 %>%
        dplyr::mutate(fileprefix = substring(filename,1, nchar(filename)-16)) %>%
        dplyr::mutate(direction = ifelse(grepl('_R1_001.fastq.gz',filename), 'R1','R2'))

    #######################################################################
    # Format sampleid
    filesdt <- dplyr::bind_rows(filesdt1,filesdt2) %>%
        dplyr::mutate(sampleid = fix_sampleid(sampleid)) %>%
        dplyr::arrange(sampleid, datereleased)
    length(unique(filesdt$sampleid))
    # 2415 = 913 + 1502 (no duplicates cross comparing releases 01-08 vs 09,11)

    #######################################################################
    # Cleanup duplicated releases and bad files
    ########
    ## For release-02 and 05, 376 exact-same fastq (md5sum identical) in release-02 were duplicated in release-05
    ## Remove duplicated fastq files in release-05 to avoid duplicated processing
    ########
    duplicated_release05 <- filesdt$fullpath[filesdt$filename %in% filesdt$filename[duplicated(filesdt$filename)]]
    duplicated_release05 <- duplicated_release05[grepl('release-05', duplicated_release05)]

    # remove the duplicated_release05 files
    filesdt_dedup <- filesdt %>%
        dplyr::filter(!(fullpath %in% duplicated_release05)) %>%
        dplyr::filter(filename != '21093FL-02-04-32_S320_L004_R1_001_broken.fastq.gz') # 5400

    #######################################################################
    # Format for the output fastq_info data
    fastq_info_base = filesdt_dedup[,c('fileprefix','datereleased','sampleid')] %>%
        dplyr::distinct()
    fastq_info <- data.table::dcast.data.table(data = data.table::setDT(filesdt_dedup),
                                               formula = fileprefix ~ direction,
                                               value.var = c('filename', 'fullpath')) %>%
        as.data.frame() %>%
        dplyr::left_join(., y = fastq_info_base, by = 'fileprefix') %>%
        dplyr::arrange(sampleid, datereleased)

    # generate unit for grenepipe input (for each )
    fastq_info_split <- base::split(fastq_info, fastq_info$sampleid)
    fastq_info_unit <- unlist(lapply(fastq_info_split, function(xx) {
        yy = seq(1,nrow(xx))
    }))
    fastq_info$unit = fastq_info_unit
    table(fastq_info$unit,useNA = 'always')
    # 285 samples were sequenced twice, no sample sequenced three times
    fastq_info$platform = 'ILLUMINA'

    # clean up with output
    fastq_info = fastq_info[,c('filename_R1','filename_R2','sampleid','fullpath_R1','fullpath_R2','unit','platform','datereleased')]
    colnames(fastq_info) = outcols

    #######################################################################
    # Output files
    use_grene_data(fastq_info)
    # output one file that conforms to grenepipe data format
    fastq_grenepipe = fastq_info[,c('sampleid','unit','platform','r1srafolder','r2srafolder')]
    colnames(fastq_grenepipe) = c('sample','unit','platform','fq1','fq2')

    write.table(fastq_grenepipe, file = './data/fastq_grenepipe.tsv', quote = FALSE, sep = '\t', row.names = FALSE)

    return(invisible())
}

gen_fastq_info()




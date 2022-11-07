load('./data/fastq_info.rda')

# the fastqs by sites
require(dplyr)
samples = unique(fastq_info$sampleid)

sampledt = data.frame(title = substr(samples,1,4),
                      site = substr(samples,5,6),
                      plot = substr(samples,7,8),
                      time = as.integer(substr(samples,9,16)))

lastday = sampledt %>%
    dplyr::group_by(site) %>%
    dplyr::summarize(last_date = max(time)) %>%
    dplyr::mutate(last_date = as.Date(as.character(last_date), format = '%Y%m%d'))

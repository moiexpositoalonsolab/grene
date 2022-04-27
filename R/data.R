#no need to document or if we are doing it we should put source
#Arabidopsis_thaliana_world_accessions_list
#ecotypes
#ecotypes.clim

# esto es nuestro o de internet?
#sites.clim

#not dataframes
#README_data
#alleles.clim

#models
# mod9965
# modbur
# modcol

#genetic data
# seqtable


#' Records is a dataset
#'
#'This dataset consists in all the recorded samples
#'
#' @format A data frame
#' \describe{
#'   \item{CODES}{These codes can take the values "FH"(Flower head)"Albugo"(common pathogen)"SB"(seedbank)"SOIL"(soil sample before experiment)"Ac"
#'   and indicates the type of sample}
#'   \item{SITE}{Indicates number of site. Each site has a unique number from 1 on}
#'   \item{PLOT}{Number of plot in each site. From 1-12. Some instances beyond 12 exist when parallel experiments were conducted}
#'   \item{DATE}{The date when the sample was coelected}
#'   \item{SAMPLE_ID}{Unique value given by the code-site-plot-date}
#'   \item{COMMENTS2}{Comments from the collectors}
#'   \item{COMMENTS3}{Comments from the collectors}
#'   \item{D}{Date in R-readable format}
#'   \item{RECODE}{Code of the field site and sample in a more compatible format with other spreadsheets}
#' }
#' @source \url{https://grenenet.wordpress.com/}
"records"


#' Census is a dataset
#'
#'This dataset consists in the census recorded samples
#'
#' @format A data frame
#' \describe{
#'   \item{SITE}{Indicates number of site. Each site has a unique number from 1 on}
#'   \item{PLOT}{Number of plot in each site. From 1-12}
#'   \item{DATE}{The date when the census was conducted}
#'   \item{RECORD_ID}{Equivalent to sample ID based on code-site-plot-date, to match with other datasets}
#'   \item{DIAGONAL_PLANT_NUMBER}{number of plants counted following the diagonal transect method in each plot}
#'   \item{OFF.DIAGONAL_PLANT_NUMBER}{number of plants counted following a central horizontal transect parallel to the long side of the each plot}
#'   \item{TOTAL_PLANT_NUMBER..OPTIONAL.}{total number of plants counted in the plot}
#'   \item{MEAN_FRUITS_PER_PLANT..OPTIONAL.}{mean number of fruits per plant}
#'   \item{SD_FRUITS_PER_PLANT..OPTIONAL.}{Standard deviation of fruit per plant}
#'   \item{COMMENTS}{Collector comments}
#'   \item{COMMENTS2}{Collector comments}
#'   \item{D}{Date in R-readable format}
#' }
#' @source \url{https://grenenet.wordpress.com/}
"census"

#' recordssorted is a dataset
#'
#'This dataset consists in the census recorded samples
#'
#' @format A data frame
#' \describe{
#'   \item{CODES}{These codes can take the values "FH"(Flower head)"Albugo"(common pathogen)"SB"(seedbank)"SOIL"(soil sample before experiment)"Ac"
#'   and indicates the type of sample}
#'   \item{SITE}{Indicates number of site. Each site has a unique number from 1 on}
#'   \item{PLOT}{Number of plot in each site. From 1-12}
#'   \item{DATE}{The date when the sample was coelected?}
#'   \item{SAMPLE_ID}{Unique value given by the code-site-plot-date}
#'   \item{NUMBER_FLOWERS_COLLECTED}{Number of flowers collected in the pot}
#'   \item{Notes.by.Ru}{}
#'   \item{D}{Date in date format}
#'   \item{RECODE}{?}
#'   \item{id}{Identifier code built from code-site-plot-date columns}
#'   \item{year}{}
#'   \item{startyear}{}
#'   \item{doy}{Day of the year. Example: 01/01 is 1 01/02 is 2}
#' }
#' @source \url{https://grenenet.wordpress.com/}
"recordssorted"

#' sites_not_reported_or_started is a dataset
#'
#'This dataset consists in the name and site code number of experiments that needs to be excluded from the analyses because participants never started the experiments
#'
#' @format A data frame
#' \describe{
#'   \item{,1}{Responsable name}
#'   \item{,2}{Site code number}
#' }
#' @source \url{https://grenenet.wordpress.com/}
"sites_not_reported_or_started"


#' sites_with_no_success is a dataset
#'
#'This dataset consists in the name and site code number of experiments that were started but where plants did not establish and reproduce.
#'
#' @format A data frame
#' \describe{
#'   \item{,1}{Responsable name}
#'   \item{,2}{Site code number}
#' }
#' @source \url{https://grenenet.wordpress.com/}
"sites_with_no_success"


#' sitesinfo is a dataset
#'
#'This dataset consists in per site contact details of participants, locations of sites, and other logistical information
#'
#' @format A data frame
#' \describe{
#'   \item{NAME}{}
#'   \item{SITE_CODE}{In the other df is just code right? }
#'   \item{DIARY}{link to a diary where collectors could put comments?}
#'   \item{EMAIL}{Contact information lead participant}
#'   \item{EMAIL_2}{Contact information of support people to lead participant}
#'   \item{COLLABORATOR}{Contact information of participants on site}
#'   \item{SHIPMENT_ADDRESS}{}
#'   \item{PACKAGE_SENT.}{Possible answers are: yes, seeds and loggers?}
#'   \item{PACKAGE_RECEIVED}{Yes or na}
#'   \item{STARTED_EXPERIMENT}{Date when the experiment was started}
#'   \item{X2018_SAMPLES}{Whether participants sent samples in 2018 (to be removed in the next version, as this should be in other spreadsheets, or expand to cover other years)}
#'   \item{SITE_NAME}{Site name given by particpiants}
#'   \item{LONGITUDE}{Degrees East}
#'   \item{LATITUDE}{Degrees North}
#'   \item{ALTITUDE}{Meters above sea level}
#'   \item{TIME_ZONE}{}
#'   \item{EXPECTED_SOWING}{Date of expected sowing}
#'   \item{ACCESS_SOIL}{Whether the participants had access to appropriate soil}
#'   \item{SOIL_TYPE}{Which soil}
#'   \item{IBUTON_READER}{Whether participants had access to climate logger (iButton) readers}
#'   \item{NUMBER_OF_SITES}{Whether participants were running experiments in one or multiple locations.}
#'   \item{NOTES}{}
#'   \item{Pathogen.sampling}{Whether participants aimed to join pathogen sampling experiment}
#' }
#' @source \url{https://grenenet.wordpress.com/}
"sitesinfo"

################################################################################
## Gather flowering time from GrENE net samples
## Created May 16 2020
## By Moi
################################################################################

# mypaths<-c("/home/mexpositoalonso/R/library-calc/3.6", "/carnegie/binaries/centos7/r/3.6.2/lib64/R/library")
# .libPaths(mypaths)
# .libPaths()
library(ggplot2)
library(cowplot)
theme_set(theme_cowplot())
library(ggpmisc)
library(devtools)
library(tidyverse)


setwd("~/safedata/ath_evo/grenephase1/")

####************************************************************************####

# samples2018<-read.csv('data-raw/GrENE-net_records_2017-2020-Samples_2018.csv.fixed.csv',header=T,fill=T)
# samples2019<-read.csv('data-raw/GrENE-net_records_2017-2020-Samples_2019.csv.fixed.csv',header=T,fill=T)
# samples2020<-read.csv('data-raw/GrENE-net_records_2017-2020-Samples_2020.csv.fixed.csv',header=T,fill=T)
# head(samples2018)
# head(samples2019)
# head(samples2020)
#
# sam<-rbind(samples2018, samples2019, samples2020)
sam<-read.csv('data-raw/GrENE-net_samples_manuallycombined - Sheet1.csv',header=T)
head(sam)


sam %>%
  dplyr::mutate(NUMBER_FLOWERS_COLLECTED=as.numeric(NUMBER_FLOWERS_COLLECTED)) %>%
  dplyr::filter(CODES=='FH', !is.na(NUMBER_FLOWERS_COLLECTED)) %>%
  # dplyr::filter(!is.na(DATE) | DATE=='na' | DATE=='x') %>%
  # dplyr::filter(grepl("2018",DATE) | grepl("2019",DATE)) %>%
  dplyr::mutate(DATE=as.numeric(as.matrix(DATE)))->
  p

head(p)
p %>%
  mutate(truedate=as.Date(as.character(DATE),format="%Y%m%d") ) %>%
  mutate(year= substring(DATE,1,4))->
p
head(p)

# p %>%
#   dplyr::group_by(SITE,year) %>%
#   summarize(meandate=median(truedate,na.rm = T),
#             varrange=sd(truedate,na.rm = T)
#             ) ->
#   psum
# head(psum)


p %>%
  dplyr::group_by(SITE,year) %>%
  mutate(startyear=as.Date(paste0(year,"0101"),format="%Y%m%d")) %>%
  mutate(fracflowers=NUMBER_FLOWERS_COLLECTED/sum(NUMBER_FLOWERS_COLLECTED)) %>%
  mutate(dayofyear=truedate-startyear) %>%
  na.omit() ->
  pnew

hist(as.numeric(pnew$dayofyear))


pnew %>%
  # dplyr::filter(dayofyear<230) %>% # to eliminate the fall generation
  # dplyr::filter(dayofyear>20) %>% # to eliminate the fall generation
  summarize(wmean=sum(dayofyear*fracflowers,na.rm = T),
            varflo=sd(dayofyear)) %>%
  mutate(wmean=as.numeric(wmean)) ->
wmean

#
# pnew %>%
#   # dplyr::filter(dayofyear<230) %>% # to eliminate the fall generation
#   # dplyr::filter(dayofyear>20) %>% # to eliminate the fall generation
#   summarize(wmean=mean(dayofyear[NUMBER_FLOWERS_COLLECTED==max(NUMBER_FLOWERS_COLLECTED)]),
#             varflo=sd(dayofyear)) %>%
#   mutate(wmean=as.numeric(wmean)) ->
#   wmean

plot(wmean$varflo,wmean$wmean)
hist(wmean$varflo)

# wmean<-dplyr::filter(varflo<60)
toplot<-wmean

#### add participants ####
sitesinfo<-read.csv("data-raw/GrENE-sites_info-CuratedParticipants.csv",header = T)
head(sitesinfo)

toplot<-merge(toplot,sitesinfo,by.x='SITE', by.y="SITE_CODE")
head(toplot)

ggplot(toplot) +
  geom_point(aes(x=wmean,y=LATITUDE)) +
  stat_smooth(aes(x=wmean,y=LATITUDE),method='glm',se=F,color='grey') +
  facet_wrap(~year)

cor.test(toplot$LATITUDE,toplot$wmean)

#### change from one year to next
wmean %>%
  select(-varflo) %>%
  spread(key="year",value="wmean") ->
  ftcompare

wmean %>%
  select(-wmean) %>%
  spread(key="year",value="varflo") ->
  ftcompare2


summary(ftcompare$`2019` - ftcompare$`2018`)
summary(ftcompare$`2020` - ftcompare$`2019`)

summary(ftcompare2$`2019` - ftcompare$`2018`)

View(ftcompare)


#### write
towrite<- toplot %>%
  dplyr::group_by(SITE) %>%
  summarize(Flowering_peak=mean(wmean),
            Flowering_sd=mean(varflo)
            )
head(towrite)

towrite<-merge(towrite,dplyr::select(sitesinfo, SITE_CODE,SITE_NAME,LATITUDE,LONGITUDE,ALTITUDE),
               by.x='SITE', by.y="SITE_CODE")
head(towrite)

write.csv(file = 'preliminary_flowering_peaks_GrENE-net.csv',towrite)

plot(towrite$Flowering_peak,towrite$LATITUDE)
cor.test(towrite$Flowering_peak,towrite$LATITUDE)

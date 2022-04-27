
Study whether there are trade-offs in phenotypes that may be under selection
and measure whether these may imply constraints to adaptation


knitr::opts_knit$set(root.dir = "~/safedata/ath_evo/grenephase1")
setwd("~/safedata/ath_evo/grenephase1")

knitr::opts_chunk$set(echo = TRUE)
library(ggplot2)
# library(ggpmisc)
library(cowplot)
theme_set(theme_cowplot())
library(RColorBrewer)
library(tidyverse)
# devtools::install("~/safedata/genemaps/")
library(genemaps)
devtools::load_all(".")

library(data.table)



# Read founder frequency from seeds and 1001genomes

frqseeds<-data.table::fread("data-big/seedscombined.chr5.frq") %>% data.frame
dim(frqseeds)
head(frqseeds)
frqseeds$SNP<-paste0(frqseeds[,1],"_", frqseeds[,2])
# head(frqseeds)


frq231<-data.table::fread("data-big/231g.frq") %>%
          data.frame %>%
          dplyr::filter(CHR==5)
# head(frq231)

frq<-merge(frqseeds,frq231,by="SNP") %>%
      rename(A1x=V3, A2x=V4, A1y=A1,A2y=A2, FRQ=V5, POS=V2) %>%
      dplyr::select(SNP, CHR, POS, A1x, A2x, A1y,A2y, MAF, FRQ, NCHROBS) %>%
      dplyr::mutate(MAF= ifelse(A1x==A1y, MAF, 1-MAF)) %>%
      data.frame

# dim(frq)
# head(frq)

# Plot relationship
toplot=frq
founder_vcfvsseeds<-ggplot(data=frq) +
  # geom_point(aes(y=FRQ,x=MAF))+
  geom_hex( aes(y=FRQ , x= MAF), bins=50) +
  scale_fill_gradientn("# SNPS",colours = RColorBrewer::brewer.pal(9, "Greys")[-1], trans='log10')+
  scale_fill_gradientn("# SNPS",colours = RColorBrewer::brewer.pal(9, "Greys")[-1], trans='log10')+
  labs(y="Deep Pool-Seq of seeds (REF allele freq)",
      x="1001 founder vcf (REF allele freq)")

founder_vcfvsseeds

save_plot(filename = "figs/founders_seeds_vs_vcf_chr5.pdf",
          founder_vcfvsseeds +coord_equal(),
          base_height = 5,base_width = 6)





# Fixed proportion across locations

frqseeds<-data.table::fread("data-big/seedscombined.chr5.frq") %>% data.frame %>%
  dplyr::mutate(SNP=paste0(V1,"_",V2))

gfreq<-data.table::fread("data-big/plate123.chr5.plink.frq") %>%
  rename(newMAF=MAF)

fg<-merge(frqseeds, gfreq,by.x='SNP',by.y='SNP') %>%
      rename(A1x=V3, A2x=V4, FRQ=V5) %>%
      rename(A1y=A1, A2y=A2, newFRQ=newMAF) %>%
      dplyr::filter( (A1y == A1x  | A1y == A2x) & (A2y == A1x  | A2y == A2x)) %>%
      dplyr::mutate(newFRQ= ifelse(A1y==A1x, newFRQ, 1-newFRQ)) %>%
      data.frame

summary(fg$newFRQ)
summary(fg$FRQ)

library(RColorBrewer)
freqchange_by_freq<-ggplot(data=fg) +
  geom_hex( aes(y=newFRQ - FRQ , x= FRQ), bins=50) +
  scale_fill_gradientn("# SNPS",colours = RColorBrewer::brewer.pal(9, "Greys")[-1], trans='log10')+
  geom_hline(yintercept=0, color='black',lty='dotted')+
  geom_abline(intercept = 1,slope=-1, lty='dotted')+
  geom_abline(intercept = 0,slope=-1, lty='dotted')+
  stat_smooth(aes(y=newFRQ - FRQ , x= FRQ), method='glm',formula = y~0+x+I(x^2)+I(x^3), color="lightgreen", lty='dashed') +
  ylim(c(-1,1))+
  labs(y="change in frequency (across all sites)", x='starting founder frequency')

freqchange_by_freq

save_plot(filename = "figs/global_frequency_change_vs_start_chr5_matchalleles.pdf",
          freqchange_by_freq,
          base_height = 5,base_width = 6)

write.table(file="tables/freqchange_by_freq.chr5.txt",fg,quote = F, row.names = F,col.names = T)


# Just focus on folded
fg_<- fg%>%
  dplyr::mutate(df=newFRQ-FRQ)%>%
  dplyr:::mutate(FRQ=ifelse(FRQ >0.5, 1-FRQ, FRQ),
                 newFRQ=ifelse(newFRQ >0.5, 1-newFRQ, newFRQ)
                 )
ggplot(data=fg_) +
  geom_hex( aes(y=newFRQ - FRQ , x= FRQ), bins=50) +
  scale_fill_gradientn("# SNPS",colours = RColorBrewer::brewer.pal(9, "Greys")[-1], trans='log10')+
  # geom_hline(yintercept=0, color='black',lty='dotted')+
  # geom_abline(intercept = 1,slope=-1, lty='dotted')+
  # geom_abline(intercept = 0,slope=-1, lty='dotted')+
  # stat_smooth(aes(y=newFRQ - FRQ , x= FRQ), method='glm',formula = y~0+x+I(x^2)+I(x^3), color="lightgreen", lty='dashed') +
  stat_smooth(aes(y=newFRQ - FRQ , x= FRQ), color="lightgreen", lty='dashed') +
  # ylim(c(-1,1))+
  labs(y="change in frequency (across all sites)", x='starting founder frequency')

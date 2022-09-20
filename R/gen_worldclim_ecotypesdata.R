# devtools::load_all(".")
# library(ggplot2)
# library(cowplot)
# library(moiR)
# library(plyr)
# library(dplyr)
# library(raster)

# devtools::install_github("MoisesExpositoAlonso/moiR")

################################################################################
#### accessions ####
load("data/ecotypes.rda")
load("data/sitesinfo.rda")

################################################################################
### Get climate data

# refresh=T
# fut=raster::getData(name ="CMIP5" ,res="2.5",path="~",var="bio",model="MP",rcp=85,year=50, download = refresh) # MP for Max Planck
# pres=raster::getData(name ="worldclim" ,res="2.5",path=".",var="bio",download = refresh)
library(raster)
bionow<-getData('worldclim', var='bio', res=2.5,path='~/natvar')
precnow<-getData('worldclim', var='prec', res=2.5,path='~/natvar')
minnow<-getData('worldclim', var='tmin', res=2.5,path='~/natvar')
maxnow<-getData('worldclim', var='tmax', res=2.5,path='~/natvar')
# pet<-stack(filename = paste0('~/natvarpet/','petworld.gri'),path='~/natvar')

### Create coordinates
coords=
  rbind(
  ecotypes[,c("LONGITUDE","LATITUDE")],
  sitesinfo[,c("LONGITUDE","LATITUDE")]
  )
Locations=coords

### Extract info
biom<-raster::extract(bionow,Locations)
precm<-raster::extract(precnow,Locations)
minm<-raster::extract(minnow,Locations)
maxm<-raster::extract(maxnow,Locations)
# petm<-raster::extract(pet,Locations)
climext<-list(biom,precm,minm,maxm)
climext<-do.call(cbind,climext)


### join with site information and ecotype information
ecotypes.clim<- cbind(ecotypes,climext[1:nrow(ecotypes),])
sites.clim<- cbind(sitesinfo,climext[-c(1:nrow(ecotypes)),])

### Save in data/
write.table(ecotypes.clim,file = "data/ecotypes.clim.tsv",quote = F,col.names = T,row.names = F)
usethis::use_data(ecotypes.clim,overwrite = T)

write.table(sites.clim,file = "data/sites.clim.tsv",quote = F,col.names = T,row.names = F)
usethis::use_data(sites.clim,overwrite = T)











# ################################################################################
# #### The locations ####
# # grenestations=read.table("data-raw/Sites_info - Participants.tsv",header=TRUE,fill=TRUE,sep="\t")
# grenestations=read.table("data-raw/GrENE-sites_info - Participants_TOGOOGLE.tsv",header=TRUE,fill=TRUE,sep="\t")
# head(grenestations)
#
# climstation=
#   sapply(1:19, function(b){
#   raster::extract(pres[[b]],grenestations[,c("LONGITUDE","LATITUDE")])
# })
# colnames(climstation)<-names(pres)
#
# grenestations.clim <- cbind(grenestations,climstation)
#
#
# #### plot clima ####
# # grenerange=ggplot()+
# #   geom_point(data=grenelist.clim, aes(y=bio1, x=bio12)) +
# #   geom_point(data=grenestations.clim, aes(y=bio1, x=bio12), size=4, shape=1, col="red") +
# #   ylab("Mean Annual Temperature (ºC x 10)")+ xlab("Mean Annual precipitation (mm)")
# # grenerange
#
# save_plot(file="figs/grene_climate.pdf",plot = grenerange,base_height = 7, base_width = 7)
#
#
# #### plot geo ####
#
# grenelist$longitude = as.numeric(grenelist$longitude)
# grenelist$latitude = as.numeric(grenelist$latitude)
# grenestations$LONGITUDE<-moiR::fn(grenestations$LONGITUDE)
# grenestations$LATITUDE<-moiR::fn(grenestations$LATITUDE)
#
#
# p<-ggplot_world_map()
# p<-ggplot_world_map(projection="ortho")
# p<-p+ geom_point(data=grenelist, aes(y=grenelist$latitude, x=grenelist$longitude),size=1, shape=1)
# p<-p+ geom_point(data=grenestations,aes(y=LATITUDE, x=LONGITUDE),size=3, shape=16, col="green4")
# p
#
# save_plot(file="figs/grene_map.pdf",plot = p,base_height = 8, base_width = 12)
# save_plot(file="figs/grene_map-ortho.pdf",plot = p,base_height = 8, base_width = 12)
#
# #### combined ####
#
# ppanel=plot_grid(p,grenerange,ncol=1)
# ppanel
#
# save_plot(file="figs/grene_map_climate.pdf",plot = ppanel,base_height = 8, base_width = 6)

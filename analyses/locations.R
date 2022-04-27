devtools::load_all(".")
# library(ggplot2)
# library(cowplot)
# library(moiR)
# library(plyr)
# library(dplyr)
# library(raster)

# devtools::install_github("MoisesExpositoAlonso/moiR")

################################################################################
#### accessions ####
data("grenelist")
grenelist
head(grenelist)

################################################################################
### Get climate
refresh=TRUE
pres=raster::getData(name ="worldclim" ,res="2.5",path=".",var="bio",download = refresh)
# fut=raster::getData(name ="CMIP5" ,res="2.5",path="~",var="bio",model="MP",rcp=85,year=50) # MP for Max Planck

coords=grenelist[,c("longitude","latitude")]
grenelist$longitude<-as.numeric(grenelist$longitude)
grenelist$latitude<-as.numeric(grenelist$latitude)

climgenom=
  sapply(1:19, function(b){
  raster::extract(pres[[b]],grenelist[,c("longitude","latitude")])

})

colnames(climgenom)<-names(pres)
grenelist.clim <- cbind(grenelist,climgenom)

################################################################################
#### The locations ####
# grenestations=read.table("data-raw/Sites_info - Participants.tsv",header=TRUE,fill=TRUE,sep="\t")
grenestations=read.table("data-raw/GrENE-sites_info - Participants_TOGOOGLE.tsv",header=TRUE,fill=TRUE,sep="\t")
head(grenestations)

climstation=
  sapply(1:19, function(b){
  raster::extract(pres[[b]],grenestations[,c("LONGITUDE","LATITUDE")])
})
colnames(climstation)<-names(pres)

grenestations.clim <- cbind(grenestations,climstation)


#### plot clima ####
grenerange=ggplot()+
  geom_point(data=grenelist.clim, aes(y=bio1, x=bio12)) +
  geom_point(data=grenestations.clim, aes(y=bio1, x=bio12), size=4, shape=1, col="red") +
  ylab("Mean Annual Temperature (ºC x 10)")+ xlab("Mean Annual precipitation (mm)")
grenerange

save_plot(file="figs/grene_climate.pdf",plot = grenerange,base_height = 7, base_width = 7)


#### plot geo ####

grenelist$longitude = as.numeric(grenelist$longitude)
grenelist$latitude = as.numeric(grenelist$latitude)
grenestations$LONGITUDE<-moiR::fn(grenestations$LONGITUDE)
grenestations$LATITUDE<-moiR::fn(grenestations$LATITUDE)


p<-ggplot_world_map()
p<-ggplot_world_map(projection="ortho")
p<-p+ geom_point(data=grenelist, aes(y=grenelist$latitude, x=grenelist$longitude),size=1, shape=1)
p<-p+ geom_point(data=grenestations,aes(y=LATITUDE, x=LONGITUDE),size=3, shape=16, col="green4")
p

save_plot(file="figs/grene_map.pdf",plot = p,base_height = 8, base_width = 12)
save_plot(file="figs/grene_map-ortho.pdf",plot = p,base_height = 8, base_width = 12)

#### combined ####

ppanel=plot_grid(p,grenerange,ncol=1)
ppanel

save_plot(file="figs/grene_map_climate.pdf",plot = ppanel,base_height = 8, base_width = 6)

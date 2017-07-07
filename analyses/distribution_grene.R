devtools::load_all(".")

#### accessions ####
data("grenelist")
grenelist

refresh=F
pres=raster::getData(name ="worldclim" ,res="2.5",path=".",var="bio",download = refresh)
# fut=raster::getData(name ="CMIP5" ,res="2.5",path="~",var="bio",model="MP",rcp=85,year=50) # MP for Max Planck

climgenom=
  sapply(1:19, function(b){
  raster::extract(pres[[b]],grenelist[,c("longitude","latitude")])
})
colnames(climgenom)<-names(pres)
grenelist.clim <- cbind(grenelist,climgenom)

#### The locations ####

grenestations = readOGR("data-raw/GRENE-net.kml", "GRENE-net stations")
grenestations %>% attributes()

grenestations.df = data.frame(longitude=coordinates(grenestations)[,c(1)],
                              latitude=coordinates(grenestations)[,c(2)],
                              name = grenestations$Name
                              )


climstation=
  sapply(1:19, function(b){
  raster::extract(pres[[b]],grenestations.df[,c("longitude","latitude")])
})
colnames(climstation)<-names(pres)

grenestations.clim <- cbind(grenestations.df,climstation)


#### plot clima ####
library(ggplot2)
library(cowplot)
grenerange=ggplot()+
  geom_point(data=grenelist.clim, aes(y=bio1, x=bio12)) +
  geom_point(data=grenestations.clim, aes(y=bio1, x=bio12), size=4, shape=1, col="red") +
  ylab("Mean Annual Temperature (ºC x 10)")+ xlab("Mean Annual precipitation (mm)")
grenerange

save_plot(file="figs/grene_range_climate.pdf",plot = grenerange,base_height = 7, base_width = 7)

#### plot geo ####
devtools::load_all("~/mexposito/moiR")
p=ggplot_world_map()
p

northern_hemisphere_map<-function(raster){

library(raster)
library(rgdal)

projectionCRS <- CRS("+proj=laea +lon_0=0.001 +lat_0=89.999 +ellps=sphere")

#http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_ocean.zip
area <- readOGR("~/Dropbox/Writing/Published/LOF_Drought_Paper/Data/ne_10m_ocean/ne_10m_ocean.shp")
projection(area)<-"+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
area <- spTransform(area, CRS=projectionCRS)

#raster data
tmin<-getData('worldclim', var='tmin', res=2.5)
tmin1<-tmin$tmin1
tmin1 <- projectRaster(tmin1, crs=projectionCRS)

### TRY FIDDLING WITH THESE LIMITS###
#how this zooming works in non-intuitive, I suggest trial and error to find your numbers
xlimUnproj <- c(-45,120)
ylimUnproj <- c(5,25)

xlimUnproj <- c(-45,125)
ylimUnproj <- c(-65,-80)
sPointsLims <- data.frame(x=xlimUnproj, y=ylimUnproj)
coordinates(sPointsLims) = c("x", "y")
#set CRS (coordinate reference system) for the points
#assuming WGS84
proj4string(sPointsLims) <- CRS("+proj=longlat +ellps=WGS84")
sPointsLims <- spTransform(sPointsLims, CRS=projectionCRS)
xlim <- coordinates(sPointsLims)[,"x"]
ylim <- coordinates(sPointsLims)[,"y"]

# reproject points for plotting
Locations<-data.frame(longitude=c(9.0576), latitude=c(48.5216))
coordinates(Locations) = c("longitude", "latitude")
proj4string(Locations) <- CRS("+proj=longlat +ellps=WGS84")
sPointsDF <- spTransform(Locations, CRS=projectionCRS)

# pdf("~/Desktop/tmin1.pdf")
plot(tmin1,xlim=xlim, ylim=ylim, col=colorRampPalette(c('royalblue4',"royalblue3", 'royalblue2', "royalblue1", "white","orange1", "orange2","orange4"))(255), main="Fall", xaxt='n', yaxt='n', ann=FALSE, legend=F)
llgridlines(area, easts=c(-90,-180,0,90,180), norths=seq(0,90,by=15),
            plotLabels=FALSE, ndiscr=1000, col=adjustcolor("gray20", 0.5), lwd=1)
markings <- data.frame(Latitude=as.numeric(c(75,60,45,30,15,85,85)), Longitude=as.numeric(c(-45,-45,-45,-45,-45,0,180)),name=c("75", "60","45","30","15","0","180"))
coordinates(markings) = c("Longitude", "Latitude")
proj4string(markings) <- CRS("+proj=longlat +ellps=WGS84")
sPointsDFmark <- spTransform(markings, CRS=projectionCRS)
text(sPointsDFmark, labels = sPointsDFmark$name, cex=1, col="gray30")
points(sPointsDF, pch=3, cex=1, lwd=1)
# dev.off()

}


# library(raster)
# library(rgdal)
#
# projectionCRS <- CRS("+proj=laea +lon_0=0.001 +lat_0=89.999 +ellps=sphere")
#
# #http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_ocean.zip
# area <- readOGR("~/Dropbox/Writing/Published/LOF_Drought_Paper/Data/ne_10m_ocean/ne_10m_ocean.shp")
# projection(area)<-"+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
# area <- spTransform(area, CRS=projectionCRS)
#
# #raster data
# tmin<-getData('worldclim', var='tmin', res=2.5)
# tmin1<-tmin$tmin1
# tmin1 <- projectRaster(tmin1, crs=projectionCRS)
#
# ### TRY FIDDLING WITH THESE LIMITS###
# #how this zooming works in non-intuitive, I suggest trial and error to find your numbers
# xlimUnproj <- c(-45,120)
# ylimUnproj <- c(5,25)
#
# xlimUnproj <- c(-45,125)
# ylimUnproj <- c(-65,-80)
# sPointsLims <- data.frame(x=xlimUnproj, y=ylimUnproj)
# coordinates(sPointsLims) = c("x", "y")
# #set CRS (coordinate reference system) for the points
# #assuming WGS84
# proj4string(sPointsLims) <- CRS("+proj=longlat +ellps=WGS84")
# sPointsLims <- spTransform(sPointsLims, CRS=projectionCRS)
# xlim <- coordinates(sPointsLims)[,"x"]
# ylim <- coordinates(sPointsLims)[,"y"]
#
# # reproject points for plotting
# Locations<-data.frame(longitude=c(9.0576), latitude=c(48.5216))
# coordinates(Locations) = c("longitude", "latitude")
# proj4string(Locations) <- CRS("+proj=longlat +ellps=WGS84")
# sPointsDF <- spTransform(Locations, CRS=projectionCRS)
#
# # pdf("~/Desktop/tmin1.pdf")
# plot(tmin1,xlim=xlim, ylim=ylim, col=colorRampPalette(c('royalblue4',"royalblue3", 'royalblue2', "royalblue1", "white","orange1", "orange2","orange4"))(255), main="Fall", xaxt='n', yaxt='n', ann=FALSE, legend=F)
# llgridlines(area, easts=c(-90,-180,0,90,180), norths=seq(0,90,by=15),
#             plotLabels=FALSE, ndiscr=1000, col=adjustcolor("gray20", 0.5), lwd=1)
# markings <- data.frame(Latitude=as.numeric(c(75,60,45,30,15,85,85)), Longitude=as.numeric(c(-45,-45,-45,-45,-45,0,180)),name=c("75", "60","45","30","15","0","180"))
# coordinates(markings) = c("Longitude", "Latitude")
# proj4string(markings) <- CRS("+proj=longlat +ellps=WGS84")
# sPointsDFmark <- spTransform(markings, CRS=projectionCRS)
# text(sPointsDFmark, labels = sPointsDFmark$name, cex=1, col="gray30")
# points(sPointsDF, pch=3, cex=1, lwd=1)
# # dev.off()

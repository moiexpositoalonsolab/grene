
p<-ggplot_world_map()
p
p<-p+ geom_point(data=grenelist, aes(y=grenelist$latitude, x=grenelist$longitude))
p
p<-p+ geom_point(data=grenestations,aes(y=LATITUDE, x=LONGITUDE),size=2, shape=1, col="red")
p

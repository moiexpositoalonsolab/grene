library(dplyr)
library(tidyr)


# Create list of names
listofnames<-c(
 paste0("bio",1:19),
 paste0("prec",1:12),
 paste0("tmin",1:12),
 paste0("tmax",1:12)
)
listoffiles<-
  paste0(
    "~/safedata/natvar/climate/",listofnames,"/output/",listofnames,".assoc.txt"
  )
# load all
clim.alleles<-
do.call(rbind,
  lapply(1:length(listoffiles), function(i){
  x=listoffiles[i]
  getname<-listofnames[i]
  tmp<-dplyr::select(data.table::fread(x), chr,ps,beta)
  tmp$pheno=getname
  return(tmp)
  })
)
dim(clim.alleles)

clim.alleles<- clim.alleles %>% pivot_wider(., names_from=pheno, values_from=beta)

dim(clim.alleles)

# Save
write.csv(clim.alleles,file = "data/alleles.clim.csv",quote = F,row.names = F)
saveRDS(clim.alleles, file="data/alleles.clim.rds")
# usethis::use_data(sites.clim,overwrite = T)

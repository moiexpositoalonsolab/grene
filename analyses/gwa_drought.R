


d<-data.table::fread("~/safedata/natvar/phenotypes/Weigel_Exposito-Alonso_NatEcoEvo_2018_PID_29255303/1001/drought_index/output/Weigel_Exposito-Alonso_NatEcoEvo_2018_PID_29255303.lmm.assoc.txt")
d$rowpos<-1:nrow(d)

d_<-dplyr::filter(d,chr==5, 
                  p_lrt<0.05)

# d_<-d %>%
#   group_by(chr) %>%
#   dplyr::mutate(cumpos = cumsum(as.numeric(ps))) %>%

d_<-dplyr::filter(d,
                  p_lrt<0.0001)
  ggplot(d_ )+
  # geom_hex(aes(y=-log10(p_lrt),x= rowpos)) 
  geom_point(aes(y=-log10(p_lrt),x= rowpos, color=factor(chr))) +
  scale_color_manual("",values=c("grey40","grey","grey40","grey","grey40"))


dtop<- dplyr::filter(d_, p_lrt < 0.000001) %>% select(chr, ps)

write.table(file="~/topdrought.txt", dtop, quote=F,row.names=F,col.names=F)


tair<-read.table("~/safedata/minivcftools/TAIR10_GFF3_genes_transposons.gff")

tair<-dplyr::filter(tair, V3 =="gene")


matched<-apply(dtop, 1, function(x){
dplyr::filter(tair, V1 == paste0("Chr",x[1]) , V4<= x[2], V5>= x[2])
}) 


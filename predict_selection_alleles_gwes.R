#
# listoffiles<-
#   c(
#     "~/safedata/natvar/phenotypes/Salt_Busoms_PNAS_2018_PID_30530653/1001/Sodium/output/Salt_Busoms_PNAS_2018_PID_30530653.lmm.assoc.txt",
#     "~/safedata/natvar/phenotypes/Kliebenstein_Chan_PlosGen_2010_PID_21079692/1001/proline_exp1/output/Kliebenstein_Chan_PlosGen_2010_PID_21079692.lmm.assoc.txt",
#     "~/safedata/natvar/phenotypes/Schmitt_Martinez-Berdeja_PNAS_2020_PID_/gemma/d32_4C_perc//output/Schmitt_Martinez-Berdeja_PNAS_2020_PID_.lmm.assoc.txt",
#     "~/safedata/natvar/phenotypes/Schmitt_Martinez-Berdeja_PNAS_2020_PID_/gemma/base_perc/output/Schmitt_Martinez-Berdeja_PNAS_2020_PID_.lmm.assoc.txt",
#     "~/safedata/natvar/phenotypes/1001_Consortium_Cell_2016_PID_27293186/1001/FT10/output/1001_Consortium_Cell_2016_PID_27293186.lmm.assoc.txt",
#     "~/safedata/natvar/DroughtRespPC_GWA/Escape_Avoid/output/pc1.assoc.txt",
#     "~/safedata/natvar/phenotypes/Busch_Slovak_PlantCell_2014_PID_24920330/gemma/Root_angle_day005/output/Busch_Slovak_PlantCell_2014_PID_24920330.lmm.assoc.txt",
#     "~/safedata/natvar/phenotypes/Vasseur_2018_PNAS_PID_29540570/gemma/RGR/output/Vasseur_2018_PNAS_PID_29540570.assoc.txt",
#     "~/safedata/natvar/phenotypes/Vasseur_2018_PNAS_PID_29540570/gemma/rosette_DM/output/Vasseur_2018_PNAS_PID_29540570.assoc.txt",
#     "~/safedata/natvar/phenotypes/Weigel_Exposito-Alonso_NatEcoEvo_2018_PID_29255303/1001/drought_index/output/Weigel_Exposito-Alonso_NatEcoEvo_2018_PID_29255303.lmm.assoc.txt",
#     "~/safedata/natvar/phenotypes/Meaux_Dittberner_MolEcol_2018_PID_30118161/gemma/stomata_density/output/Meaux_Dittberner_MolEcol_2018_PID_30118161.lmm.assoc.txt",
#     "~/safedata/natvar/phenotypes/Meaux_Dittberner_MolEcol_2018_PID_30118161/1001/Delta_13C/output/Meaux_Dittberner_MolEcol_2018_PID_30118161.lmm.assoc.txt",
#     "~/safedata/natvar/DroughtRespPC_GWA/Escape_Avoid/output/pc15.assoc.txt",
#     "~/safedata/natvar/phenotypes/Exposito-Alonso_Nature_2019_PID_31462776/1001/rFitness_thi/output/Exposito-Alonso_Nature_2019_PID_31462776.lmm.assoc.txt",
#     "~/safedata/natvar/phenotypes/Exposito-Alonso_Nature_2019_PID_31462776/1001/rFitness_mlp/output/Exposito-Alonso_Nature_2019_PID_31462776.lmm.assoc.txt"
#     "~/safedata/natvar/phenotypes/Exposito-Alonso_Nature_2019_PID_31462776/1001/rFitness_thi/output/Exposito-Alonso_Nature_2019_PID_31462776.lmm.assoc.txt",
#
#   )
# listofnames<-c(
#   "Sodium",
#   "proline_exp1",
#   "d32_4C_perc",
#   "base_perc",
#   "FT10",
#   "pc1",
#   "Root_angle_day005",
#   "RGR",
#   "rosette_DM",
#   "drought_index",
#   "stomata_density",
#   "Delta_13C",
#   "pc15",
#   "rFitness_thi",
#   "rFitness_mlp"
# )
# # load all
#
# gwas<-lapply(1:length(listoffiles), function(i){
#   x=listoffiles[i]
#   getname<-listofnames[i]
#   tmp<-data.table::fread(x) %>% select(chr,ps,p_score) #%>% head
#   tmp$pheno=getname
#   return(tmp)
# }) %>%  do.call(rbind,.)
# gwasbackkup<-gwas
# # predictselectiongwes<-
# # function(s.alleles,clim.alleles,clim.sites)
# # {
# # # Subset data in train and test
# #
# # # Make the matrices
# #   y=
# #
# # }
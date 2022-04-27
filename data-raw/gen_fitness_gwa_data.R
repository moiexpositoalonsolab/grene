library(dplyr)
library(data.table)

d<-list(
  (data.table::fread("~/safedata/natvar/phenotypes/Exposito-Alonso_Nature_2019_PID_31462776/1001/norm_rFitness_mhi/output/Exposito-Alonso_Nature_2019_PID_31462776norm.lmm.assoc.txt") %>%
     select(chr,rs,ps,n_miss,allele1,allele0, beta,se) %>%
     mutate(z=beta/se) %>%
     select(-beta, -se)),
  (data.table::fread("~/safedata/natvar/phenotypes/Exposito-Alonso_Nature_2019_PID_31462776/1001/norm_rFitness_mhp/output/Exposito-Alonso_Nature_2019_PID_31462776norm.lmm.assoc.txt") %>%
     select(beta,se) %>%
     mutate(z=beta/se) %>%
     select(-beta, -se)),
  (data.table::fread("~/safedata/natvar/phenotypes/Exposito-Alonso_Nature_2019_PID_31462776/1001/norm_rFitness_mli/output/Exposito-Alonso_Nature_2019_PID_31462776norm.lmm.assoc.txt") %>%
     select(beta,se) %>%
     mutate(z=beta/se) %>%
     select(-beta, -se)),
  (data.table::fread("~/safedata/natvar/phenotypes/Exposito-Alonso_Nature_2019_PID_31462776/1001/norm_rFitness_mlp/output/Exposito-Alonso_Nature_2019_PID_31462776norm.lmm.assoc.txt") %>%
     select(beta,se) %>%
     mutate(z=beta/se) %>%
     select(-beta, -se)),
  (data.table::fread("~/safedata/natvar/phenotypes/Exposito-Alonso_Nature_2019_PID_31462776/1001/norm_rFitness_thi/output/Exposito-Alonso_Nature_2019_PID_31462776norm.lmm.assoc.txt") %>%
     select(beta,se) %>%
     mutate(z=beta/se) %>%
     select(-beta, -se)),
  (data.table::fread("~/safedata/natvar/phenotypes/Exposito-Alonso_Nature_2019_PID_31462776/1001/norm_rFitness_thp/output/Exposito-Alonso_Nature_2019_PID_31462776norm.lmm.assoc.txt") %>%
     select(beta,se) %>%
     mutate(z=beta/se) %>%
     select(-beta, -se)),
  (data.table::fread("~/safedata/natvar/phenotypes/Exposito-Alonso_Nature_2019_PID_31462776/1001/norm_rFitness_tli/output/Exposito-Alonso_Nature_2019_PID_31462776norm.lmm.assoc.txt") %>%
     select(beta,se) %>%
     mutate(z=beta/se) %>%
     select(-beta, -se)),
  (data.table::fread("~/safedata/natvar/phenotypes/Exposito-Alonso_Nature_2019_PID_31462776/1001/norm_rFitness_tlp/output/Exposito-Alonso_Nature_2019_PID_31462776norm.lmm.assoc.txt") %>%
     select(beta,se) %>%
     mutate(z=beta/se) %>%
     select(-beta, -se))
) %>% do.call(cbind,.)

colnames(d)[ (ncol(d)-7):ncol(d) ] <-c("mhi" ,"thi" ,"mli" ,"tli", "mhp", "thp", "mlp", "tlp")

# Save
write.csv(alleles.lmmfit,file = "data/alleles.lmmfit.csv",quote = F,row.names = F)
saveRDS(alleles.lmmfit, file="data/alleles.lmmfit.rds")
# usethis::use_data(sites.clim,overwrite = T)

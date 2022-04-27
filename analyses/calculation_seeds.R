
library(dplyr)

#### GENERAL CALCULATIONS ####

20* 8*60   # number of seeds necessary in stock
10* 8*60   # number of seeds necessary in stock


60000 / 60 / 8

0.75 * 10000 / 60 / 8
0.75 * 10000 * 230/ 60 / 8


################################################################################
#### Seed by weight
# Using an instrucment RAUCH rauch.co.at, article number XA 52/2X
# col

wei= c( 0,NA, 0.00385,0.00578,0.00750,0.00934,0.01126,0.01328,NA, 0.01722,0.01924,0.02126)
seeds= seq(0,100*length(wei[-1]),by=100)

mod=lm(wei ~ seeds -1)
summary(mod)
modcol=mod
mod %>% summary()
plot(wei ~ seeds,pch=19, ylab="mg") ;abline(mod)

devtools::use_data(modcol)

# bur
wei=c(0,0.00135, 0.00264 , 0.00452 )
seeds= c(0,50, 100, 190)

mod=lm(wei ~ seeds-1)
modbur=mod
mod %>% summary()
plot(wei ~ seeds,pch=19) ;abline(mod)

devtools::use_data(modbur)

# 9965
wei=c(0,0.00067, NA ,0.00194, 0.00278 , 0.00346 )
seeds= c(0,50, 100, 150,200,250)

mod=lm(wei ~ seeds-1)
mod %>% summary()
mod9965=mod
plot(wei ~ seeds,pch=19) ;abline(mod)

devtools::use_data(mod9965, overwrite = F)

################################################################################
## Seeds per ecotype

ecotype.w<-read.table("data-raw/Grene-Net ecotypes\ -\ GrENE-net_final_list.tsv",header=TRUE,sep="\t")
ecotype.w= ecotype.w[-nrow(ecotype.w),] # remove the lowest row, that is the total

totwei=rbind(
            ecotype.w$weight_put_on_master_mix..g. / coefficients(modcol) ,
            ecotype.w$weight_put_on_master_mix..g. / coefficients(mod9965) ,
            ecotype.w$weight_put_on_master_mix..g. / coefficients(modbur)
            ) %>% apply(.,2,mean) %>% round

hist(ecotype.w$weight_put_on_master_mix..g.)
hist(totwei)
mean(totwei)
sum(totwei)

ecotype.w$estimated.number.of.seeds.in.total = totwei
head(ecotype.w)

# moiR::write.tsv(file="data/Grene-Net_ecotypes_andseeds.tsv",ecotype.w)

################################################################################
#### How much per epi ####
# an eppi full of 2 ML of seeds weights
wei2ml = 1.1022 # substracted the weight of the eppendorf
#
# options(scipen=999)
# mod %>%summary()
# wei2ml /coefficients(modcol)
# wei2ml /coefficients(modbur)
# wei2ml /coefficients(mod9965)
#
#
# 376.7 * (wei2ml/2)  /coefficients(modcol) # total amount of seeds
# 376.7 * (wei2ml/2)  / coefficients(modcol) * 0.75 / 60 / 8 # in one plot
#
# (0.5 * 230) * (wei2ml/2)  / coefficients(modcol)* 0.75 / 60 / 8 # in one plot
#
# 376.7 * (wei2ml/2)  / coefficients(modcol)* 0.75 / 60 / 8  / (60 * 40)
#
#
# 0.5 * (wei2ml/2)  / coefficients(modcol) * 0.75 / 60 / 12
# 0.17 / coefficients(modcol) * 0.75 / 60 / 8
# 0.17 / coefficients(modcol) * 0.75 / 60
# 0.38 / coefficients(modcol) * 0.75 / 60
# 0.38 / coefficients(modcol) * 0.75 / 60 /8
# 0.25 / coefficients(modcol) * 0.75 / 60 /8
# 0.3 / coefficients(modcol) * 0.75 / 60 /8
#
#
# weiperplot= 0.1
#
# 0.3 / coefficients(modcol)  * 0.75 / 60 / 12


#### Again, how much seeds per plot (12 plots now of 60 x 40 cm)

# 25 seeds per 231 ecotypes, by the weight on average per seed
25 * 231  * coefficients(modcol)

# all those seeds per cm2 of the plot
25 * 231 / (60*40)



0.1 / coefficients(modcol)
0.1 / coefficients(modbur)
0.1 / coefficients(mod9965)


5000 / 231

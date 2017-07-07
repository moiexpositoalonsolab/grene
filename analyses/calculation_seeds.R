library(dplyr)

#### GENERAL CALCULATIONS ####

20* 8*60   # number of seeds necessary in stock
10* 8*60   # number of seeds necessary in stock



60000 / 60 / 8

0.75 * 10000 / 60 / 8
0.75 * 10000 * 230/ 60 / 8



#### Seed by weight
# Using an instrucment RAUCH rauch.co.at, article number XA 52/2X
# col

wei= c(
  0,
  NA,
  0.00385,
  0.00578,
  0.00750,
  0.00934,
  0.01126,
  0.01328,
  NA,
  0.01722,
  0.01924,
  0.02126
)
seeds= seq(0,100*length(wei[-1]),by=100)


mod=lm(wei ~ seeds)
modcol=mod
mod %>% summary()
plot(wei ~ seeds,pch=19, ylab="mg") ;abline(mod)

# bur
wei=c(0,0.00135, 0.00264 , 0.00452 )
seeds= c(0,50, 100, 190)

mod=lm(wei ~ seeds)
modbur=mod
mod %>% summary()
plot(wei ~ seeds,pch=19) ;abline(mod)

# 9965
wei=c(0,0.00067, NA ,0.00194, 0.00278 , 0.00346 )
seeds= c(0,50, 100, 150,200,250)

mod=lm(wei ~ seeds)
mod %>% summary()
mod9965=mod
plot(wei ~ seeds,pch=19) ;abline(mod)

#### How much per epi ####
# an eppi full of 2 ML of seeds weights
wei2ml = 1.1022 # substracted the weight of the eppendorf

options(scipen=999)
mod %>%summary()
wei2ml /coefficients(modcol)[2]
wei2ml /coefficients(modbur)[2]
wei2ml /coefficients(mod9965)[2]


376.7 * (wei2ml/2)  /coefficients(modcol)[2] # total amount of seeds
376.7 * (wei2ml/2)  / coefficients(modcol)[2] * 0.75 / 60 / 8 # in one plot



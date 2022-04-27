
forcerecursive2<-function(z){
  myrow=length(z)
  mycol=max(sapply(z, length))
  tmp=matrix(ncol=mycol,nrow=myrow)
  for(i in 1:(length(z)) ){
    x=z[[i]]
    tmp[i,1:length(x)]<-x
  }
  return(tmp)
}




makedesignmatrix<-function(
                            predcodes = c('ml','th','UnitedKingdom','Andalucia','Germany','Finland')
                             ,
                             predcomb = c(length(predcodes),length(predcodes) -1)
                             ,
                             testcodes = predcodes
                             ,
                             testcomb =   c(1,length(testcodes))
                             ,
                             same=F
                             ){
  require(purrr)

  # all combinations of predictors

  res <- Map(combn, list(predcodes), predcomb , simplify = FALSE)
  res<-unlist(res, recursive = FALSE)

  res<-forcerecursive2(res)

  if(is.null(dim(res))){
    res<-matrix(res) %>% t()
  }
  if(ncol(res) != length(predcodes)){
    res<-cbind(res,rep(NA, length(predcodes)- ncol(res) ))
  }
  res

  # all combinations of testers
  res2 <- Map(combn, list(testcodes), testcomb , simplify = FALSE)
  res2 <-unlist(res2, recursive = FALSE)

  res2<-forcerecursive2(res2)

  if(is.null(dim(res2))){
    res2<-matrix(res2) %>% t()
  }
  if(ncol(res2) != length(predcodes)){
    res<-cbind(res2,rep(NA, length(predcodes)- ncol(res2) ))
  }
  res2
  # expand with predictors

  tmpgrid<-expand.grid(1:nrow(res),1:nrow(res2))
  tmpgrid
  design<-cbind(res[tmpgrid[,1] ,],res2[tmpgrid[,2] ,])
  design

  if(same==F){
    whichtokeep<- apply(design ,1, function(x){
                          !any(na.omit(x[1:length(predcodes)]) %in% na.omit(x[length(predcodes) + 1:length(testcodes)]))
                        })
   whichtokeep2<- apply(design ,1, function(x){
                              (length(na.omit(x[length(predcodes) + 1:length(testcodes) ])) ==length(testcodes) )
                        })

    design<-design[ which(whichtokeep==T | whichtokeep2==T),]

    if(is.null(dim(design))){
      design<-matrix(design) %>% t()
    }
  }

  rownames(design)<-1:nrow(design)


  return(design)
}

makedesignmatrix()

#####**********************************************************************#####
#### CLASS to test predictions ####


pred<-function(dat, envs, snps=NULL, focalcodes=c('mlp', 'mli','thi','thp'),
               predcomb=c(4),testcomb=c(1,4),
               design=NULL,
               nTraining=10000,nTesting=10000,method='rf', formula=NULL){

stopifnot(method %in% c('rf','lm'))
stopifnot(all(focalcodes %in%unique(envs) ))

####  get the positions where each env is
# mlp<- grepl('mlp',envs)
# mli<- grepl('mli',envs)
# thi<-grepl('thi',envs)
# thp<-grepl('thp',envs)
# possubsets <-list(mlp=mlp,mli=mli,thi=thi,thp=thp)


possubsets<-list()
for(i in focalcodes){
  tmplist<-list(grepl(i,envs))
  names(tmplist) <- i
  possubsets<-append(possubsets,tmplist)
}

####  get the design
if(is.null(design)){
message("creating analysis design")
design<-makedesignmatrix(predcodes = focalcodes,testcodes = focalcodes)
 #makedesignmatrix(predcodes = focalcodes, predcomb = predcomb, testcodes = focalcodes,testcomb = testcomb)
}

if(method=='rf'){
  traincommand='randomForest( y= pd$dat[TRAINING,1], x= pd$dat[TRAINING,-1])'
  # traincommand='randomForest( y= bdat[TRAINING,1], x= bdat[TRAINING,-1])'
  testcommand='randomForest:::predict.randomForest(pd$mods[[i]],pd$dat[TESTING,-1])'
}else if(method=='lm'){
  traincommand=paste('lm(data=pd$dat, ',formula,')')
  testcommand='predict.lm(pd$mods[[i]],pd$dat[TESTING,-1])'
}

### define objects
value<-list(dat=dat,
            focalcodes=focalcodes,
            nTraining=nTraining,
            nTesting=nTesting,
            method=method,

            possubsets=possubsets,
            trainsets=list(),
            testsets=list(),

            design=design,

            mods<-list(),

            traincommand=traincommand,
            testcommand=testcommand,

            results=list(),
            printresults=list(),
            plot=list()
          )
class(value) <- append(class(value),"pred")

####  Already sample points
value<-samplepoints(value)

return(value)
}

#####**********************************************************************#####

modifyformula<- function(pd){UseMethod("modifyformula")}
modifyformula.pred <- function(pd, formula){
  if(pd$method=='rf'){
    traincommand='randomForest( y= pd$dat[TRAINING,1], x= pd$dat[TRAINING,-1])'
    testcommand='randomForest:::predict.randomForest(pd$mods[[i]],pd$dat[TESTING,-1])'
  }else if(pd$method=='lm'){
    traincommand=paste('lm(data=pd$dat, ',formula,')')
    testcommand='predict.lm(pd$mods[[i]],pd$dat[TESTING,-1])'
  }
}

modifydesign<- function(pd){UseMethod("modifydesign")}
modifydesign.pred <- function(pd, focalcodes=c('mlp', 'mli','thi','thp'), predcomb=c(4),testcomb=c(1,4)){
  pd$design<-makedesignmatrix(predcodes = focalcodes, predcomb = predcomb, testcodes = focalcodes,testcomb = testcomb)
  return(pd)
}


#####**********************************************************************#####
##### METHODS #####

###### runpred #####

samplepoints<- function(pd,redo=T){UseMethod("samplepoints")}
samplepoints.pred <- function(pd, redo=T){ # the defaults go here

  if(redo==T){
  pd$trainsets<-list()
  pd$testsets<-list()
  }

# for(i in 1:nrow(pd$design) ){
#   traincode<-which(pd$focalcodes %in% pd$design[i , 1:length(pd$focalcodes)] )
#   tmp<-do.call(cbind,pd$possubsets[traincode])
#   tmp<-apply(tmp,1,function(x) sum(moiR::fn(x)) ==1)
#   pd$trainsets<-append(pd$trainsets, list(sample( which(tmp==TRUE), size=pd$nTraining) ) )
#
#   testcode<-which(pd$focalcodes %in% pd$design[i,- c(1:length(pd$focalcodes)) ] )
#   tmp<-do.call(cbind,pd$possubsets[testcode])
#   tmp<-apply(tmp,1,function(x) sum(moiR::fn(x)) ==1)
#   pd$testsets<-append(pd$testsets, list(sample( which(tmp==TRUE), size=pd$nTesting)) )
# }

for(i in 1:length(pd$focalcodes) ){
  message("sampling positions of environment: ", pd$focalcodes[i])


### version of training with chromosome 1 and testing in the rest
  if(!is.null(snps)){
    # tmp=list(sample(which(pd$possubsets[[i]] ==T & grepl("1_",snps)), size=pd$nTraining , # both environment and chr1
    #         prob = 1- rank( abs(pd$dat[,1])[which(pd$possubsets[[i]] ==T)] ) /
    #                 length(which(pd$possubsets[[i]] ==T))
    #                 ))
    tmp=list(sample(which(pd$possubsets[[i]] ==T & grepl("1_",snps)) , size=pd$nTraining ))
    names(tmp)<- pd$focalcodes[i]
    pd$trainsets <- append(pd$trainsets,tmp)

    tmp=list(sample(which(pd$possubsets[[i]] ==T & !grepl("1_",snps)) , size=pd$nTesting ))
    names(tmp)<- pd$focalcodes[i]
    pd$testsets <- append(pd$testsets,tmp)

  }else{

    # tmp=list(sample(which(pd$possubsets[[i]] ==T) , size=pd$nTraining , # with probabilities given rank, not necessary
    #   prob = 1- rank( abs(pd$dat[,1])[which(pd$possubsets[[i]] ==T)] ) /
    #         length(which(pd$possubsets[[i]] ==T))
    #         ))
    tmp=list(sample(which(pd$possubsets[[i]] ==T) , size=pd$nTraining ))
    names(tmp)<- pd$focalcodes[i]
    pd$trainsets <- append(pd$trainsets,tmp)

    tmp=list(sample(which(pd$possubsets[[i]] ==T) , size=pd$nTesting ))
    names(tmp)<- pd$focalcodes[i]
    pd$testsets <- append(pd$testsets,tmp)
  }
}


return(pd)
}
#----------------------------------

predtrain <- function(pd,parallel,cores,whichanalyses){UseMethod("predtrain")}
predtrain.pred <- function(pd,parallel=T,cores=NULL, whichanalyses=1:nrow(pd$design)){ # the defaults go here
require(randomForest)
pd$whichanalyses<-whichanalyses
message("training ", length(whichanalyses)," models ...")
if(parallel==TRUE){
pd$traincommand='randomForest( y= bdat[TRAINING,1], x= bdat[TRAINING,-1])'
pd$bdatdesc<-describe(pd$dat)
cl<-startcluster(cores)#<- start cluster
    clusterExport(cl=cl, list("pd","randomForest",'lm',"attach.resource"),envir=environment())
    pd$mods<-parLapply(cl,whichanalyses, function(i){
                            print(paste("training design: ",i))
                            traincode<-which(pd$focalcodes %in% pd$design[i , 1:length(pd$focalcodes)] )
                            TRAINING<- moiR::fn(sample(unlist(pd$trainsets[traincode]), size=pd$nTraining))
                            bdat<-attach.resource(pd$bdatdesc)
                            mod<- eval(parse(text= pd$traincommand))
                            return(mod)
                    })
stopCluster(cl) #<- stop cluster

}else{
pd$traincommand='randomForest( y= pd$dat[TRAINING,1], x= pd$dat[TRAINING,-1])'

  pd$mods<-lapply(whichanalyses, function(i){
                            print(paste("training design: ",i))
                            traincode<-which(pd$focalcodes %in% pd$design[i , 1:length(pd$focalcodes)] )
                            TRAINING<- moiR::fn(sample(unlist(pd$trainsets[traincode]), size=pd$nTraining))
                            # mod<- randomForest( y= pd$dat[TRAINING,1], x= pd$dat[TRAINING,-1])
                            mod<- eval(parse(text= pd$traincommand))
                    return(mod)
                })
}


 message('...done')

  return(pd)
}



#---------------------------------- test

test <- function(pd,parallel,cores,whichanalyses,bootsize){ UseMethod("test") }
test.pred <- function(pd,parallel=T,cores=NULL,whichanalyses=pd$whichanalyses, bootsize=100){ # the defaults go here
message("testing ", length(whichanalyses)," models ...")
if(pd$nTesting/bootsize <= 10){
  stop('Errors might occurr because testsize/bootsize is equal or lower than 10')
}
pd$bootsize=bootsize

  if(parallel==TRUE){
  pd$testcommand='randomForest:::predict.randomForest(pd$mods[[i]],bdat[TESTING,-1])'

  pd$bdatdesc<-describe(pd$dat)
  cl<-startcluster(cores)#<- start cluster
  clusterExport(cl=cl, list("pd","attach.resource",'bootsize'),envir=environment())

    pd$results<-parLapply(cl,whichanalyses,
        function(i){
        res<-lapply(1:bootsize, function(z){
              testcode<-which(pd$focalcodes %in% pd$design[i ,-c(1:length(pd$focalcodes))] )
              TESTING<- moiR::fn(sample(unlist(pd$testsets[testcode]), size=pd$nTesting / bootsize))
              bdat<-attach.resource(pd$bdatdesc)
              predicted<-eval(parse(text=pd$testcommand))
              real<-bdat[TESTING,1]

              mod<-cor.test(predicted,real, method='pearson')
              lmmod<-lm(real ~ predicted)
              return(list(
                          mod$estimate,
                          summary(lmmod)$r.squared
                          ))
              # rs[z] <- mod$estimate
              # rsquared<-summary(lm(real ~ predicted))$r.squared
          })
          res<-do.call(rbind,res)
          res<-apply(res,2,moiR::fn)

          r_mean<-mean(res[,1])
          r_high<-quantile(res[,1], prob=(0.975))
          r_low<-quantile(res[,1], prob=(0.025))
          rsquared_mean<-mean(res[,2])
          rsquared_high<-quantile(res[,2], prob=(0.975))
          rsquared_low<-quantile(res[,2], prob=(0.025))
      return(list(r=r_mean,
                  lowci=r_low,
                  uppci=r_high,
                  rsquared=rsquared_mean,
                  rsquared_low=rsquared_low,
                  rsquared_high=rsquared_high))
    }
  )


stopCluster(cl) #<- stop cluster

}else{
  pd$testcommand='randomForest:::predict.randomForest(pd$mods[[i]],pd$dat[TESTING,-1])'

  pd$results<-
  # debug<-
    lapply(whichanalyses, function(i){

    # rs<-c()
    # rsquared<-c()
    message("starting bootstrapping for analysis: ",i)
    # for(z in 1:100){
    #
    #   testcode<-which(pd$focalcodes %in% pd$design[i ,-c(1:length(pd$focalcodes))] )
    #   TESTING<- moiR::fn(sample(unlist(pd$testsets[testcode]), size=pd$nTesting / 100))
    #   # predicted<-randomForest:::predict.randomForest(pd$mods[[i]],pd$dat[TESTING,-1])
    #   predicted<-eval(parse(text=pd$testcommand))
    #   real<-pd$dat[TESTING,1]
    #
    #   mod<-cor.test(predicted,real, method='pearson')
    #   # r_mean<-mod$estimate
    #   # r_low<-mod$conf.int[1]
    #   # r_high<-mod$conf.int[2]
    #   rs[z] <- mod$estimate
    #   rsquared<-summary(lm(real ~ predicted))$r.squared
    # }

    # r_mean<-mean(rs)
    # r_high<-quantile(rs, prob=(0.975))
    # r_low<-quantile(rs, prob=(0.025))
    # rsquared_mean<-mean(rsquared)
    # rsquared_low<-quantile(rsquared, prob=(0.975))
    # rsquared_high<-quantile(rsquared, prob=(0.975))

     res<-lapply(1:bootsize, function(z){
        testcode<-which(pd$focalcodes %in% pd$design[i ,-c(1:length(pd$focalcodes))] )
        TESTING<- moiR::fn(sample(unlist(pd$testsets[testcode]), size=pd$nTesting / bootsize))
        predicted<-eval(parse(text=pd$testcommand))
        real<-pd$dat[TESTING,1]

        mod<-cor.test(predicted,real, method='pearson')
        return(list(
                    mod$estimate,
                    summary(lm(real ~ predicted))$r.squared
                    ))
        # rs[z] <- mod$estimate
        # rsquared<-summary(lm(real ~ predicted))$r.squared
    })
    res<-do.call(rbind,res)
    res<-apply(res,2,moiR::fn)

    r_mean<-mean(res[,1])
    r_high<-quantile(res[,1], prob=(0.975))
    r_low<-quantile(res[,1], prob=(0.025))
    rsquared_mean<-mean(res[,2])
    rsquared_low<-quantile(res[,2], prob=(0.025))
    rsquared_high<-quantile(res[,2], prob=(0.975))


      return(list(r=r_mean,
                  lowci=r_low,
                  uppci=r_high,
                  rsquared=rsquared_mean,
                  rsquared_low=rsquared_low,
                  rsquared_high=rsquared_high))
  })
}

  # Parse results for nice display
  pd<-printr(pd)

  return(pd)
}

printmods <- function(pd,whichanalyses){UseMethod("printmods")}
printmods.pred <-function(pd){
  stopifnot(!is.null(pd$mods))
  lapply(1:length(pd$mods), function(i) randomForest:::print.randomForest(pd$mods[[i]]))
}


printr <- function(pd,whichanalyses){UseMethod("printr")}
printr.pred <-function(pd,whichanalyses=pd$whichanalyses){
  pd$printresults<-lapply(whichanalyses, function(i){
    x<-pd$results[[i]]
    x<-format(x,digits=3)
    x_<-paste('r=',x[[1]], ', CI=',paste(x[2:3],collapse='  '), ', R2=',x[4],', CI=',paste(x[5:6],collapse='  ') )
    return(x_)
  })
  return(pd)
}


print <- function(pd){UseMethod("print")}
print.pred <-function(pd){
cat( c('predictors', 'testers','result') , sep= '\t')

if(length(pd$printresults) !=0)  {
  cat('\n')
  lapply(pd$whichanalyses, function(i){
    predictors<-paste(na.omit(pd$design[i,1:length(pd$focalcodes)]), collapse='+')
    testers<-paste(na.omit(pd$design[i,-c(1:length(pd$focalcodes))]), collapse='+')
    result<-pd$printresults[[i]]

    cat( c(predictors, testers,result) ,sep= '\t')
    cat('\n')
  })
}else{
  cat( '\n')
  cat( '... No results ... ')
  cat( '\n')
}

}

writetable <- function(pd,path,name){UseMethod("writetable")}
writetable.pred <-function(pd, path='tables',name=""){

  # pd$towrite<-
  # lapply(1:nrow(pd$design), function(i){
  #   predictors<-paste(na.omit(pd$design[i,1:length(pd$focalcodes)]), collapse='+')
  #   testers<-paste(na.omit(pd$design[i,-c(1:length(pd$focalcodes))]), collapse='+')
  #   result<-pd$printresults[[i]]
  #
  #   c(predictors, testers,result)
  #  }) %>% do.call(rbind)

  # write.tsv(pd$towrite, file=paste(path,'/', paste0('predictablity-gwaclim-extraenv-', fvar,"_","_ntrain",pd$nTraining,"_ntest",pd$nTesting,'.tsv')) )

  sink(file=paste0(path,'/', paste0(name,'predictablity-gwaclim-extraenv-', fvar,"_","_ntrain",pd$nTraining,"_ntest",pd$nTesting,gsub(" ","__",Sys.time()),'.tsv')) )
  print(pd)
  cat('------------------'); cat( '\n')
  cat(paste('Fitness_var=',fvar)); cat( '\n')
  cat(paste('Training_n=',pd$nTraining)); cat( '\n')
  cat(paste('Testing_n=',pd$nTesting)); cat( '\n')
  sink()

}

#### get the model given environment ####

givemod <- function(pd){UseMethod("givemod")}
givemod.pred <-function(pd, codes=pd$focalcodes){
  # modelwenviron<-apply(pd$design[,1:length(pd$focalcodes)], 1, function(x) all(x %in% codes)) %>% head(1)
  numenv<-apply(pd$design[,1:length(pd$focalcodes)], 1, function(x) length(na.omit(x)) )
  modelwenviron<-which(numenv==max(numenv) )%>% head(1)
  return(pd$mods[[modelwenviron]])
}

#### plotting functions ####


plot <- function(pd,what,save,name){UseMethod("plot")}

plot.pred <-function(pd, what='r',save=T,name=''){

stopifnot(what %in% c('r','R2'))




predmat<-lapply(1:nrow(pd$design), function(i){
                        tmp<-matrix(NA,nrow=1, ncol=length(pd$focalcodes))
                        whichones<-which(pd$focalcodes %in% pd$design[i,c(1:length(pd$focalcodes)) ])
                        tmp[whichones]<-whichones
                        return(tmp)
                      }) %>% do.call(rbind,.)

testmat<-lapply(1:nrow(pd$design), function(i){
                        tmp<-matrix(NA,nrow=1, ncol=length(pd$focalcodes))
                        whichones<-which(pd$focalcodes %in% pd$design[i,-c(1:length(pd$focalcodes)) ])
                        tmp[whichones]<-whichones
                        return(tmp)
                      }) %>% do.call(rbind,.)

resu<-data.frame(do.call(rbind,pd$results))
resu<-data.frame(apply(resu,2,moiR::fn))
resu$analysis<-1:nrow(resu)
# resu<-dplyr::arrange(resu,r)
resu$y<-1:nrow(resu)

predmat<-predmat[resu$analysis,]
testmat<-testmat[resu$analysis,]


if(what=='r'){
pres<-ggplot(resu) +
  geom_segment(aes(y=ifelse(min(resu)>0,0,min(resu)) ,yend=+1,x=y,xend=y),col=transparent('grey70'))+
  geom_segment( aes(y = lowci, yend = uppci, x=y,xend=y))  +
  geom_point(aes(y=r,x=y)) +
  geom_segment(aes(x=-Inf,xend=Inf,y=0,yend=0),col=transparent('black',0.2), lty='dashed',lwd=0.5)+
  theme(axis.line.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        plot.margin = unit(c(0, 0, 0, 0), "cm"),
        panel.grid.minor.x = element_line(colour = "white", size = 0.5)
  )+
  # ylim(min(resu),+1)+
  scale_y_continuous(breaks = seq(-0.75,+1,by=0.25))+
  ylab('Predictive correlation (r)')+
  xlab('')
# pres
# dev.off()
bottom<-ifelse(min(resu)>0,0,min(resu))
toplot_p<- data.frame(analysis= moiR::fn(row(predmat)), predictors= moiR::fn(predmat))
toplot_p$y<- seq(bottom-1.1,bottom-0.7,length.out = max(toplot_p$predictors, na.rm = T))[toplot_p$predictors]

toplot_t<- data.frame(analysis= moiR::fn(row(testmat)), testors= moiR::fn(testmat))
toplot_t$y<- seq(bottom-0.5,bottom-0.1,length.out = max(toplot_t$testors, na.rm = T))[toplot_t$testors]
}else{
  pres<-ggplot(resu) +
  geom_segment(aes(y=ifelse(min(resu)>0,0,min(resu)) ,yend=+1,x=y,xend=y),col=transparent('grey70'))+
  geom_segment( aes(y = rsquared_low , yend = rsquared_high, x=y,xend=y))  +
  geom_point(aes(y=rsquared,x=y)) +
  geom_segment(aes(x=-Inf,xend=Inf,y=0,yend=0),col=transparent('black',0.2), lty='dashed',lwd=0.5)+
  theme(axis.line.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        plot.margin = unit(c(0, 0, 0, 0), "cm"),
        panel.grid.minor.x = element_line(colour = "white", size = 0.5)
  )+
  scale_y_continuous(breaks = seq(0,+1,by=0.25))+
  ylab(TeX('Predictive variance explained ($R^2$)'))+
  xlab('')
# pres
# dev.off()

bottom<-0

toplot_p<- data.frame(analysis= moiR::fn(row(predmat)), predictors= moiR::fn(predmat))
toplot_p$y<- seq(bottom-1.1,bottom-0.7,length.out = max(toplot_p$predictors, na.rm = T))[toplot_p$predictors]

toplot_t<- data.frame(analysis= moiR::fn(row(testmat)), testors= moiR::fn(testmat))
toplot_t$y<- seq(bottom-0.5,bottom-0.1,length.out = max(toplot_t$testors, na.rm = T))[toplot_t$testors]
}


pfinal<-
      pres +
        geom_tile(data=toplot_p,aes(x=analysis,y=y, fill=factor(predictors))) +
        geom_tile(data=toplot_t,aes(x=analysis,y=y, fill=factor(testors))) +
        scale_fill_brewer("",palette = 'Pastel2',
                          # na.value='grey',
                          labels=pd$focalcodes[1:max(toplot_t$testors, na.rm = T)] )


# pfinal

# toplot_p<- data.frame(analysis= moiR::fn(row(predmat)), predictors= moiR::fn(predmat))
# plotpreds<-ggplot(toplot_p) +
#   geom_tile(aes(x=analysis,y=predictors, fill=factor(predictors))) +
#   theme(
#        axis.line=element_blank(),
#        legend.position="none",
#         axis.text.y=element_blank(),
#         axis.text.x=element_blank(),
#         axis.ticks=element_blank(),
#        plot.margin = unit(c(0, 0, 0, 0), "cm"),
#       panel.grid.minor.y = element_line(colour = "white", size = 0.5)
#       )+
#       # scale_fill_manual(values = c('#e31a1c','#fb9a99','#a6cee3','#1f78b4'))+
#       # scale_fill_manual(values = c('#e31a1c','#1f78b4'))+
#       scale_fill_brewer(palette = 'Accent')+
#       xlab('')+ylab('')
#
# # plotpreds
# # dev.off()
#
# toplot_t<- data.frame(analysis= moiR::fn(row(testmat)), testors= moiR::fn(testmat))
# plottest<-ggplot(toplot_t) +
#   geom_tile(aes(x=analysis,y=testors,fill=factor(testors))) +
#   theme(
#       axis.line=element_blank(),
#       legend.position="none",
#       axis.text.y=element_blank(),
#       axis.text.x=element_blank(),
#       axis.ticks=element_blank(),
#       plot.margin = unit(c(0, 0, 0, 0), "cm"),
#       panel.grid.minor.y = element_line(colour = "white", size = 0.5)
#       )+
#       scale_fill_brewer(palette='Accent')    +
#     # scale_fill_manual(values = c('#e31a1c','#fb9a99','#a6cee3','#1f78b4'))+
#       # scale_fill_manual(values = c('#e31a1c','#1f78b4'))+
#       xlab('')+ylab('')

# plottest
# dev.off()

# pfinal<-plot_grid(plotlist =
#                   list(pres,plottest, plotpreds),
#                   ncol=1,
#                   rel_heights = c(0.8,0.1,0.1),
#                   align='h')
# pfinal
# dev.off()

# save_plot(plot=pfinal,file='Rplot.pdf',base_width=0.2, base_height = 0.2,ncol = length(pd$focalcodes)*12, nrow=nrow(pd$design) )

pd$plot<-pfinal

if(save==T){
  save_plot(plot=pd$plot,
            file=paste0('figs/',name,'predictablity-',what,'-gwaclim-extraenv-', fvar,"_",pd$method,"_",'ALL',"_ntrain",pd$nTraining,"_ntest",pd$nTesting,gsub(" ","__",Sys.time()),'.pdf'),
            # base_width=0.1, base_height = 5,
            # nrow = 1, ncol=nrow(pd$design) ,
            base_width=5, base_height = 5,
            useDingbats=F)
}

print(pd$plot)
return(pd)
}


#####**********************************************************************#####

# regularsamplingprob<-function(dat,nbreaks=100){
#   toycut<-cut(dat, breaks = nbreaks) %>% as.numeric()
#   toycut<-factor(toycut,levels =1:nbreaks )
#
#   # probsample<- 1-(table(toycut) / length(dat) )
#   probsample<- 1-normalize(table(toycut) )
#
#   toycutprob<- fn(probsample)[fn(toycut)]
#
#   toycutprob<-normalize(toycutprob)
#   return(toycutprob)
# }
#
#
#
# predicted2real<-function(mod, testset, dat=m2, reponsecol='effect',colset=c(biocols, ancols, metricscols), type='lm'){
#
#   stopifnot(type %in% c('lm','r'))
#
#   predicted<-predict(mod,dat[testset,colset])
#   real<-dat[testset,reponsecol]
#
#   if(type=='lm'){
#     return(moiR::lm_eq( predicted, real,tex = F) )
#   }else if(type=='r'){
#     return(moiR::r2_eq( predicted, real,tex = F) )
#   }
#
# }

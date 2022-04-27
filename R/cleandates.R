cleandates<-function(mydate){
  newdate<-paste0(substr(mydate,1,4), "-",
         substr(mydate,5,6), "-",
         substr(mydate,7,8)
  )
 return(as.Date(newdate))
}

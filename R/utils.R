#' Title
#'
#' @param libnames
#'
#' @return
#' @export
#'
#' @examples
cleansampleid<-function(libnames=c("MLFH130320180405","MLFH13_1_20190122")){
  mytmp<-tempfile(pattern = "file", tmpdir = tempdir(), fileext = "")
  write.table(file = mytmp, x=libnames,quote = F,row.names = F,col.names = F)
  mytmp2<-tempfile(pattern = "file", tmpdir = tempdir(), fileext = "")
  system(paste('../data-raw/homogenizesampleID.sh', mytmp, mytmp2))
  cleanid<-read.table(mytmp2,stringsAsFactors = F,header = F)$V1
  return(cleanid)
}
# echo "ML-FH-1-2-20200101" | sed "s/-\([0-9]\)-/-0\1-/g" | sed "s/-\([0-9]\)-/-0\1-/g" | sed "s/-//g"
#' Title
#'
#' @param idlist
#' @param var
#'
#' @return
#' @export
#'
#' @examples
parseid<-function(idlist=c("MLFH130120190107","MLFH130120190107"),var='site'){
  stopifnot(var %in% c('site',"plot",'year','month',"day","date"))
  if(var =='site'){
    sapply(idlist,function(x) substr(x,5,6))
  }else if(var=='plot'){
    sapply(idlist,function(x) substr(x,7,8))
  }else if(var=='year'){
    sapply(idlist,function(x) substr(x,9,12))
  }else if(var=='month'){
    sapply(idlist,function(x) substr(x,13,14))
  }else if(var=='day'){
    sapply(idlist,function(x) substr(x,15,16))
  }else if(var=='date'){
    sapply(idlist,function(x) substr(x,9,16))
  }
}
#' Title
#'
#' @param x
#'
#' @return
#' @export
#'
#' @examples
addparsedidcolumns<-function(x){
  stopifnot("id" %in% colnames(x))
  x$site<-parseid(x$id,"site")
  x$plot<-parseid(x$id,"plot")
  x$year<-parseid(x$id,"year")
  x$month<-parseid(x$id,"month")
  x$day<-parseid(x$id,"day")
  x$date<-parseid(x$id,"date")
  return(x)
}
#' Title
#'
#' @param x
#'
#' @return
#' @export
#'
#' @examples
doy<-function(x=c("20190122","20190122")){
  as.Date(x, format="%Y%m%d")-as.Date(paste0(substr(x,0,4),"0101"),format="%Y%m%d")
}


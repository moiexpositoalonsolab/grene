#' Clean dates
#'
#' Takes the format yyyymmdd used in most of the samples id to convert it into an R readable date format
#' @param mydate string(8) in the formar yyyymmdd
#'
#' @return date in r format
#' @export
#'
#' @examples
cleandates<-function(mydate){
  newdate<-paste0(substr(mydate,1,4), "-",
                  substr(mydate,5,6), "-",
                  substr(mydate,7,8)
  )
 return(as.Date(newdate))
}




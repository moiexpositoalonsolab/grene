#' @param folder
#'
#' @export
Arabidopsis_thalina_world_accessions_list=function(folder="data/"){

thefile="Arabidopsis_thaliana_world_accessions_list.tsv"
pathtoit=paste(folder,thefile,sep="/")

Ath=read.table(pathtoit,header=T,fill=T,stringsAsFactors = F)

}
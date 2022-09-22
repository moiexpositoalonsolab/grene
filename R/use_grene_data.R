# custom use_data
use_grene_data <- function(xx) {
    filename = deparse(substitute(xx))
    write.csv(xx, file = paste0('./data/',filename,'.csv'), quote = TRUE, row.names = FALSE)
    save(xx, file = paste0('./data/',filename,'.rda'))
    return(invisible())
}

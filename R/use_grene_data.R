# custom use_data
use_grene_data <- function(xx) {
    filename = deparse(substitute(xx))
    write.csv(xx, file = paste0('./data/',filename,'.csv'), quote = TRUE, row.names = FALSE)
    assign(filename,xx) # assign xx's content to an object named filename.
    save(list = filename, file = paste0('./data/',filename,'.rda'))
    return(invisible())
}

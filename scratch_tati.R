#pip3 install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib
#install.packages("reticulate")
system('ls')
## in case you need to install a python library
## module load Conda/3.7
## conda activate grenenet_phase1

library(devtools)

devtools::document()
load_all()



library(reticulate)
use_virtualenv("grenenet_phase1")
source_python("data-raw/python_scripts/list_new_data_files.py")
source_python("data-raw/python_scripts/census_samples_download.py")
source_python("data-raw/python_scripts/records_sorted_download.py")


library(readxl)
path <- "data-raw/census_samples.xlsx"
excel_sheets(path = path)

# then you copypaste the one you want and run this function
set_lib_paths <- function(lib_vec) {
  lib_vec <- normalizePath(lib_vec, mustWork = TRUE)
  shim_fun <- .libPaths
  shim_env <- new.env(parent = environment(shim_fun))
  shim_env$.Library <- character()
  shim_env$.Library.site <- character()
  environment(shim_fun) <- shim_env
  shim_fun(lib_vec)
}
set_lib_paths("/home/tbellagio/R/x86_64-pc-linux-gnu-library/3.6")

library(dplyr)
library(tidyverse)
library(data.table)


library(devtools)

document()
data(seqtable)
records?

sensors<-list.files(path = "data-sensors")

sensors
#### import
#import data void first 15 rows about devide info
sensor1 = fread("data-sensors/02-12-40CADA21-20180716.csv",
      col.names = c('Time','Unit','Value','decimal'),
      #skip = 15,
      sep = ",")

sensor2 = fread("data-sensors/02-12-40CADA21-20180716.csv")


head(sensor2)
head(sensor1)

sensor3 = read.table("data-sensors/02-TH-H-20180716.csv",
                     header = FALSE,
                     sep = "",
                     skip = 20)
head(sensor3)

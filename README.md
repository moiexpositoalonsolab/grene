
# The GrENE-net evolution experiment 

To find more information, visit [grene-net.org](grene-net.org)
For comments or bugs, moisesexpositoalonso@gmail.com

This folder is an R package to contain all the meta data of the GrENE-net experiment, including sample names, information from participants, sample records from participants, environmental data, and scripts to manipulate and analyze genome sequences
To install the package, you can run:
./build.R
./install


The structure of folders is the following:

The key folders and files needed for the R package are:

-DESCRIPTION
-NAMESPACE
These two describe the package name and dependencies

-R/
All R functions that will be available and loaded. These functions will be accessible to call when the package is installed and loaded via library(grene) in any script
-man/ 
The manual of the package containing descriptions of functions and datasets.
-CPP/
C++ functions that can be accessible to be called from R if loaded via the Rcpp module or sourced via the function Rcpp::sourceCpp()

-data/
The data files that will be loaded together with the package when installed adnd loaded via library(grene). Datasets will be accessible in any script as data("nameofdataset")

-data-raw/
Datasets from this project in raw format which are parsed and then stored in data/
R scripts starting with gen_.R load those raw datasets, clean them, and store them in data/

-data-big-seeds
Sequencing dataset pointers to the Short Read Archive with results of a seed sequencing experiment. These seeds started GrENE-net
Intermediate files of those raw sequencing datasets can be stored here

-data-big-flowers-phase1
Sequencing dataset pointers to the Short Read Archive with results of flower sequencing over the years in different GrENE-net sites
Intermediate files of those can also be stored here

-data-sensors
The environmental sensors, which were read by participants every year and send to the organizers. All the iButton data is stored in the google drive folder:
https://drive.google.com/drive/folders/1-vtLaK1bdWlVSHAYC9cjfkzq06xNIeDi?usp=sharing

-data-worldclim
Datasets from worldclim.org which can be matched with the locations of GrENE-net to extract average climates at those locations


-analyses/
Folder containing R files to conduct analyses, make figures, and result tables

-figs/
Folder containing PDFs of result figures created with scripts in analyses/
-tables/
Folder containing .csv of result tables created with scripts in analyses/


<!-- README.md is generated from README.Rmd. Please edit that file -->

# grene

<!-- badges: start -->
<!-- badges: end -->

# The GrENE-net evolution experiment

For more information, visit [grene-net.org](grene-net.org). For comments or bugs, contact [moisesexpositoalonso@gmail.com](mailto:moisesexpositoalonso@gmail.com).

This folder hosts the R package for the GrENE-net experiment, encompassing all metadata, including sample names, participant information, sample records, environmental data, and scripts for genome sequence manipulation and analysis. To install the package, run: `./build.R` followed by `./install`.

## Folder Structure and Key Components

- **build.R**: Script for building the R package.
- **CPP/**: Directory possibly containing C++ source code.
- **data/**: The data files that will be loaded together with the package
when installed adnd loaded via library(grene). Datasets will be
accessible in any script as data(“nameofdataset”)
- **data-raw/**: Datasets from this project in raw format which are parsed
and then stored in data/ R scripts starting with gen\_.R load those raw
datasets, clean them, and store them in data/
- **DESCRIPTION**: Package metadata including name, version, and dependencies.
- **grene.Rproj**: RStudio project file.
- **gsod/**: Directory, potentially related to Global Surface Summary of the Day weather data.
- **install**: Script for installation.
- **LICENSE** & **LICENSE.md**: Licensing information for the project.
- **logs/**: Directory for log files.
- **man/**: Manual pages for the package's functions and datasets.
- **NAMESPACE**: Controls the export and import of functions in the package.
- **R/**: ll R functions that will be available and loaded. These functions
will be accessible to call when the package is installed and loaded via
library(grene) in any script -man/ The manual of the package containing
descriptions of functions and datasets. -CPP/ C++ functions that can be
accessible to be called from R if loaded via the Rcpp module or sourced
via the function Rcpp::sourceCpp()
- **README.md** & **README.Rmd**: Descriptive documentation for the project.
- **srtm/**: Directory, possibly related to Shuttle Radar Topography Mission data.
- **TODELETE/**: Directory marked for potential deletion.
- **wc2-0.5/**: Directory, speculated to contain climate or weather data.

## Installation

Install the development version from [GitHub](https://github.com/moiexpositoalonsolab/grene) with:

``` r
# install.packages("devtools")
devtools::install_github("moiexpositoalonsolab/grene")

## Example
``` r
#library(grene)
```


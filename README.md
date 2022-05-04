
<!-- README.md is generated from README.Rmd. Please edit that file -->

# grene

<!-- badges: start -->

<!-- badges: end -->

# The GrENE-net evolution experiment

To find more information, visit [grene-net.org](grene-net.org) For
comments or bugs, <moisesexpositoalonso@gmail.com>

This folder is an R package to contain all the meta data of the
GrENE-net experiment, including sample names, information from
participants, sample records from participants, environmental data, and
scripts to manipulate and analyze genome sequences To install the
package, you can run: ./build.R ./install

The structure of folders is the following:

The key folders and files needed for the R package are:

\-DESCRIPTION -NAMESPACE These two describe the package name and
dependencies

\-R/ All R functions that will be available and loaded. These functions
will be accessible to call when the package is installed and loaded via
library(grene) in any script -man/ The manual of the package containing
descriptions of functions and datasets. -CPP/ C++ functions that can be
accessible to be called from R if loaded via the Rcpp module or sourced
via the function Rcpp::sourceCpp()

\-data/ The data files that will be loaded together with the package
when installed adnd loaded via library(grene). Datasets will be
accessible in any script as data(“nameofdataset”)

\-data-raw/ Datasets from this project in raw format which are parsed
and then stored in data/ R scripts starting with gen\_.R load those raw
datasets, clean them, and store them in data/

\-data-big-seeds Sequencing dataset pointers to the Short Read Archive
with results of a seed sequencing experiment. These seeds started
GrENE-net Intermediate files of those raw sequencing datasets can be
stored here

\-data-big-flowers-phase1 Sequencing dataset pointers to the Short Read
Archive with results of flower sequencing over the years in different
GrENE-net sites Intermediate files of those can also be stored here

\-data-sensors The environmental sensors, which were read by
participants every year and send to the organizers. All the iButton data
is stored in the google drive folder:
<https://drive.google.com/drive/folders/1-vtLaK1bdWlVSHAYC9cjfkzq06xNIeDi?usp=sharing>

\-data-worldclim Datasets from worldclim.org which can be matched with
the locations of GrENE-net to extract average climates at those
locations

\-analyses/ Folder containing R files to conduct analyses, make figures,
and result tables

\-figs/ Folder containing PDFs of result figures created with scripts in
analyses/ -tables/ Folder containing .csv of result tables created with
scripts in analyses/

## Installation

You can install the development version of grene from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("moiexpositoalonsolab/grene")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
#library(grene)
## basic example code
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this. You could also
use GitHub Actions to re-render `README.Rmd` every time you push. An
example workflow can be found here:
<https://github.com/r-lib/actions/tree/v1/examples>.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.

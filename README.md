<!-- README.md is generated from README.Rmd. Please edit that file -->

# GrENE-net: Global Evolutionary Network Experiment

<!-- badges: start -->
<!-- badges: end -->

## Overview

GrENE-net (Global Evolutionary Network Experiment) is a collaborative research project studying plant evolution on a global scale. This R package contains the complete toolkit for managing and analyzing data from the GrENE-net experiment, including sample metadata, environmental data, and genomic analysis tools.

For more information, visit [grene-net.org](https://grene-net.org).

## Features

- Sample metadata management
- Environmental data processing
- Climate and geographical data integration

## Installation

### Prerequisites

- R (>= 3.5.0)
- devtools package

### Installing from GitHub

```r
# Install devtools if you haven't already
if (!require("devtools")) install.packages("devtools")

# Install GrENE-net package
devtools::install_github("moiexpositoalonsolab/grene")
```

Alternatively, you can install locally:

1. Clone the repository
2. Run `./build.R`
3. Execute `./install`

## Package Structure

### Core Directories

- **R/**: Core R functions for data analysis and manipulation
- **data/**: Processed datasets (accessible via `data("dataset_name")`), including:
  - Climate data: `bioclimvars_ecotypes_era5.csv`, `worldclim_sitesdata.csv`, `weatherstation_data.rda`
  - Sample data: `samples_data.csv`, `sbsamples_data.csv`, `seedbank_samples.csv`
  - Experimental data: `siliques_data.csv`, `census_data.csv`, `ecotypes_data.csv`
  - Location data: `locations_data.csv`, `sites.clim.csv`
  - Environmental data: `soilsamples_data.csv`, `temphum_ib_data.csv`
  - Sequencing data: `fastq_info.csv`
- **data-raw/**: Raw data files and processing scripts, containing:
  - Original experimental data: `SURVIVAL_total_flowers_collected.csv`, `samples_records.csv`
  - Location information: `locations_dataraw.csv`
  - Census data: `census_samples.xlsx`
  - Ecotype information: `ecotypes_seedmix.csv`, `accessions_1001g.csv`
  - Python scripts for data processing in `python_scripts/`
- **man/**: Package documentation and function references

### Additional Components

- **CPP/**: C++ source code for performance-critical operations
- **gsod/**: Global Surface Summary of Day weather data processing
- **srtm/**: Shuttle Radar Topography Mission data utilities
- **wc2-0.5/**: Climate data processing tools

## Usage

```r
# Load the package
library(grene)

# Access documentation
?grene

# Load included datasets
data("dataset_name")
```
We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## Support

For questions, bug reports, or feature requests:

- Open an issue on GitHub

## License

This project is licensed under [LICENSE.md](LICENSE.md)

## Citation

If you use GrENE-net in your research, please cite:

[Citation information to be added]

## Acknowledgments

Thanks to all contributors and participants in the GrENE-net experiment worldwide.

## Example
``` r
#library(grene)
```


#!/bin/bash
#
##SBATCH --job-name=download_GlobalSurfacesummaryOftheDay
#SBATCH --output=/Carnegie/DPB/Data/Shared/Labs/Moi/Everyone/ath_evo/grenephase1/logs/download_GlobalSurfacesummaryOftheDay.out.txt
#SBATCH --error=/Carnegie/DPB/Data/Shared/Labs/Moi/Everyone/ath_evo/grenephase1/logs/download_GlobalSurfacesummaryOftheDay.err.txt
#SBATCH --time=23:59:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=20G

# Title: download the newer worldclim2 data since the raster package only has the worldclim1 version
# Author: Meixi Lin
# Date: Fri Nov 18 10:42:08 2022
# Usage: sbatch download_GlobalSurfacesummaryOftheDay.sh

#######################################################################
# set up environment
set -eo pipefail

HOMEDIR="/Carnegie/DPB/Data/Shared/Labs/Moi/Everyone/ath_evo/grenephase1"
COMMITID=$(git --git-dir="${HOMEDIR}/.git" --work-tree="${HOMEDIR}/" rev-parse master)
echo -e "[$(date "+%Y-%m-%d %T")] JOB ID ${SLURM_JOBID}; GIT commit id ${COMMITID} ..."

cd ${HOMEDIR}/gsod
mkdir -p noaa-ftp/
cd noaa-ftp/
mkdir -p tarfiles/

#######################################################################
# download data
# links from https://www.ncei.noaa.gov/metadata/geoportal/rest/metadata/item/gov.noaa.ncdc:C00516/html#
for year in {2017..2021}; do
    echo $year
    mkdir -p $year
    cd $year
    wget -nv https://www.ncei.noaa.gov/data/global-summary-of-the-day/archive/${year}.tar.gz
    tar -xf ${year}.tar.gz
    rsync -a ${year}.tar.gz ../tarfiles/
    rm ${year}.tar.gz
    cd ..
done


#######################################################################
# get md5sum of data
cd tarfiles
md5sum *.tar.gz > noaa_gsod_targz.md5sum

echo -e "[$(date "+%Y-%m-%d %T")] JOB ID ${SLURM_JOBID} Done"







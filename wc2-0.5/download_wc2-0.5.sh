#!/bin/bash
#
##SBATCH --job-name=download_wc2-0.5
#SBATCH --output=/Carnegie/DPB/Data/Shared/Labs/Moi/Everyone/ath_evo/grenephase1/logs/download_wc2-0.5.out.txt
#SBATCH --error=/Carnegie/DPB/Data/Shared/Labs/Moi/Everyone/ath_evo/grenephase1/logs/download_wc2-0.5.err.txt
#SBATCH --time=23:59:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=20G

# Title: download the newer worldclim2 data since the raster package only has the worldclim1 version
# Author: Meixi Lin
# Date: Wed Nov 16 13:37:45 2022
# Usage: sbatch download_wc2-0.5.sh

#######################################################################
# set up environment
set -eo pipefail

HOMEDIR="/Carnegie/DPB/Data/Shared/Labs/Moi/Everyone/ath_evo/grenephase1"
COMMITID=$(git --git-dir="${HOMEDIR}/.git" --work-tree="${HOMEDIR}/" rev-parse master)
echo -e "[$(date "+%Y-%m-%d %T")] JOB ID ${SLURM_JOBID}; GIT commit id ${COMMITID} ..."

cd ${HOMEDIR}/wc2-0.5
mkdir -p geotiff/
cd geotiff/

#######################################################################
# download data
# links from https://www.worldclim.org/data/worldclim21.html

wget -nv https://geodata.ucdavis.edu/climate/worldclim/2_1/base/wc2.1_30s_bio.zip
wget -nv https://geodata.ucdavis.edu/climate/worldclim/2_1/base/wc2.1_30s_tmin.zip
wget -nv https://geodata.ucdavis.edu/climate/worldclim/2_1/base/wc2.1_30s_tmax.zip
wget -nv https://geodata.ucdavis.edu/climate/worldclim/2_1/base/wc2.1_30s_tavg.zip
wget -nv https://geodata.ucdavis.edu/climate/worldclim/2_1/base/wc2.1_30s_prec.zip
wget -nv https://geodata.ucdavis.edu/climate/worldclim/2_1/base/wc2.1_30s_srad.zip
wget -nv https://geodata.ucdavis.edu/climate/worldclim/2_1/base/wc2.1_30s_wind.zip
wget -nv https://geodata.ucdavis.edu/climate/worldclim/2_1/base/wc2.1_30s_vapr.zip

#######################################################################
# unzip data
# in this version of bash, unzip does not remove the files
unzip wc2.1_30s_bio.zip
unzip wc2.1_30s_tmin.zip
unzip wc2.1_30s_tmax.zip
unzip wc2.1_30s_tavg.zip
unzip wc2.1_30s_prec.zip
unzip wc2.1_30s_srad.zip
unzip wc2.1_30s_wind.zip
unzip wc2.1_30s_vapr.zip

#######################################################################
# get md5sum of data
md5sum *.zip > wc2.1_30s_zip.md5sum
md5sum *.tif > wc2.1_30s_tif.md5sum

echo -e "[$(date "+%Y-%m-%d %T")] JOB ID ${SLURM_JOBID} Done"







################################################################################
## Information on GRENE-net package /data-raw folder
################################################################################

## Re-generate records data from updated spreadsheets (online records participants entry their samples)
# This will combine the records
bash fix_records-columnspaces.sh GrENE-net_records_2017-2020-Samples_2020.csv
bash fix_records-columnspaces.sh GrENE-net_records_2017-2020-Samples_2019.csv
bash fix_records-columnspaces.sh GrENE-net_records_2017-2020-Samples_2018.csv
Rscript gen_samplerecordscombined.R

## Re-generate participants list with fixes
Rscript gen_participantdata.R


## Re-generate arabidopsis world accessions
Rscript gen_world_accessions.ids.R
Rscript gen_Ecotype_list.R




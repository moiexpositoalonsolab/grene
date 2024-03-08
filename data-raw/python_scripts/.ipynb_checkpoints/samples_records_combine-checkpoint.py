import pandas as pd
import numpy as np
import openpyxl
from datetime import datetime

records = pd.read_csv('../samples_sorted.csv')

samples_filename = '../census_samples.xlsx'

# Load census/samples spreadsheets
sheets = openpyxl.load_workbook(samples_filename).sheetnames

# Get only the sheets that are census data
samples_sheets = [sheet for sheet in sheets if "Samples" in sheet]

# Read each selected sheet into a DataFrame and store in a list
sheetlist_samples = [pd.read_excel(samples_filename, sheet_name=sheet, dtype={'SITE': str, 'PLOT': str}) for sheet in samples_sheets]

samples = pd.concat(sheetlist_samples, ignore_index=True)

########### samples data wrangling ###########

## keep only flower heads
samples = samples[samples['CODES']=='FH']

## if they are exactly the same including comments and everything they are indeed just duplciates
samples = samples.drop_duplicates()

# Function to convert date with multiple formats
def convert_date_with_multiple_formats(date_str):
    formats = ['%Y-%m-%d', '%Y%m%d']  # List of formats to try
    for fmt in formats:
        try:
            return pd.to_datetime(date_str, format=fmt)
        except ValueError:
            continue
    print(date_str)
    return pd.NaT  # Return Not a Time for unconvertible formats

samples['site'] = samples['SITE'].astype(float).astype(int)

## because site 57 was doing other experiments thye added a g to the plot number but it means grenent so it is safe to just delete it 
samples['PLOT'] = samples['PLOT'].str.replace('G', '')

##this is a particualr plot from site 57 not grenent related 
samples = samples.drop(samples[samples['PLOT']=='14V'].index)

## this are trasnplant experiments eliminate 
samples = samples.drop(samples[samples['PLOT']=='from the local population around 30 m from the plots'].index)

samples = samples.drop(samples[samples['PLOT']=='from the local population from immediate vicinity of the plots'].index)

## this are just empty 
samples = samples.drop(samples[samples['PLOT'].isna()].index)

samples['plot'] = samples['PLOT'].astype(float).astype(int)

## there is no date but there is date in the sampleid 

samples.loc[(samples['site'] == 43)  & (samples['DATE'].isna()), 'DATE'] = samples[(samples['site'] == 43)  & (samples['DATE'].isna())]['SAMPLE_ID'].str.split('-').str[-1]

## the date is in an unreadable fromat convert it into just a string
samples['date'] = samples['DATE'].astype(str).str.replace('\.0$', '', regex=True)

## these samples state 2012 but based on when they were uploaded to the spreasheet they seem to be 2002, also there
## is a gap on the diary so cant confirm 
samples.loc[(samples['site']==57)  & (samples['date'].str[:4] == '2012'), 'date'] = ['20200204', '20200305', '20200305', '20200305', '20200305']

## from the diaires this is wrong 
samples.loc[(samples['site']==57)  & (samples['date'] == '20180116') & (samples['SAMPLE_ID'].str.contains('20180129')),'date' ] = '20190129'


## from the diaires this is wrong this are all 2019
samples.loc[(samples['site']==57)  & (samples['date'] == '20180116'), 'date']= '20190116'



## convert date to redable format 
samples['date'] = samples['date'].apply(convert_date_with_multiple_formats)

## DROP THIS SINGLE NAN that it actually doesnt have any info 
samples = samples.drop(samples[samples['date'].isna()].index)

# create sampleid
samples['sampleid'] = samples.apply(lambda row: 'ML' + row['CODES'] + str(row['site']).zfill(2) + str(row['plot']).zfill(2) + row['date'].strftime('%Y%m%d'), axis=1)

samples['SAMPLE_ID'] = samples['SAMPLE_ID'].fillna('no_data')

## this are flowers samples out the plot, eliminate 
samples = samples.drop(samples[samples['SAMPLE_ID'].str.contains('.out')].index)

# this is a duplciated that was misspeleed 
samples = samples.drop(samples[samples['SAMPLE_ID'] == 'FH-01-01-20190401'].index)

## safe to felete this 2 they are replicates 
samples = samples.drop(samples[samples['COMMENTS1'] == 'Helpers were not instructed to stop at 100 FHs but they informed me there were not many more than 100'].index)

## safe to delete these are duplciates 
samples = samples.drop(samples[samples['sampleid'].isin(['MLFH450620190131', 'MLFH450120190131']) & (samples['COMMENTS1'] == 'In URJC freezer' )].index)

## safe to delete all duplicates 
samples = samples.drop(samples[samples['COMMENTS1'] == 'Second generation. URJC freezer'].index)

## mistake when joining the columns, safe to delete 
samples = samples.drop(samples[(samples['sampleid'] == 'MLFH520120190402') & (samples['SAMPLE_ID']=='FH-52_1_20190322')].index)
samples = samples.drop(samples[(samples['sampleid'] == 'MLFH520120190322') & (samples['COMMENTS2']=='samples sent to Niek: 26.6.2019')].index)

## safe to delete these, thery are all form site 52 and duplciates based on a difference on the comments 2 
to_keep = samples.drop('COMMENTS2',axis=1).drop_duplicates().index

samples = samples.loc[to_keep,:]

## all duplicates 
samples = samples.drop(samples[(samples['sampleid'].isin(['MLFH520420190322','MLFH520520190322','MLFH520620190322','MLFH520720190322',
 'MLFH520820190322','MLFH520920190322','MLFH521020190322','MLFH521120190322','MLFH521220190322','MLFH520420190322',
'MLFH520520190322','MLFH520620190322','MLFH520720190322','MLFH520820190322',
 'MLFH520920190322','MLFH521020190322','MLFH521120190322','MLFH521220190322'])) 
        & (samples['COMMENTS2'] == 'samples sent to Niek: 26.6.2019')].index)

## corrected, the SAMPLEid was right, cehcked with diary 
samples.loc[(samples['sampleid'] == 'MLFH570320180116') & (samples['SAMPLE_ID'] == 'FH-57-3G-20180129'), 'date'] = pd.to_datetime('2018-01-29')

samples.loc[(samples['sampleid'] == 'MLFH570320180116') & (samples['SAMPLE_ID'] == 'FH-57-3G-20180129'), 'sampleid'] = 'MLFH570320180129'

samples.loc[(samples['sampleid'] == 'MLFH570120180116') & (samples['SAMPLE_ID'] == 'FH-57-1G-20180129'), 'date'] = pd.to_datetime('2018-01-29')

samples.loc[(samples['sampleid'] == 'MLFH570120180116') & (samples['SAMPLE_ID'] == 'FH-57-1G-20180129'), 'sampleid'] = 'MLFH570120180129'


## now all comments were read and take into consideration 

## flowers raken oout of the plot
samples = samples.drop(samples[samples['COMMENTS1'] == '12 flower sampled OUT of the plot (identified as "5.OUT")'].index)

## i will delete them since not sure if i should compelte with 0 flowers
samples = samples.drop(samples[(samples['NUMBER_FLOWERS_COLLECTED'].isna()) & (samples['site']==60) ].index)

## based on what i observed in the dairies and sheet i would assume these are just 0 flowers 
samples.loc[samples['NUMBER_FLOWERS_COLLECTED'].isna(), 'COMMENTS1'] = 'added 0 flowers. Tati B.' 
samples.loc[samples['NUMBER_FLOWERS_COLLECTED'].isna(), 'NUMBER_FLOWERS_COLLECTED'] = 0

## added this data to the survival spreadsheet but for now delete for the number of flowers 
samples = samples.drop(samples[samples['NUMBER_FLOWERS_COLLECTED']=='Tray lost, unknown cause'].index)

## one instance no data
samples = samples.drop(samples[samples['NUMBER_FLOWERS_COLLECTED']=='?'].index)

## based on what I observe in the spreadsheets i will assume these are 0
samples.loc[samples['NUMBER_FLOWERS_COLLECTED']=='na', 'COMMENTS1'] = 'added 0 flowers. Tati B.' 
samples.loc[samples['NUMBER_FLOWERS_COLLECTED']=='na', 'NUMBER_FLOWERS_COLLECTED'] = 0

samples['NUMBER_FLOWERS_COLLECTED'] = samples['NUMBER_FLOWERS_COLLECTED'].astype(int)

# collect year, month and day
samples['year'] = samples['date'].dt.year
samples['month'] = samples['date'].dt.month
samples['day'] = samples['date'].dt.day

samples = samples.drop(['CODES','SITE', 'PLOT', 'DATE', 'SAMPLE_ID', 'COMMENTS1', 'COMMENTS2', 'COMMENTS3' ],axis=1)

########### records data wrangling ###########

records['sampleid'] = 'ML' + records['SAMPLE_ID'].str.replace('-', '')

## because my goal is to just count flowers i will sum the replicates and ignore them for now 

replicates = records[records['REPLICATES']=='B']['sampleid'].values

replicates_simplified = records[records['sampleid'].isin(replicates)].groupby(['sampleid','CODES', 'SITE', 'PLOT','DATE','SAMPLE_ID'])['NUMBER_FLOWERS_COLLECTED'].sum().reset_index()

records = records.drop(records[records['sampleid'].isin(replicates)].index)

records = pd.concat([records, replicates_simplified], axis=0)

records = records.drop('REPLICATES',axis=1).reset_index()

# select only relevant columns
records = records[[ 'SITE', 'PLOT', 'DATE', 'NUMBER_FLOWERS_COLLECTED', 'TO_SKIP', 'sampleid']]

records['DATE'] = pd.to_datetime(records['DATE'], format= '%Y%m%d')

##rename columns
records.columns = [ 'site', 'plot', 'date', 'NUMBER_FLOWERS_COLLECTED', 'to_skip', 'sampleid']

## create year column
records['year'] = records['date'].dt.year

# merge samples and records to start to check matches
# Merging with an indicator to identify the source of each row

merged_df = samples.merge(records, on=['site', 'plot', 'date', 'NUMBER_FLOWERS_COLLECTED', 'sampleid', 'year'], how='outer', indicator=True)

# Filtering to get rows that didn't match from 'samples'
unmatched_samples = merged_df[merged_df['_merge'] == 'left_only']
unmatched_records = merged_df[merged_df['_merge'] == 'right_only']
matched = merged_df[merged_df['_merge'] == 'both']

## unmatched_samples_2021_2022 will be taken as true since they all velong to samples (no sample was seq after 2020)
unmatched_samples_2021_2022 = unmatched_samples[unmatched_samples['year'].isin([2021,2022])]

unmatched_samples = unmatched_samples[~unmatched_samples['year'].isin([2021,2022])]

## if they matched in everything but in the number of flowers collected the records dataset will be accepted since ru counted them 

merged_df = unmatched_samples.drop([ 'to_skip', '_merge'],axis=1).merge(unmatched_records.drop(['month', 'day', '_merge'],axis=1), on = ['site', 'plot', 'date', 'sampleid', 'year'],  how='outer', indicator=True)

unmatched_samples = merged_df[merged_df['_merge'] == 'left_only']
unmatched_records = merged_df[merged_df['_merge'] == 'right_only']
matched_flowers = merged_df[merged_df['_merge'] == 'both']

matched_flowers = matched_flowers.drop('NUMBER_FLOWERS_COLLECTED_x',axis=1)
matched_flowers = matched_flowers.rename(columns= {'NUMBER_FLOWERS_COLLECTED_y': 'NUMBER_FLOWERS_COLLECTED'})

## all the unmatched smaples that flower count is 0 keepis and accept it as true since records dont have 0 because you can sequence 0 flowers

unmatched_samples_to_keep_0flowers = unmatched_samples[unmatched_samples['NUMBER_FLOWERS_COLLECTED_x']==0]

unmatched_samples_to_keep_0flowers = unmatched_samples_to_keep_0flowers.drop('NUMBER_FLOWERS_COLLECTED_y',axis=1)
unmatched_samples_to_keep_0flowers = unmatched_samples_to_keep_0flowers.rename(columns= {'NUMBER_FLOWERS_COLLECTED_x': 'NUMBER_FLOWERS_COLLECTED'})

unmatched_samples = unmatched_samples[unmatched_samples['NUMBER_FLOWERS_COLLECTED_x']!=0]

unmatched_samples.loc[unmatched_samples['sampleid']=='MLFH571020191029', 'NUMBER_FLOWERS_COLLECTED_x'] = 5
unmatched_samples.loc[unmatched_samples['sampleid']=='MLFH571220191029', 'NUMBER_FLOWERS_COLLECTED_x'] = 1

## all of these records I manually checked and based on diaries and logic of data entry they are wrong 
to_delete_records = ['MLFH130820190309', 'MLFH130720190309','MLFH101020200211', 'MLFH090520180418', 'MLFH090620180418', 'MLFH091220180531',
                      'MLFH090320180418', 'MLFH090420180418', 'MLFH491120180409', 'MLFH491220180409','MLFH570620191026', 'MLFH570720191026', 'MLFH571020191026', 'MLFH571220191026',
       'MLFH490920180409', 'MLFH491020180409', 'MLFH570320190223','MLFH570420191016', 'MLFH570620191016', 'MLFH570620191016', 'MLFH570720191016',
                     'MLFH571020191016', 'MLFH571220191016', 'MLFH571020191002']

unmatched_records = unmatched_records.drop(unmatched_records[unmatched_records['sampleid'].isin(to_delete_records)].index)

unmatched_samples = unmatched_samples.drop('NUMBER_FLOWERS_COLLECTED_y',axis=1)
unmatched_samples = unmatched_samples.rename(columns= {'NUMBER_FLOWERS_COLLECTED_x': 'NUMBER_FLOWERS_COLLECTED'})

unmatched_records = unmatched_records.drop('NUMBER_FLOWERS_COLLECTED_x',axis=1)
unmatched_records = unmatched_records.rename(columns= {'NUMBER_FLOWERS_COLLECTED_y': 'NUMBER_FLOWERS_COLLECTED'})

## where is the data coming from 
matched['source'] = 'samples_records'
unmatched_samples_2021_2022['source'] = 'samples'
matched_flowers['source'] = 'records'
unmatched_samples['source'] = 'samples'
unmatched_records['source'] = 'records'

## concat everything 

samples = pd.concat([matched.drop('_merge',axis=1),
           unmatched_samples_2021_2022.drop('_merge',axis=1),
          matched_flowers.drop('_merge',axis=1),
          unmatched_samples.drop('_merge',axis=1),
          unmatched_records.drop('_merge',axis=1)],axis=0)

## just in case convert to date time again
samples['date'] = samples['date'].apply(convert_date_with_multiple_formats)

# collect year, month and day
samples['year'] = samples['date'].dt.year
samples['month'] = samples['date'].dt.month
samples['day'] = samples['date'].dt.day

# Add annotations for generations, considering all experiments started in 2017
samples['generation'] = np.where(samples['month'] >= 10, 
                                      samples['year'] - 2017 + 1, 
                                      samples['year'] - 2017)

samples.loc[(samples['site'] == 57) & (samples['year'] == 2018) & (samples['month'] >= 3) & (samples['month'] <= 6), 'generation'] = 1
samples.loc[(samples['site'] == 57) & (samples['year'] == 2018) & (samples['month'] >= 9) & (samples['month'] <= 12), 'generation'] = 2
samples.loc[(samples['site'] == 57) & (samples['year'] == 2019) & (samples['month'] >= 1) & (samples['month'] <= 6), 'generation'] = 3
samples.loc[(samples['site'] == 57) & (samples['year'] == 2019) & (samples['month'] >= 7) & (samples['month'] <=11), 'generation'] = 4
samples.loc[(samples['site'] == 57) & (samples['year'] == 2020) & (samples['month'] >= 2) & (samples['month'] <= 5), 'generation'] = 5
samples.loc[(samples['site'] == 57) & (samples['year'] == 2020) & (samples['month'] >= 7) & (samples['month'] <= 12), 'generation'] = 6

samples = samples.rename(columns = {'NUMBER_FLOWERS_COLLECTED': 'number_flowers_collected'})

samples.to_csv('samples_records.csv')
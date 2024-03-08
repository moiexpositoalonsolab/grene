import pandas as pd
import numpy as np
import openpyxl
from datetime import datetime
import os

# Function to convert date with multiple formats
def convert_date_with_multiple_formats(date_str):
    formats = ['%Y-%m-%d', '%m-%d-%y']  # List of formats to try
    for fmt in formats:
        try:
            return pd.to_datetime(date_str, format=fmt)
        except ValueError:
            continue
    return pd.NaT  # Return Not a Time for unconvertible formats

filename = '../census_samples.xlsx'

# Load census/samples spreadsheets
sheets = openpyxl.load_workbook(filename).sheetnames

# Get only the sheets that are census data
census_sheets = [sheet for sheet in sheets if "Census" in sheet]

# Read each selected sheet into a DataFrame and store in a list
sheetlist_census = [pd.read_excel(filename, sheet_name=sheet, dtype={'SITE': str, 'PLOT': str}) for sheet in census_sheets]

# Concatenate all DataFrames in the list into a single DataFrame
census = pd.concat(sheetlist_census, ignore_index=True)

# Select only relevant columns and clean/format the data
## will ignore COMMENTS2 since it does nto have any info 
census = census[['SITE', 'PLOT', 'DATE', 'DIAGONAL_PLANT_NUMBER', 'OFF-DIAGONAL_PLANT_NUMBER',
                 'TOTAL_PLANT_NUMBER\n(OPTIONAL)', 'MEAN_FRUITS_PER_PLANT\n(OPTIONAL)', 'SD_FRUITS_PER_PLANT\n(OPTIONAL)',
                 'COMMENTS']]

## from the diaries I know site 55 uses the format '%Y-%m-%d'

census['DATE'] = census['DATE'].astype(str).str.replace('\.0$', '', regex=True)

## based on info from the diaries and checked the date is actually 20190320
census.loc[census['DATE'] == '20193020', 'DATE'] = '20190320'

census['DATE'] = census['DATE'].apply(convert_date_with_multiple_formats)

census = census.rename(columns={
    'SITE': 'site',
    'PLOT': 'plot',
    'DATE': 'date',
    'DIAGONAL_PLANT_NUMBER': 'diagonalplantnumber',
    'OFF-DIAGONAL_PLANT_NUMBER': 'offdiagonalplantnumber',
    'TOTAL_PLANT_NUMBER\n(OPTIONAL)': 'totalplantnumber',
    'MEAN_FRUITS_PER_PLANT\n(OPTIONAL)': 'meanfruitsperplant',
    'SD_FRUITS_PER_PLANT\n(OPTIONAL)': 'sdfruitsperplant',
    'COMMENTS': 'comments'
})

census['plot'] = census['plot'].astype(float)

## this record does not contain nay information 
index_todrop = census[census['plot'].isna()].index
census = census.drop(index_todrop)

census['site'] = census['site'].astype(float).astype(int)

census['plot'] = census['plot'].astype(int)

census['censusid'] = census.apply(lambda row: str(row['site']).zfill(2) + str(row['plot']).zfill(2) + row['date'].strftime('%Y%m%d'), axis=1)


## some sites used a ? symbol, replace it for nan
census = census.replace('?', np.nan)


## since this is in totalplantnumber but it is already in the comment, just replace it for np nan 
census = census.replace('>100', np.nan)

## put all this data in the comments and replace for nan

census.loc[census['totalplantnumber'] == 'more than 20', 'comments'] = 'more than 20'
census['totalplantnumber'] = census['totalplantnumber'].replace('more than 20', np.nan)

census.loc[census['totalplantnumber'] == 'many but probably not A. thaliana', 'comments'] = 'many but probably not A. thaliana'
census['totalplantnumber'] = census['totalplantnumber'].replace('many but probably not A. thaliana', np.nan)

census.loc[census['totalplantnumber'] == '* total number of plants was impossible to assess as there are a lot of very small, purplish rosettes that aggregate together which makes it impossible to count.', 'comments'] = '* total number of plants was impossible to assess as there are a lot of very small, purplish rosettes that aggregate together which makes it impossible to count.'
census['totalplantnumber'] = census['totalplantnumber'].replace('* total number of plants was impossible to assess as there are a lot of very small, purplish rosettes that aggregate together which makes it impossible to count.', np.nan)

census['year'] = census['date'].dt.year

census['month'] = census['date'].dt.month

# Add annotations for generations, considering all experiments started in 2017
census['generation'] = np.where(census['month'] >= 10, 
                                      census['year'] - 2017 + 1, 
                                      census['year'] - 2017)

census.loc[(census['site'] == 57) & (census['year'] == 2018) & (census['month'] >= 3) & (census['month'] <= 6), 'generation'] = 1
census.loc[(census['site'] == 57) & (census['year'] == 2018) & (census['month'] >= 9) & (census['month'] <= 12), 'generation'] = 2
census.loc[(census['site'] == 57) & (census['year'] == 2019) & (census['month'] >= 1) & (census['month'] <= 6), 'generation'] = 3
census.loc[(census['site'] == 57) & (census['year'] == 2019) & (census['month'] >= 7) & (census['month'] <=11), 'generation'] = 4
census.loc[(census['site'] == 57) & (census['year'] == 2020) & (census['month'] >= 2) & (census['month'] <= 5), 'generation'] = 5
census.loc[(census['site'] == 57) & (census['year'] == 2020) & (census['month'] >= 7) & (census['month'] <= 12), 'generation'] = 6

## this site summed diag and off diagonal
## 'summed diag. & off-diag. in error; redid survey 2 weeks later, see next entries'
## based on this we will create a new column of the sum and then delete the diagonalplantnumber
census.loc[census['comments'] ==  'summed diag. & off-diag. in error; redid survey 2 weeks later, see next entries', 'sum_diagonal_off_diag'] = census.loc[census['comments'] ==  'summed diag. & off-diag. in error; redid survey 2 weeks later, see next entries', 'diagonalplantnumber']
census.loc[census['comments'] ==  'summed diag. & off-diag. in error; redid survey 2 weeks later, see next entries', 'diagonalplantnumber'] = np.nan


## from what I observed in the sheets, the participants in this date got confused and put the flower heads collected in ttoal 
## plant number, but actually counted the plants and added to the comments
## the plantnumber reported is teh same as the flower heads counts for that date
## so i will replace the data for the one in the comments and replace a comment for a number 
census.loc[(census['site']==52) & (census['date'] == '20210323'), 'totalplantnumber'] = census.loc[(census['site']==52) & (census['date'] == '20210323'), 'comments']

census = census.replace('non-flowering plants:>50', 50)

## read also the diarie and this people put the number of flowering plant instead of the number of rosettes 
census.loc[census['comments'] ==  'Total plant number only of flowering plants', 'flowering_plants'] = census.loc[census['comments'] ==  'Total plant number only of flowering plants', 'totalplantnumber']
census.loc[census['comments'] ==  'Total plant number only of flowering plants','totalplantnumber'] = np.nan

## just replace empty string with np.nan
census.loc[(census['site'] == 5) & (census['date']=='20180321'), 'totalplantnumber'] = np.nan

census.to_csv('../../data/census_data.csv')
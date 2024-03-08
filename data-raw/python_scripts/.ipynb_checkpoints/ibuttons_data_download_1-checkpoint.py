# download ibuttons data and create two datasets, 1 for hum/temp ibuttons and 1 for temp ibuttons 
# author Tati
# date nov 7 2022

import pandas as pd
import numpy as np
import os
import datetime as dt
import io
import ast
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from googleapiclient.http import MediaIoBaseDownload

path = 'data-raw/'
files = os.listdir(path)

tempr = [file for file in files if 'tempr' in file]
temphum = [file for file in files if 'temphum' in file]

temp_ib_data = pd.DataFrame()

dt = 'object'
columns = {'datetime':dt, 'unit':dt,
            'value':'float', 'name':dt}

possible_formats_temp = ['%m/%d/%y %H:%M', '%d.%m.%y %H:%M:%S' , '%m/%d/%y %H:%M:%S', '%m/%d/%y %I:%M:%S %p',
                '%d-%m-%y %H:%M:%S', '%d/%m/%y %H:%M:%S', '%d/%m/%y %H:%M', '%d/%m/%y %H:%M:%S',
                '%d/%m/%Y %H:%M:%S' , '%d/%m/%Y %H:%M', '%d-%m-%y %H:%M', '%d.%m.%y %H:%M', '%m/%d/%Y %H:%M', '%m/%d/%y ', '%d/%m/%y', '%y.%m.%d %H:%M']

possible_formats_humtemp = ['%d.%m.%y' , '%d-%m-%y','%d-%m-%Y','%d/%m/%Y', '%m/%d/%y',  '%d/%m/%y', '%m/%d/%Y','%y-%m-%d','%y-%d-%m', '%m/%d/%y %H:%M']
            
for file in tempr: 
    print(file)
    ibutton = pd.read_csv( path + file,
                          usecols = columns.keys(),
                          dtype = columns)
    print(ibutton.iloc[0,0])
    if (ibutton['unit'] == 'F').any(): 
        ibutton['value'] = (ibutton['value']-32) * 5/9
        ibutton['unit'] = 'C'
    ibutton['name'] = file.replace('.csv', '').replace('tempr', '')
    
    #ibutton['datetime_right'] = pd.to_datetime(ibutton['datetime'])
    ibutton['datetime_right'] = np.nan
    #for eachformat in possible_formats_temp: 
    #    ibutton['datetime_right'] = ibutton['datetime_right'].fillna(pd.to_datetime(ibutton['datetime'], format=eachformat, errors="coerce"))
    
    for eachformat in possible_formats_temp:
        ibutton['datetime_right'] = ibutton['datetime_right'].fillna(pd.to_datetime(ibutton['datetime'], format=eachformat, errors="coerce"))
        if ibutton['datetime_right'].isna().any():
            ibutton['datetime_right'] = np.nan
        else:
            break 

    if (file == 'tempr33-11-40BFF421-20190819.csv') or (file == 'tempr33-02-40C90021-20190819.csv'): 
        ibutton['datetime_right'] = pd.to_datetime(ibutton['datetime'], format='%d.%m.%y %H:%M')
    if file == 'tempr33-02-40C90021-20190102.csv': 
        ibutton['datetime_right'] = pd.to_datetime(ibutton['datetime'], format='%y.%m.%d %H:%M')
        
    ## ibuttons with mix formats:
    if (file == 'tempr57-09-40B84621-20170000.csv') or (file == 'tempr57-10-4090ED21-20170000.csv'): 
        ibutton['datetime_right'] = ibutton['datetime_right'].fillna(pd.to_datetime(ibutton['datetime'], format='%d-%m-%y %H:%M:%S', errors="coerce")).fillna(pd.to_datetime(ibutton['datetime'], format='%d/%m/%y %H:%M', errors="coerce"))
    
    if file == ('tempr27-01-40C6BD21-20180811.csv') or ('tempr27-01-408BE821-20180811.csv'):     
        ibutton['datetime_right'] = ibutton['datetime_right'].fillna(pd.to_datetime(ibutton['datetime'], format='%m/%d/%y %I:%M:%S %p', errors="coerce")).fillna(pd.to_datetime(ibutton['datetime'], format='%d-%m-%y %H:%M', errors="coerce"))

    temp_ib_data = pd.concat([temp_ib_data, ibutton])
    os.remove(path + file)
    
temphum_ib_data = pd.DataFrame()

for file in temphum: 
    print(file)
    ibutton = pd.read_csv(path + file,
                          usecols = columns.keys(),
                          dtype = columns)
    print(ibutton.iloc[0,0])
    ibutton['name'] = file.replace('.csv', '').replace('temphum', '')
    if file == 'temphum06-TH-T-50B29441-20180725.csv' or ' temphum06-TH-H-50B29441-20180725.csv':
        ibutton['datetime'] = ibutton['datetime'].str.split(' ').str[0]
        
    ibutton['datetime'] = ibutton['datetime'].str.replace('%RH', '')
    
    ibutton['datetime_right'] = pd.to_datetime(ibutton['datetime'])
    
    ibutton['datetime_right'] = np.nan
    #for eachformat in possible_formats_humtemp: 
    #    ibutton['datetime_right'] = ibutton['datetime_right'].fillna(pd.to_datetime(ibutton['datetime'], format=eachformat, errors="coerce"))
    
    
    
    for eachformat in possible_formats_humtemp:
        ibutton['datetime_right'] = ibutton['datetime_right'].fillna(pd.to_datetime(ibutton['datetime'], format=eachformat, errors="coerce"))
        if ibutton['datetime_right'].isna().any():
            ibutton['datetime_right'] = np.nan
        else:
            break 
            
    if (file == 'temphum33-TH-H-20190102.csv') or (file == 'temphum33-TH-T-20190102.csv'): 
        ibutton['datetime_right'] = pd.to_datetime(ibutton['datetime'], format='%y-%m-%d')
            
    ## ibuttons with mix formats:
    if (file == 'temphum57-TH-H-20170000.csv') or (file == 'temphum57-TH-T-20170000.csv'): 
        ibutton['datetime_right'] = ibutton['datetime_right'].fillna(pd.to_datetime(ibutton['datetime'], format='%d-%m-%y', errors="coerce")).fillna(pd.to_datetime(ibutton['datetime'], format='%d/%m/%y', errors="coerce"))
   
    if (file == 'temphum27-TH-T-50B65E41-20180811.csv') or (file == 'temphum27-TH-H-50B65E41-20180811.csv'): 
        ibutton['datetime_right'] = ibutton['datetime_right'].fillna(pd.to_datetime(ibutton['datetime'], format='%m/%d/%y', errors="coerce")).fillna(pd.to_datetime(ibutton['datetime'], format='%m-%d-%y', errors="coerce"))
    
    
    temphum_ib_data = pd.concat([temphum_ib_data, ibutton])
    ## now we can drop it
    os.remove(path + file)

ib_info = pd.read_csv('data/ibuttons_info.csv')

temphum_ib_data = temphum_ib_data.merge(ib_info[['name', 'sensortype', 'site']], how = 'left')

temp_ib_data = temp_ib_data.merge(ib_info[['name', 'sensortype', 'site', 'plot']], how = 'left')

temphum_ib_data.to_csv('data/temphum_ib_data.csv')
temp_ib_data.to_csv('data/temp_ib_data.csv')






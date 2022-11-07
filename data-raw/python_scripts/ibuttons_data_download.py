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

SCOPES = ['https://www.googleapis.com/auth/spreadsheets', 'https://www.googleapis.com/auth/drive']
creds = Credentials.from_authorized_user_file('data-raw/python_scripts/token.json', SCOPES)
drive_service = build('drive', 'v3', credentials=creds)

ibuttons_info = pd.read_csv('data/ibuttons_info.csv')
tempr = ibuttons_info[(ibuttons_info['sensortype'].isin(['temp'])) ][['fileid', 'name']]
temphum = ibuttons_info[(ibuttons_info['sensortype'].isin(['hum-tempT', 'hum-tempH']))][['fileid', 'name']]

ibtypes = [tempr, temphum]
ibnames = ['tempr','temphum']

for ibtype, ibname in zip(ibtypes, ibnames): 
    for file_id, name in zip(ibtype['fileid'], ibtype['name']):
        request = drive_service.files().get_media(fileId=file_id)
        fh = io.FileIO(f'data-raw/{ibname}{name}.csv', 'wb') 
        downloader = MediaIoBaseDownload(fh, request)
        print(name)
        done = False
        while done is False:
            status, done = downloader.next_chunk()
            print ("Download %d%%." % int(status.progress() * 100))

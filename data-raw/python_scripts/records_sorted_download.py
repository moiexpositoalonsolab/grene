from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from googleapiclient.http import MediaIoBaseDownload
import io
import ast
import glob
import pandas as pd
import os

with open('data-raw/python_scripts/files_to_download.txt') as f:
    files_to_download = ast.literal_eval(f.read())

SCOPES = ['https://www.googleapis.com/auth/spreadsheets', 'https://www.googleapis.com/auth/drive']
creds = Credentials.from_authorized_user_file('data-raw/python_scripts/token.json', SCOPES)
drive_service = build('drive', 'v3', credentials=creds)

files_downloaded = []
for files in files_to_download:
    request = drive_service.files().export_media(fileId=files['id'], mimeType='text/csv')
    name =files['name']
    print(name)
    files_downloaded.append(name)
    fh = io.FileIO(f'data-raw/{name}.csv', 'wb') 
    downloader = MediaIoBaseDownload(fh, request)
    done = False
    while done is False:
        status, done = downloader.next_chunk()
        print ("Download %d%%." % int(status.progress() * 100))

samples_sorted = pd.concat([pd.read_csv(f, index_col=0, usecols=['CODES','SITE','PLOT','DATE','SAMPLE_ID','NUMBER_FLOWERS_COLLECTED','TO_SKIP','REPLICATES']) for f in glob.glob("data-raw/Samples_selected*.csv")])

samples_sorted.to_csv('data-raw/samples_sorted.csv')

for files in files_downloaded:
    if os.path.exists(f"data-raw/{files}.csv"):
        os.remove(f"data-raw/{files}.csv")
print('samples_sorted.csv saved and all intermediate files removed')

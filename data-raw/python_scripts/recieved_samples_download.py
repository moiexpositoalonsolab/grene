# https://docs.google.com/spreadsheets/d/1D9ilDvRYg-UGmDpc8NWaA9xvMtqjTv6PIfkP9IP4-fA/edit#gid=0
# download of GrENE-net_received_samples_n_data2018-2021

from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from googleapiclient.http import MediaIoBaseDownload
import io
import ast

SCOPES = ['https://www.googleapis.com/auth/spreadsheets', 'https://www.googleapis.com/auth/drive']
creds = Credentials.from_authorized_user_file('data-raw/python_scripts/token.json', SCOPES)
drive_service = build('drive', 'v3', credentials=creds)

file_id = '1D9ilDvRYg-UGmDpc8NWaA9xvMtqjTv6PIfkP9IP4-fA'

request = drive_service.files().export_media(fileId=file_id, mimeType='text/csv')

fh = io.FileIO('data-raw/recieved_samples_dataraw.csv', 'wb') 
downloader = MediaIoBaseDownload(fh, request)
print('recieved_samples_dataraw.csv')
done = False
while done is False:
    status, done = downloader.next_chunk()
    print ("Download %d%%." % int(status.progress() * 100))

## import the general list of accessions 
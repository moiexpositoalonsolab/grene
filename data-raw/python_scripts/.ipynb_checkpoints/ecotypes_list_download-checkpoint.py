## import the list of ecotypes used in grenenet 
## https://docs.google.com/spreadsheets/d/1TfOSBCR55-gXJPn7FSQcQSdD-GNj9GwynVKaoPx3jC8/edit#gid=0
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from googleapiclient.http import MediaIoBaseDownload
import io
import ast

SCOPES = ['https://www.googleapis.com/auth/spreadsheets', 'https://www.googleapis.com/auth/drive']
creds = Credentials.from_authorized_user_file('data-raw/python_scripts/token.json', SCOPES)
drive_service = build('drive', 'v3', credentials=creds)

file_id = '1TfOSBCR55-gXJPn7FSQcQSdD-GNj9GwynVKaoPx3jC8'

request = drive_service.files().export_media(fileId=file_id, mimeType='text/csv')

fh = io.FileIO('data-raw/ecotypes_seedmix.csv', 'wb') 
downloader = MediaIoBaseDownload(fh, request)
print('ecotypes_seedmix.csv')
done = False
while done is False:
    status, done = downloader.next_chunk()
    print ("Download %d%%." % int(status.progress() * 100))

## import the general list of accessions 

## import silique counting spreadsheets uploaded till nov 1 2022
## https://docs.google.com/spreadsheets/d/1n42223TJbNhULn4WT-d9lD2lWy4KjWRBKEcebjguNzA/edit#gid=1499384771
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from googleapiclient.http import MediaIoBaseDownload
import io
import ast

SCOPES = ['https://www.googleapis.com/auth/spreadsheets', 'https://www.googleapis.com/auth/drive']
creds = Credentials.from_authorized_user_file('data-raw/python_scripts/token.json', SCOPES)
drive_service = build('drive', 'v3', credentials=creds)

file_id = '1n42223TJbNhULn4WT-d9lD2lWy4KjWRBKEcebjguNzA'

request = drive_service.files().export_media(fileId=file_id, mimeType='text/csv')

fh = io.FileIO('data-raw/siliques_data_raw.csv', 'wb') 
downloader = MediaIoBaseDownload(fh, request)
print('siliques_data_raw.csv')
done = False
while done is False:
    status, done = downloader.next_chunk()
    print ("Download %d%%." % int(status.progress() * 100))


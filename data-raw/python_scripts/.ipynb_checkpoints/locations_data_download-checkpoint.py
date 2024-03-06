## import the list of participants data 
#https://docs.google.com/spreadsheets/d/1NTHPZ23FQHmvxaXzonJwRdORMVi6Qz-ILHE_T47S3VI/edit?pli=1#gid=818914143

from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from googleapiclient.http import MediaIoBaseDownload
import io
import ast

SCOPES = ['https://www.googleapis.com/auth/spreadsheets', 'https://www.googleapis.com/auth/drive']
creds = Credentials.from_authorized_user_file('data-raw/python_scripts/token.json', SCOPES)
drive_service = build('drive', 'v3', credentials=creds)

file_id = '1NTHPZ23FQHmvxaXzonJwRdORMVi6Qz-ILHE_T47S3VI'

request = drive_service.files().export_media(fileId=file_id, mimeType='text/csv')

fh = io.FileIO('data-raw/locations_dataraw.csv', 'wb') 
downloader = MediaIoBaseDownload(fh, request)
print('locations_dataraw.csv')
done = False
while done is False:
    status, done = downloader.next_chunk()
    print ("Download %d%%." % int(status.progress() * 100))

## import the general list of accessions 

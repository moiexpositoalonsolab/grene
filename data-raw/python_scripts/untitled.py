# https://docs.google.com/spreadsheets/d/15Pe3MsCD_CKBYD183t5qjzm-KGtSpUqha_KRGQmY8to/edit?pli=1#gid=0
# download diaries summary 
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from googleapiclient.http import MediaIoBaseDownload
import io
import ast

SCOPES = ['https://www.googleapis.com/auth/spreadsheets', 'https://www.googleapis.com/auth/drive']
creds = Credentials.from_authorized_user_file('data-raw/python_scripts/token.json', SCOPES)
drive_service = build('drive', 'v3', credentials=creds)

file_id = '15Pe3MsCD_CKBYD183t5qjzm-KGtSpUqha_KRGQmY8to'

request = drive_service.files().export_media(fileId=file_id, mimeType='text/csv')

fh = io.FileIO('data-raw/diaries_summary_dataraw.csv', 'wb') 
downloader = MediaIoBaseDownload(fh, request)
print('diaries_summary_dataraw.csv')
done = False
while done is False:
    status, done = downloader.next_chunk()
    print ("Download %d%%." % int(status.progress() * 100))

## import the general list of accessions 
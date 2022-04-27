from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from googleapiclient.http import MediaIoBaseDownload
import io
import ast

SCOPES = ['https://www.googleapis.com/auth/spreadsheets', 'https://www.googleapis.com/auth/drive']
creds = Credentials.from_authorized_user_file('data-raw/python_scripts/token.json', SCOPES)
drive_service = build('drive', 'v3', credentials=creds)

file_id = '14prL6uIpfutAixzRr8V6taHzmWpP8KjHCd-Vd3m9F58'

request = drive_service.files().export_media(fileId='1F4_3Uc62Hn3Aah-XqFVG3aF3xtzYNY3ETjlM6OtQTAM', mimeType='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')

fh = io.FileIO('data-raw/census_samples.xlsx', 'wb') 
downloader = MediaIoBaseDownload(fh, request)
print('census_samples.xlsx')
done = False
while done is False:
    status, done = downloader.next_chunk()
    print ("Download %d%%." % int(status.progress() * 100))

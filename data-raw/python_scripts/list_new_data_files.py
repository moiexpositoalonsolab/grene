from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
SCOPES = ['https://www.googleapis.com/auth/spreadsheets', 'https://www.googleapis.com/auth/drive']
creds = Credentials.from_authorized_user_file('data-raw/python_scripts/token.json', SCOPES)

service = build('drive', 'v3', credentials=creds)

results = service.files().list(
    q="'1Unx3cb5WYUtxUQ0ETlNO9j6dz6FsHPKt' in parents and mimeType='application/vnd.google-apps.spreadsheet'" , 
    pageSize=10, fields="nextPageToken, files(id, name)").execute()
items = results.get('files', [])

filtered = [item for item in items if item['name'].startswith('Samples_selected_sequencing')]

print('Items that will be download')
for item in filtered:
    print(u'{0}'.format(item['name']))

import json
with open('data-raw/python_scripts/files_to_download.txt', 'w') as fout:
    json.dump(filtered, fout)


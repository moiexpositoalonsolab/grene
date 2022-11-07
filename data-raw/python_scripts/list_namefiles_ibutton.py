import pandas as pd
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
SCOPES = ['https://www.googleapis.com/auth/spreadsheets', 'https://www.googleapis.com/auth/drive']
creds = Credentials.from_authorized_user_file('data-raw/python_scripts/token.json', SCOPES)

service = build('drive', 'v3', credentials=creds)

folder_id = "1-vtLaK1bdWlVSHAYC9cjfkzq06xNIeDi"
query = f"parents = '{folder_id}' and mimeType='application/vnd.google-apps.folder'"
response = service.files().list(q=query).execute()
files = response.get('files')
nextPageToken = response.get('nextPageToken')

while nextPageToken:
    response = service.files().list(q=query).execute()
    files.extend(response.get('files'))
    nextPageToken = result.get('nextPageToken')

parent_folders = pd.DataFrame(files)
all_folders = pd.DataFrame()

for folder_id in parent_folders.id:
    query = f"parents = '{folder_id}' and mimeType='application/vnd.google-apps.folder'"
    response = service.files().list(q=query).execute()
    files = response.get('files')
    nextPageToken = response.get('nextPageToken')
    
    while nextPageToken:
        response = service.files().list(q=query).execute()
        files.extend(response.get('files'))
        nextPageToken = result.get('nextPageToken')
    #print(files)
    df_aux = pd.DataFrame(files)
    df_aux['parent_folder'] = folder_id
    all_folders = pd.concat([all_folders, df_aux])

all_files = pd.DataFrame()
for folder_id in all_folders.id:
    query = f"parents = '{folder_id}'"
    response = service.files().list(q=query).execute()
    files = response.get('files')
    nextPageToken = response.get('nextPageToken')
    
    while nextPageToken:
        response = service.files().list(q=query).execute()
        files.extend(response.get('files'))
        nextPageToken = result.get('nextPageToken')
    #print(files)
    df_aux = pd.DataFrame(files)
    df_aux['folder_id'] = folder_id
    all_files = pd.concat([all_files, df_aux])


####### preprocessing of ibuttons file names ######
all_folders = all_folders[['id', 'name', 'parent_folder']]
parent_folders = parent_folders[['id', 'name']]

all_files = all_files[all_files['mimeType'].isin(['text/csv',
       'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
       'application/vnd.ms-excel', 'text/plain'])]

## a lot of participants used _ instead of - 
all_files['name'] = all_files['name'].str.replace('_', '-')

all_files['name_noext'] = all_files['name'].str.split('.').str[0]
all_files['ext'] = all_files['name'].str.split('.').str[-1]

#drop duplicated files because of different formats
all_files = all_files.sort_values(['name_noext','ext']).drop_duplicates(subset='name_noext', keep='first')

general = all_folders.merge(parent_folders, left_on = 'parent_folder', right_on = 'id', how='left')

general = general.drop(['parent_folder', 'id_y'],axis=1)

general.columns = ['folder_id', 'folder_name', 'p_folder_name']

all_files = all_files[['name', 'id', 'name_noext', 'ext' , 'folder_id']]

general = all_files.merge(general, left_on = 'folder_id', right_on = 'folder_id', how='left')

general = general[['name','name_noext','ext', 'folder_name', 'p_folder_name', 'id']]

general['sensor_type'] = 'not_known'

general.loc[general.name.str.contains('TH'), 'sensor_type'] = 'hum-temp'
general.loc[general.name.str.contains('TH-H'), 'sensor_type'] = 'hum-tempH'
general.loc[general.name.str.contains('TH-T'), 'sensor_type'] = 'hum-tempT'

general.loc[(general['sensor_type'] == 'not_known') & (general['name_noext'].str.len().isin([23])), 'sensor_type'] = 'temp'

general_temp = general.loc[(general['sensor_type'] == 'temp')].copy()

## extract site, plot and date from temperature sensors 
general_temp[['site', 'plot', 'devicenum', 'date']] = general_temp['name_noext'].str.split('-',4,expand=True)

general_humtemp = general.loc[general['sensor_type'].isin(['hum-tempT', 'hum-tempH'])].copy()

general_humtemp[['site','hum-tempT-exp' ]] = general_humtemp['name_noext'].str.split('-',1,expand=True)

general_humtemp[['hum-tempT-exp','date' ]] = general_humtemp['hum-tempT-exp'].str.rsplit('-', 1, expand=True)


general = pd.concat([general_temp,general_humtemp.drop('hum-tempT-exp',axis=1)])

general['date'] = general['date'].replace({'20170000':'20170101','20180000':'20180101',
                                           '20200700': '20200701', '20190300': '20190301',
                                           '20191100': '20191101',
                                          '20200792': '20200702',
                                          '20182208': '20180822'})

general['site'] = general['site'].astype(int)

general = general[['id','name_noext', 'ext', 'folder_name', 'p_folder_name',
       'sensor_type', 'site', 'plot', 'devicenum', 'date']]

general.columns = ['fileid','name', 'ext', 'foldername', 'pfoldername',
       'sensortype', 'site', 'plot', 'devicenum', 'date']
       
general.to_csv('data/ibuttons_info.csv')

    

import numpy as np
import pandas as pd

survival = pd.read_csv('../SURVIVAL_total_flowers_collected.csv')

fail_gen0 = survival[survival['plot'].isin([ 'no_existence', 'not_successful',
       'no_germination','no_success', 'not_reported'])][['site', 'plot', 'comments']]

def check_all_plots_died(group):
    results = {}
    for column in ['1_survival', '2_survival', '3_survival', '4_surviva', '5_survival']:
        # Check if all values in the column for this group are -1
        results[column] = (group[column] == -1).all()
    return pd.Series(results)

# Group by 'site' and apply the custom function
results = survival.groupby('site').apply(check_all_plots_died)



results = results.reset_index()

results.loc[results['site'].isin(fail_gen0['site'].to_list()), '0_survival'] = True

results = results.fillna(False)

results = results.astype(int)

df = results[['site','0_survival','1_survival', '2_survival', '3_survival', '4_surviva',
       '5_survival', ]].set_index('site')

# Concatenate column names where value is 1 for each row
df = df.apply(lambda row: ','.join([row.index[col] for col in range(len(row)) if row[col] == 1]), axis=1)

df = df.reset_index().rename(columns={0: 'year_experiment_ended'})

df['year_experiment_ended'] = df['year_experiment_ended'].str.replace('_survival', '') #.astype(float).fillna(0)

df['year_experiment_ended'] = pd.to_numeric(df['year_experiment_ended'], errors='coerce').fillna(np.nan)

df = df.merge(fail_gen0, on ='site', how='outer').rename(columns={'plot': 'reason'})

df.to_csv('year_experiment_ended.csv')
#!/usr/bin/env python3

"""
@author: Shreya Chandrasekharan

This script includes any ad hoc scripts written for theta_plus
"""

# Finding the intersection/union between all 11 years

import pandas as pd
from glob import glob


year_list = []

for file_name in glob('dump.*.mci.I20.csv'):
    if len(file_name) == 37:
        vars()[file_name[5:12]] = pd.read_csv(file_name)
        year_list.append(vars()[file_name[5:12]])
    elif len(file_name) == 42: # ---> imm1985_1995
        vars()[file_name[5:17]] = pd.read_csv(file_name) # ---> Not appending to year_list

for i in range(len(year_list)):
    name = 'imm' + str(85+i)
    year_list[i].name = name

imm1985_1995.name = 'imm85_95'  

# Intersection/Union as absolute values
df = pd.DataFrame(columns = [i.name for i in year_list], index = [i.name for i in year_list])
for i in year_list:
    for j in year_list:
        intersection = len(i.merge(j, left_on = 'scp', right_on = 'scp', how = 'inner'))
        union = len(i.merge(j, left_on = 'scp', right_on = 'scp', how = 'outer'))
        
        df[i.name][j.name] = (intersection,union)
        
# Intersection as a percentage of union
df2 = pd.DataFrame(columns = [i.name for i in year_list], index = [i.name for i in year_list])
for i in year_list:
    for j in year_list:

        df2[i.name][j.name] = df[i.name][j.name][0]/df[i.name][j.name][1]
        
# Intersection as a percentage of total number of records in year (row-wise)
df3 = pd.DataFrame(columns = [i.name for i in year_list], index = [i.name for i in year_list])
for i in year_list:
    for j in year_list:
        intersection = len(i.merge(j, left_on = 'scp', right_on = 'scp', how = 'inner'))
        
        df3[i.name][j.name] =round((intersection/ len(i)), 3)
        

# ------------------------------------------------------------------------------------------- #      

# Get a sample from a shuffled cluster-scp list

import pandas as pd
from sqlalchemy import create_engine
rootdir = '/erniedev_data3/theta_plus/imm'
# user_name 
# password 
schema = "theta_plus"
sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)
year = '1990'
shuffled_file_name = rootdir + '/imm' + year + '/dump.imm' + year + '_citing_cited_shuffled_1million.I20.csv'
# shuffled_file_name = "mcl/immunology/eleven_years/dump.imm1990_citing_cited_shuffled_1million.I20.csv"
shuffled_file = pd.read_csv(shuffled_file_name)
grouped_shuffled_file = shuffled_file.groupby('cluster_no', as_index=False).agg('count').rename(columns={'scp':'cluster_counts'})
grouped_sample = grouped_shuffled_file[(grouped_shuffled_file['cluster_counts'] >= 30) & (grouped_shuffled_file['cluster_counts'] <= 350) ].sample(n=1000, random_state=2020).sort_values(by="cluster_no", ignore_index=True)
grouped_sample['temp_cluster_no'] = grouped_sample.index + 1
sample = grouped_sample['cluster_no'].to_list()
shuffled_sample = shuffled_file[shuffled_file['cluster_no'].isin(sample)]
shuffled_sample = shuffled_sample.merge(grouped_sample[['cluster_no', 'temp_cluster_no']], how='left')
shuffled_sample = shuffled_sample.rename(columns={'cluster_no':'1990_cluster_no', 'temp_cluster_no':'cluster_no'})
# jsd_compute.py takes cluster numbers and not index values, 
# so, we need to change the cluster number to follow an order
save_name_reindexed = 'imm' + year + '_cluster_scp_list_shuffled_sample_reindexed'
save_name_original = 'imm' + year + '_cluster_scp_list_shuffled_sample_original'
shuffled_sample[['cluster_no', 'scp']].to_sql(save_name_reindexed, con=engine, schema=schema, index=False, if_exists='fail')
shuffled_sample[['1990_cluster_no', 'scp']].to_sql(save_name_original, con=engine, schema=schema, index=False, if_exists='fail')


# ------------------------------------------------------------------------------------------- #      

# Code to generate 'table 1' in the paper:

import pandas as pd
from sqlalchemy import create_engine
from tabulate import tabulate
import numpy as np

schema = "theta_plus"
user_name = ""
password = ""
data_type = "imm"
start_year = 1985
end_year = 1995

sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)

year_names_list = []
for year in range(start_year, end_year+1):
    name = data_type + str(year)
    year_names_list.append(name)
superset_name = data_type + str(start_year) + '_' + str(end_year)
year_names_list.append(superset_name)
year_all_merged_list = []
year_citing_cited_list = []

for i in range(len(year_names_list)):
   # Read from Postgres
    table_all_merged_name = year_names_list[i] + '_all_merged_unshuffled'
    year_all_merged_list.append(pd.read_sql_table(table_name=table_all_merged_name, schema=schema, con=engine))   
    year_all_merged_list[i].name = year_names_list[i]
    
    table_citing_cited_name = year_names_list[i] + '_citing_cited'
    year_citing_cited_list.append(pd.read_sql_table(table_name=table_citing_cited_name, schema=schema, con=engine))   
    year_citing_cited_list[i].name = year_names_list[i]


name = []
num_clusters = [] 
num_articles = [] 
num_edges = []
mean_size = [] 
median_size = [] 
mean_cond = []
mean_coh = []

year_names_list[-1] = '   combined'

for i in range(len(year_names_list)):
    
    name.append(year_names_list[i][3:])
    num_clusters.append(len(year_all_merged_list[i]))
    num_articles.append(sum(year_all_merged_list[i]['cluster_size']))
    num_edges.append(len(year_citing_cited_list[i]))
    mean_size.append(round(np.mean(year_all_merged_list[i]['cluster_size']), 3))
    median_size.append(round(np.median(year_all_merged_list[i]['cluster_size']), 3))
    mean_cond.append(round(np.mean(year_all_merged_list[i]['conductance']), 3))
    
    at_least_ten = year_all_merged_list[i][year_all_merged_list[i]['jsd_size'] >= 10]
    weighted_coherence = round(sum(at_least_ten['coherence'] * at_least_ten['cluster_size'])/sum(at_least_ten['cluster_size']), 3)
    mean_coh.append(weighted_coherence)

all_lists = [name, num_clusters, num_articles, num_edges, mean_size, median_size, mean_cond, mean_coh]


headers=['Dataset', 'num_clusters', 'num_articles', 'num_edges', 'mean_size', 
        'median_size', 'mean_conductance', 'mean_coherence*']
print(tabulate(pd.DataFrame(all_lists).transpose(), headers=headers, tablefmt='latex', showindex=False))
#!/usr/bin/env python3
"""
@author: Shreya Chandrasekharan

This script computes Random JSD for all clusters within a clustering.
We have the option to process the data in batches by providing cluster numbers.

Argument(s): rootdir               - The directory where all cluster-scp list information is stored
                                     If Random JSD is being computed from data stored in a database,
                                     this argument is used to identify the cluster name (year)
             start_cluster_num     - The cluster number to start from in a clustering
             end_cluster_num       - The cluster number to process up to.
                                     If there is no specific value, use 'max'
             cluster_type          - The type of cluster to process - (shuffled, unshuffled, graclus)
             repeat                - Number of iterations of Random JSD to be computed
             user_name             - Database username
             password              - Database password
             
Output:      result_df             - Rows to be appended in the final output file (one at a time)
                                     correspoding to the number of clusters processed
"""

import jsd_modules as jm
import pandas as pd
pd.options.mode.chained_assignment = None
import multiprocessing as mp
from sqlalchemy import create_engine
from glob import glob
from sys import argv
import os

jsd_output_column_names = ['weight', 'inflation', 'cluster', 'total_size', 'pre_jsd_size',
       'missing_values', 'post_jsd_size', 'jsd_nans', 'mean_jsd', 'min_jsd',
       'percentile_25_jsd', 'median_jsd', 'percentile_75_jsd', 'max_jsd',
       'std_dev_jsd', 'total_unique_unigrams', 'final_unique_unigrams',
       'size_1_unigram_prop']
    
# name = argv[1]
# val = argv[2]
name = 'now'
val = '20'
rootdir = "/erniedev_data3/theta_plus"
data_type = argv[1]
data_path = rootdir + '/' + data_type
dir_list = sorted(os.listdir(data_path))
start_year = argv[2]
end_year = argv[3]
schema = argv[4]
start_cluster_num = int(argv[5])
end_cluster_num = argv[6]
cluster_type = argv[7]
repeat = int(argv[8])
user_name = argv[9]
password = argv[10]

sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)

# p = mp.Pool(mp.cpu_count())
p = mp.Pool(6)

tmp_dir_list = ['eco2000_2010']
for dir_name in tmp_dir_list:
#for dir_name in dir_list:    
    print(f'Working on {dir_name}')
    
    title_abstracts_table = data_type + start_year + '_' + end_year + '_union_title_abstracts_processed'
    query = "SELECT csl.*, tat.processed_all_text FROM " + schema + "." + dir_name + "_cluster_scp_list_" + cluster_type + " csl LEFT JOIN " + schema + "." + title_abstracts_table + " tat ON csl.scp = tat.scp WHERE tat.processed_all_text is NOT NULL;"
    all_text_data = pd.read_sql(query, con=engine)

    jsd_output_file_name = data_path + '_output/' + dir_name + '/' + dir_name + '_JSD_' + cluster_type + ".csv"
    jsd_output_data = pd.read_csv(jsd_output_file_name, names = jsd_output_column_names)

    cluster_counts_table = jsd_output_data[['cluster', 'pre_jsd_size']].groupby('pre_jsd_size', as_index = False).agg('count').rename(columns={'cluster':'frequency', 'pre_jsd_size':'cluster_size'}).sort_values('cluster_size', ascending=False)
    cluster_counts_table = cluster_counts_table.reset_index(drop=True)

    if end_cluster_num == 'max':
        max_val = len(cluster_counts_table)
    else:
        max_val = int(end_cluster_num)

    save_name = data_path + '_output/' + dir_name + '/' +  dir_name + '_JSD_random_' + cluster_type + '.csv'

    for cluster_num in range(start_cluster_num-1, max_val):
        print("")
    #     print(f'Working on Cluster: {name} {val}.')
        print(f'The Cluster Size Number is {cluster_num+1} of {max_val} in {dir_name}')
        result_df = cluster_counts_table[cluster_num:cluster_num+1]
        print(f'The Cluster Size is {result_df["cluster_size"].values[0]}')
        
        # if there is a struct_error:
        sample_all_text_data = all_text_data.sample(n=2000000) # else use all_text_data
        result_df['random_jsd'] = p.starmap(jm.random_jsd, [(result_df['cluster_size'], sample_all_text_data, repeat)])
        result_df.to_csv(save_name, mode = 'a', index = None, header=False, encoding='utf-8')
        print(f'Done with Cluster Size Number {cluster_num+1}')
        print("")
print("")
print("")
print("ALL COMPLETED.")

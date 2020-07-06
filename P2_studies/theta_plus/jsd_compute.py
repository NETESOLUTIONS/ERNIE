#!/usr/bin/env python3
"""
@author: Shreya Chandrasekharan

This script computes JSD for all clusters within a clustering.
We have the option to process the data in batches by providing cluster numbers.

Argument(s): rootdir               - The directory where all cluster-scp list information is stored
                                     If JSD is being computed from data stored in a database,
                                     this argument is used to identify the cluster name (year)
             start_cluster_num     - The cluster number to start from in a clustering
             end_cluster_num       - The cluster number to process up to.
                                     If there is no specific value, use 'max'
             cluster_type          - The type of cluster to process - (shuffled, unshuffled, graclus)
             user_name             - Database username
             password              - Database password
             
Output:      jsd_df                - Rows to be appended in the final output file (one at a time)
                                     correspoding to the number of clusters processed
"""

import jsd_modules as jm
import pandas as pd
pd.options.mode.chained_assignment = None
import multiprocessing as mp
from sqlalchemy import create_engine
from sys import argv
import os

# name = argv[1]
# val = argv[2]
name = 'now'
val = '20'
rootdir = argv[1] # ---> /erniedev_data3/theta_plus/imm
dir_list = sorted(os.listdir(rootdir))
start_cluster_num = argv[2]
end_cluster_num = argv[3]
cluster_type = argv[4]
user_name = argv[5]
password = argv[6]

schema = "theta_plus"
sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)

tmp_dir_list = ['imm1985','imm1986', 'imm1987', 'imm1988', 'imm1989', 'imm1990',
                'imm1991', 'imm1992', 'imm1993', 'imm1994', 'imm1995']
for dir_name in tmp_dir_list:
#for dir_name in dir_list:
    print(f'Working on {dir_name}')
    title_abstracts_table = 'imm1985_1995_union_title_abstracts_processed'
    query = "SELECT csl.*, tat.processed_all_text FROM theta_plus." + dir_name + "_cluster_scp_list_" + cluster_type + " csl LEFT JOIN theta_plus." + title_abstracts_table + " tat ON csl.scp = tat.scp;"  
    data_text = pd.read_sql(query, con=engine)
    
    if end_cluster_num == 'max':
        max_val = data_text['cluster_no'].max()
    else:
        max_val = int(end_cluster_num)

    save_name = rootdir + '_output/' + dir_name + '/' + dir_name + '_JSD_' + cluster_type + ".csv"
    # p = mp.Pool(mp.cpu_count())
    p = mp.Pool(6)

    for cluster_num in range(int(start_cluster_num), max_val+1):

        print(f'Working on Cluster Number {cluster_num} of {max_val} in {dir_name}_{cluster_type}')
        jsd_dict = p.starmap(jm.compute_jsd, [(data_text[data_text['cluster_no']==cluster_num], name, val, cluster_num)])
        jsd_df = pd.DataFrame(jsd_dict)
        jsd_df.to_csv(save_name, mode = 'a', index = None, header=False, encoding='utf-8')

    print(f'{dir_name} Completed.')
    print("")
    print("")
    
print("All Completed.")


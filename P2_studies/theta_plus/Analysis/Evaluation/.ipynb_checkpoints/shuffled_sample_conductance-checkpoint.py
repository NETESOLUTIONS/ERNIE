#!/usr/bin/env python3
"""
@author: Shreya Chandrasekharan

This script computes conductance for shuffled sample clusters. 

Argument(s): rootdir               - The directory where all cluster-scp list information is stored
             cluster_name          - Cluster name to append - (re-indexed/original)
             
Output:      conductance_x5        - Final data frame of complete conductance computation
"""

import os
import pandas as pd
from sys import argv
from glob import glob

rootdir = '/erniedev_data3/theta_plus/imm'
dir_list = sorted(os.listdir(rootdir))
cluster_name = argv[1] # ---> re-indexed/original

for dir_name in dir_list:
    print(f'Working on {dir_name}')
    
    shuffled_cluster_path = rootdir + '/' + dir_name + '/dump.' + dir_name + '_citing_cited_shuffled_1million.I20.csv'
    shuffled_file = pd.read_csv(shuffled_cluster_path)
    
    grouped_shuffled_file = shuffled_file.groupby('cluster_no', as_index=False).agg('count').rename(columns={'scp':'cluster_counts'})
    grouped_sample = grouped_shuffled_file[(grouped_shuffled_file['cluster_counts'] >= 30) & (grouped_shuffled_file['cluster_counts'] <= 350) ].sample(n=1000, random_state=2020).sort_values(by="cluster_no", ignore_index=True)
    grouped_sample['temp_cluster_no'] = grouped_sample.index + 1
    sample = grouped_sample['cluster_no'].to_list()
    shuffled_sample = shuffled_file[shuffled_file['cluster_no'].isin(sample)] 
    shuffled_sample = shuffled_sample.merge(grouped_sample[['cluster_no', 'temp_cluster_no']], how='left')
    shuffled_sample = shuffled_sample.rename(columns={'cluster_no':'1990_cluster_no', 'temp_cluster_no':'cluster_no'})
    
    shuffled_sample_scp = shuffled_sample['scp'].to_list()
    cluster_data = shuffled_sample[['cluster_no', 'scp']]
    
    nodes_data_name = rootdir + '/' + dir_name + '/' + dir_name + '_citing_cited.csv'
    nodes_data = pd.read_csv(nodes_data_name)
    nodes_data = nodes_data[(nodes_data['citing'].isin(shuffled_sample_scp)) | (nodes_data['cited'].isin(shuffled_sample_scp))]

    conductance_data = nodes_data.merge(cluster_data, left_on='citing', right_on='scp', how='inner').rename(columns={'cluster_no':'citing_cluster'}).merge(cluster_data, left_on='cited', right_on='scp', how='inner').rename(columns={'cluster_no':'cited_cluster'})

    conductance_data = conductance_data[['citing', 'cited', 'citing_cluster', 'cited_cluster']]

    conductance_counts_data = cluster_data.groupby('cluster_no', as_index=False).agg('count').rename(columns={'cluster_no':'cluster', 'scp':'cluster_counts'})

    conductance_x1 = conductance_data[conductance_data.cited_cluster != conductance_data.citing_cluster][['citing', 'citing_cluster']].groupby('citing_cluster', as_index=False).agg('count').rename(columns = {'citing': 'ext_out'})
    conductance_x2 = conductance_data[conductance_data.cited_cluster != conductance_data.citing_cluster][['cited', 'cited_cluster']].groupby('cited_cluster', as_index=False).agg('count').rename(columns = {'cited': 'ext_in'})
    conductance_x3 = conductance_data[conductance_data.cited_cluster == conductance_data.citing_cluster][['citing', 'cited_cluster']].groupby('cited_cluster', as_index=False).agg('count').rename(columns = {'citing': 'int_edges'})

    conductance_x1_clusters = conductance_counts_data.merge(conductance_x1, left_on = 'cluster', right_on = 'citing_cluster', how = 'left')[['cluster', 'ext_out']]
    conductance_x1_clusters = conductance_x1_clusters.fillna(0)
    conductance_x2_clusters = conductance_counts_data.merge(conductance_x2, left_on = 'cluster', right_on = 'cited_cluster', how = 'left')[['cluster', 'ext_in']]
    conductance_x2_clusters = conductance_x2_clusters.fillna(0)
    conductance_x3_clusters = conductance_counts_data.merge(conductance_x3, left_on = 'cluster', right_on = 'cited_cluster', how = 'left')[['cluster', 'int_edges', 'cluster_counts']]
    conductance_x3_clusters = conductance_x3_clusters.fillna(0)

    conductance_x4 = conductance_x1_clusters.merge(conductance_x2_clusters, left_on='cluster', right_on='cluster', how = 'inner')
    conductance_x5 = conductance_x4.merge(conductance_x3_clusters, left_on='cluster', right_on='cluster')
    conductance_x5['boundary'] = conductance_x5['ext_in'] + conductance_x5['ext_out']
    conductance_x5['volume'] = conductance_x5['ext_in'] + conductance_x5['ext_out'] + 2*conductance_x5['int_edges']
    conductance_x5['two_m'] = conductance_data.shape[0]*2
    conductance_x5['alt_denom'] = conductance_x5['two_m'] - conductance_x5['volume']
    conductance_x5['denom'] = conductance_x5[['alt_denom', 'volume']].min(axis=1)
    conductance_x5['conductance'] = round((conductance_x5['boundary']/conductance_x5['denom']), 3)

    save_name = rootdir + '_output/' + dir_name + '/' +  dir_name + '_conductance_shuffled_sample_' + cluster_name + '.csv'
    conductance_x5.to_csv(save_name, index = None, header=True, encoding='utf-8')

print("All completed.")


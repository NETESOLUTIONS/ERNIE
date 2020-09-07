#!/usr/bin/env python3
"""
@author: Shreya Chandrasekharan

This script computes conductance for given clusters. 

Argument(s): data_type             - The data type to compute conductance for - 'imm' or 'eco'
                                     'imm': immunology
                                     'eco': ecology
             cluster_type          - The type of cluster to process - 
                                     (shuffled, unshuffled, graclus, leiden)
             
Output:      conductance_x5        - Final data frame of complete conductance computation
"""

import os
import pandas as pd
from sys import argv
from glob import glob

data_type = argv[1]
cluster_type = argv[2]
rootdir = '/erniedev_data3/theta_plus/' 
dir_path = rootdir + data_type
dir_list = sorted(os.listdir(dir_path))

tmp_dir_list = ['eco2000_2010']
# for dir_name in dir_list:
for dir_name in tmp_dir_list:
    print(f'Working on {dir_name}')
    if cluster_type == 'unshuffled':
        cluster_path = rootdir + data_type + '/' + dir_name + '/dump.' + dir_name + '_citing_cited.mci.I20.csv'
        cluster_data = pd.read_csv(cluster_path)
        nodes_data_name = rootdir + data_type + '/' + dir_name + '/' + dir_name + '_citing_cited.csv'
    elif cluster_type == 'shuffled':
        cluster_path = rootdir + data_type +  '/' + dir_name + '/dump.' + dir_name + '_citing_cited_shuffled_1million.I20.csv'
        cluster_data = pd.read_csv(cluster_path)
        nodes_data_name = rootdir + data_type + '/' + dir_name + '/' + dir_name + '_citing_cited.csv'
    elif cluster_type == 'graclus':
        graclus_coded_cluster_num_path = rootdir + data_type + '/' + dir_name + '/graclus_' + dir_name + '_citing_cited.csv.part.*'
        graclus_coded_cluster_num = pd.read_csv(glob(graclus_coded_cluster_num_path)[0], header=None)
        graclus_coded_cluster_num.columns = ['cluster_no']
        graclus_coded_cluster_num['citing_id'] = range(1, len(graclus_coded_cluster_num)+1)
        graclus_nodes_path = rootdir + data_type + '/' + dir_name + '/graclus_coded_' + dir_name + '_citing_cited.csv'
        graclus_nodes = pd.read_csv(graclus_nodes_path)
        graclus_clusters = graclus_nodes.merge(graclus_coded_cluster_num)
        graclus_clusters = graclus_clusters.astype({'citing':object, 'citing_id':object, 'cluster_no':object}) 
        cluster_data = graclus_clusters[['citing', 'cluster_no']].rename(columns={'citing':'scp'})
        nodes_data_name = rootdir + data_type + '/' + dir_name + '/' + dir_name + '_citing_cited.csv'
    elif cluster_type == 'graclus_half_mclsize':
        cluster_path = rootdir + data_type + '_output/' + dir_name + '/' +  dir_name + '_cluster_scp_list_graclus_half_mclsize.csv'
        columns = ['scp', 'cluster_no']
        cluster_data = pd.read_csv(cluster_path, names=columns)
        nodes_data_name = rootdir + data_type + '/' + dir_name + '/' + dir_name + '_citing_cited.csv'
    else:
        cluster_path = rootdir + 'Leiden/' + dir_name + '_cluster_scp_list_' + cluster_type + '.csv'
        cluster_data = pd.read_csv(cluster_path)
        nodes_data_name = rootdir + 'Leiden/' + dir_name + '_citing_cited_unique_pairs.csv'
    
    nodes_data = pd.read_csv(nodes_data_name)

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

    save_name = rootdir + data_type + '_output/' + dir_name + '/' +  dir_name + '_conductance_' + cluster_type + '.csv'
    conductance_x5.to_csv(save_name, index = None, header=True, encoding='utf-8')

print("All completed.")



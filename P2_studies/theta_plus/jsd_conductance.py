import os
import pandas as pd
from sys import argv

rootdir = '/erniedev_data3/theta_plus/imm/'
dir_list = sorted(os.listdir(rootdir))
cluster_type = argv[1]

tmp_dir_list = ['imm1985', 'imm1990', 'imm1995']
for dir_name in tmp_dir_list:
# for dir_name in dir_list:
    print(f'Working on {dir_name}')
    if cluster_type == 'unshuffled':
        cluster_path = rootdir + dir_name + '/dump.' + dir_name + '_testcase_asjc2403_citing_cited.mci.I20.csv'
    elif cluster_type == 'shuffled':
        cluster_path = rootdir + dir_name + '/dump.' + dir_name + '_testcase_asjc2403_citing_cited_shuffled_1million.I20.csv'
    
    cluster_data = pd.read_csv(cluster_path)
    
    nodes_data_name = rootdir + dir_name + '/' + dir_name + '_testcase_asjc2403_citing_cited.csv'
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
    
    save_name = '/home/shreya/mcl_jsd/immunology/JSD_conductance_output_' + dir_name + '_' + cluster_type + '.csv'
    conductance_x5.to_csv(save_name, index = None, header=True, encoding='utf-8')
    
print("All completed.")
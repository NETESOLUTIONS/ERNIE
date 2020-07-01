import os
import pandas as pd
from sys import argv

rootdir = '/erniedev_data3/theta_plus/imm'
dir_list = sorted(os.listdir(rootdir))
cluster_type = argv[1]

for dir_name in dir_list:
    print(f'Working on {dir_name}')
    if cluster_type == 'unshuffled':
        cluster_path = rootdir + '/' + dir_name + '/dump.' + dir_name + '_citing_cited.mci.I20.csv'
        cluster_data = pd.read_csv(cluster_path)
    elif cluster_type == 'shuffled':
        cluster_path = rootdir + '/' + dir_name + '/dump.' + dir_name + '_citing_cited_shuffled_1million.I20.csv'
        cluster_data = pd.read_csv(cluster_path)
    elif cluster_type == 'graclus':
        graclus_coded_cluster_num_path = rootdir + '/' + dir_name + '/graclus_' + dir_name + '_citing_cited.csv.part.*'
        graclus_coded_cluster_num = pd.read_csv(glob(graclus_coded_cluster_num_path)[0], header=None)
        graclus_coded_cluster_num.columns = ['cluster_no']
        graclus_coded_cluster_num['citing_id'] = range(1, len(graclus_coded_cluster_num)+1)
        graclus_nodes_path = rootdir + '/' + dir_name + '/graclus_coded_' + dir_name + '_citing_cited.csv'
        graclus_nodes = pd.read_csv(graclus_nodes_path)
        graclus_clusters = graclus_nodes.merge(graclus_coded_cluster_num)
        graclus_clusters = graclus_clusters.astype({'citing':object, 'citing_id':object, 'cluster_no':object}) 
        cluster_data = graclus_clusters[['citing', 'cluster_no']].rename(columns={'citing':'scp'})
    
    nodes_path = rootdir + '/' + dir_name + '/' + dir_name + '_citing_cited.csv'
    nodes = pd.read_csv(nodes_path)

    nodes = nodes.astype({'citing':'object', 'cited':'object'})
    nodes_grouped = nodes.groupby('cited', as_index=False).agg('count').rename(columns={'citing': 'cited_counts'}).astype({'cited':'object'})
    nodes_merged = nodes.merge(nodes_grouped, left_on = 'cited', right_on = 'cited', how = 'inner')
    nodes_all_merged = nodes_merged.merge(nodes_grouped, left_on = 'citing', right_on = 'cited', how = 'outer')
    nodes_all_merged = nodes_all_merged.rename(columns={'cited_x':'cited', 'cited_counts_x':'cited_counts', 'cited_counts_y':'citing_counts'})[['citing', 'cited', 'cited_counts', 'citing_counts']]
    nodes_all_merged = nodes_all_merged.fillna(0)
    nodes_final = nodes_all_merged[['cited', 'cited_counts', 'citing_counts']].groupby('cited', as_index=False).agg('sum').merge(nodes_all_merged[['cited', 'cited_counts']].groupby('cited', as_index=False).agg('count'), left_on='cited', right_on='cited', how='inner')
    nodes_final = nodes_final[nodes_final['cited']!=0].rename(columns={'cited':'scp', 'cited_counts_x':'sum_cited', 'citing_counts':'sum_citing', 'cited_counts_y':'total_cited'})
    nodes_final['article_score'] = nodes_final['sum_citing'] + (nodes_final['sum_cited']/nodes_final['total_cited'])

    cluster_scores = nodes_final.merge(cluster_data, left_on='scp', right_on='scp', how='inner').sort_values(by='cluster_no')

    save_name = '/erniedev_data3/theta_plus/imm_output/' + dir_name + '/' +  dir_name + '_article_score_' + cluster_type + '.csv'

    cluster_scores.to_csv(save_name, index = None, header=True, encoding='utf-8')

print("All completed.")
import os
import pandas as pd
from sys import argv

rootdir = '/erniedev_data3/theta_plus/imm/'
dir_list = sorted(os.listdir(rootdir))
cluster_type = argv[1]

#tmp_dir_list = ['imm1985', 'imm1990', 'imm1995']
#for dir_name in tmp_dir_list:
for dir_name in dir_list:
    print(f'Working on {dir_name}')

    if cluster_type == 'unshuffled':
        cluster_path = rootdir + dir_name + '/dump.' + dir_name + '_testcase_asjc2403_citing_cited.mci.I20.csv'
    elif cluster_type == 'shuffled':
        cluster_path = rootdir + dir_name + '/dump.' + dir_name + '_testcase_asjc2403_citing_cited_shuffled_1million.I20.csv'
    nodes_path = rootdir + dir_name + '/' + dir_name + '_testcase_asjc2403_citing_cited.csv'

    cluster_data = pd.read_csv(cluster_path)
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

    save_name = '/home/shreya/mcl_jsd/immunology/article_score_output_' + dir_name + '_' + cluster_type + '.csv'

    cluster_scores.to_csv(save_name, index = None, header=True, encoding='utf-8')

print("All completed.")
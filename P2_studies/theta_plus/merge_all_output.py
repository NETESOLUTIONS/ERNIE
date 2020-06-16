import pandas as pd
import os
from sys import argv

rootdir = '/erniedev_data3/theta_plus/imm_output'
dir_list = sorted(os.listdir(rootdir))
cluster_type = argv[1]

for dir_name in dir_list:
    print(f'Working on {dir_name}')

    article_score_path = rootdir + '/' + dir_name + '/' + dir_name + '_article_score_' + cluster_type + '.csv'
    conductance_path = rootdir + '/' + dir_name + '/' + dir_name + '_conductance_' + cluster_type + '.csv'
    coherence_path = rootdir + '/' + dir_name + '/' + dir_name + '_JSD_final_result_' + cluster_type + '.csv'
    article_score_file = pd.read_csv(article_score_path)
    conductance_file = pd.read_csv(conductance_path)
    coherence_file = pd.read_csv(coherence_path)
    

    grouped_article_score_sum = article_score_file[['cluster_no', 'article_score']].groupby('cluster_no', as_index=False).sum().rename(columns={'article_score':'sum_article_score'})
    grouped_article_score_max = article_score_file[['cluster_no', 'article_score']].groupby('cluster_no', as_index=False).max().rename(columns={'article_score':'max_article_score'})
    grouped_article_score_median = article_score_file[['cluster_no', 'article_score']].groupby('cluster_no', as_index=False).median().rename(columns={'article_score':'median_article_score'})
    grouped_article_score = grouped_article_score_sum.merge(grouped_article_score_max).merge(grouped_article_score_median)
    
    conductance_file = conductance_file.rename(columns={'cluster':'cluster_no', 'cluster_counts':'cluster_size'})
    coherence_file = coherence_file.rename(columns={'cluster':'cluster_no', 'jsd_coherence':'coherence', 'pre_jsd_size':'jsd_size'})
    all_merged = conductance_file[['cluster_no', 'cluster_size', 'conductance']].merge(grouped_article_score, how='left').merge(coherence_file[['cluster_no', 'jsd_size', 'mean_jsd', 'coherence']], how ='left')
    
    save_name = rootdir + '/' + dir_name + '/' + dir_name + '_all_merged_' + cluster_type + '.csv'
    
    all_merged.to_csv(save_name, index = None, header=True, encoding='utf-8')

print("All Completed.")
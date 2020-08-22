#!/usr/bin/env python3
"""
@author: Shreya Chandrasekharan

This script combines the evaluation metrics - conductance and article
scores - computed for given clusters. We need the output from compute_conductance.py 
and compute_article_score.py to run this script for any clustering. 
The final output is stored both on the database and the server.

Argument(s): rootdir          - The directory where all cluster-scp list information is stored
             cluster_type     - The type of cluster to process - (shuffled, unshuffled, graclus)
             user_name        - Database username
             password         - Database password
             
Output:      all_merged       - Final dataframe of both evaluation metrics for a clustering
"""

import pandas as pd
from sys import argv
from sqlalchemy import create_engine

rootdir = '/erniedev_data3/sb_plus_triplets/mcl'

cluster_type = argv[1]
user_name = argv[2]
password = argv[3]
schema = "sb_plus_triplets"
sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)

article_score_path = rootdir + "/output_I20/triplets_cited" + '_article_score_' + cluster_type + '.csv'
conductance_path = rootdir + "/output_I20/triplets_cited" + '_conductance_' + cluster_type + '.csv'

article_score_file = pd.read_csv(article_score_path)
conductance_file = pd.read_csv(conductance_path)

grouped_article_score_sum = article_score_file[['cluster_no', 'article_score']].groupby('cluster_no', as_index=False).sum().rename(columns={'article_score':'sum_article_score'})
grouped_article_score_max = article_score_file[['cluster_no', 'article_score']].groupby('cluster_no', as_index=False).max().rename(columns={'article_score':'max_article_score'})
grouped_article_score_median = article_score_file[['cluster_no', 'article_score']].groupby('cluster_no', as_index=False).median().rename(columns={'article_score':'median_article_score'})
grouped_article_score = grouped_article_score_sum.merge(grouped_article_score_max).merge(grouped_article_score_median)

conductance_file = conductance_file.rename(columns={'cluster':'cluster_no', 'cluster_counts':'cluster_size'})

all_merged = conductance_file[['cluster_no', 'cluster_size', 'int_edges', 'boundary', 'conductance']].merge(grouped_article_score, how='left')

save_name = rootdir + "/output_I20/triplets_cited" + "_all_merged_" + cluster_type + ".csv"
all_merged.to_csv(save_name, index = None, header=True, encoding='utf-8')
save_name_sql = 'triplets_cited' + '_all_merged_' + cluster_type
all_merged.to_sql(save_name_sql, con=engine, schema=schema, index=False, if_exists='fail')

print("All Completed.")
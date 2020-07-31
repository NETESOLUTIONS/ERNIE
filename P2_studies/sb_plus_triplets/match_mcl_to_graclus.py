import pandas as pd
from sqlalchemy import create_engine
from sys import argv
import numpy as np

user_name = argv[1]
password = argv[2]
rootdir = '/erniedev_data3/sb_plus_triplets/mcl'
schema = "sb_plus_triplets"
sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)
start_cluster_num = int(argv[3])

mcl_clusters_query = "SELECT * FROM sb_plus_triplets.triplets_cited_all_merged_unshuffled ORDER BY cluster_no;"
mcl_clusters = pd.read_sql(mcl_clusters_query, con=engine)

for cluster_num in range(start_cluster_num, len(mcl_clusters)+1):
    mcl_data_query = "SELECT * FROM sb_plus_triplets.triplets_cited_cluster_scp_list_unshuffled WHERE cluster_no = " + str(cluster_num) + ";"
    mcl_data = pd.read_sql(mcl_data_query, con=engine)
    mcl_cluster_size = len(mcl_data)
    common_nodes = mcl_data['scp'].to_list()
    graclus_query = "SELECT * FROM sb_plus_triplets.triplets_cited_cluster_scp_list_graclus;"
    graclus_data = pd.read_sql(graclus_query, con=engine)

    common_graclus_clusters = list(set(graclus_data['cluster_no'][graclus_data['scp'].isin(common_nodes)].to_list()))
    merged_data_intersect = mcl_data[['scp']].merge(graclus_data[graclus_data['cluster_no'].isin(common_graclus_clusters)], how='inner')

    grouped_merged_data_intersect = merged_data_intersect.groupby(by='cluster_no', as_index=False).agg('count')
    max_match_count = int(grouped_merged_data_intersect['scp'].max())

    graclus_cluster_no = grouped_merged_data_intersect.set_index('scp').at[max_match_count, 'cluster_no']
    if type(graclus_cluster_no) == np.int64:
        graclus_cluster_size = len(graclus_data[graclus_data['cluster_no'] == graclus_cluster_no])
        indicator = 0
    elif type(graclus_cluster_no) == np.ndarray:
        graclus_cluster_no = graclus_cluster_no[0]
        graclus_cluster_size = len(graclus_data[graclus_data['cluster_no'] == graclus_cluster_no])
        indicator = 1

    graclus_to_mcl_ratio = round(graclus_cluster_size/mcl_cluster_size, 3)

    graclus_cluster_query = "SELECT * FROM sb_plus_triplets.triplets_cited_cluster_scp_list_graclus WHERE cluster_no = " + str(graclus_cluster_no) + ";"
    graclus_cluster_data = pd.read_sql(graclus_cluster_query, con=engine)

    merged_data_union = mcl_data[['scp']].merge(graclus_cluster_data[['scp']], how='outer')
    
    graclus_all_merged_query = "SELECT * FROM sb_plus_triplets.triplets_cited_all_merged_graclus WHERE cluster_no = " + str(graclus_cluster_no) + ";"
    graclus_all_merged = pd.read_sql(graclus_all_merged_query, con=engine)
    
    result_dict = {'mcl_cluster_no': int(cluster_num), 
                   'mcl_cluster_size': int(mcl_cluster_size),
                   'graclus_cluster_no': int(graclus_cluster_no), 
                   'graclus_cluster_size' : int(graclus_cluster_size),
                   'graclus_to_mcl_ratio': graclus_to_mcl_ratio,
                   'total_intersection': max_match_count,
                   'total_union': len(merged_data_union),
                   'intersect_union_ratio': round(max_match_count/len(merged_data_union), 4),
                   'multiple_options': [indicator],
                   'mcl_int_edges': mcl_clusters.set_index('cluster_no').at[cluster_num, 'int_edges'], 
                   'mcl_boundary': mcl_clusters.set_index('cluster_no').at[cluster_num, 'boundary'],
                   'mcl_conductance': mcl_clusters.set_index('cluster_no').at[cluster_num, 'conductance'],
                   'mcl_sum_article_score': mcl_clusters.set_index('cluster_no').at[cluster_num, 'sum_article_score'], 
                   'mcl_max_article_score': mcl_clusters.set_index('cluster_no').at[cluster_num, 'max_article_score'], 
                   'mcl_median_article_score': mcl_clusters.set_index('cluster_no').at[cluster_num, 'median_article_score'],
                   'graclus_int_edges': graclus_all_merged.set_index('cluster_no').at[graclus_cluster_no, 'int_edges'], 
                   'graclus_boundary': graclus_all_merged.set_index('cluster_no').at[graclus_cluster_no, 'boundary'],
                   'graclus_conductance': graclus_all_merged.set_index('cluster_no').at[graclus_cluster_no, 'conductance'],
                   'graclus_sum_article_score':  graclus_all_merged.set_index('cluster_no').at[graclus_cluster_no, 'sum_article_score'],
                   'graclus_max_article_score': graclus_all_merged.set_index('cluster_no').at[graclus_cluster_no, 'max_article_score'], 
                   'graclus_median_article_score': graclus_all_merged.set_index('cluster_no').at[graclus_cluster_no, 'median_article_score'],
                   }
    
    result_df = pd.DataFrame.from_dict(result_dict)
    result_df.to_sql('triplets_cited_mcl_to_graclus', schema=schema, con=engine, if_exists='append', index=False)

print("All Completed.") 
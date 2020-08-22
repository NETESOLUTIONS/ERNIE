#!/usr/bin/env python3
"""
@author: Shreya Chandrasekharan

This script outputs the cluster-scp list of graclus clusters.
The final output has two columns - cluster number and scp which is 
then stored both in the database and on the sevrer.

Argument(s): rootdir               - The directory where all graclus data are stored
             user_name             - Database username
             password              - Database password
 
Output:      cluster_data          - Final cluster-scp list
"""

import pandas as pd
from sys import argv
from glob import glob
from sqlalchemy import create_engine

user_name = argv[1]
password = argv[2]
rootdir = rootdir = '/erniedev_data3/sb_plus_triplets/mcl/'
schema = "sb_plus_triplets"
sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)

graclus_coded_cluster_num_path = rootdir + "/output_I20/" + '/graclus_triplets_cited.csv.part.6021'
graclus_coded_cluster_num = pd.read_csv(glob(graclus_coded_cluster_num_path)[0], header=None)
graclus_coded_cluster_num.columns = ['cluster_no']
graclus_coded_cluster_num['citing_id'] = range(1, len(graclus_coded_cluster_num)+1)
graclus_nodes_path = rootdir + "/output_I20/" + "/graclus_coded_triplets_cited.csv"
graclus_nodes = pd.read_csv(graclus_nodes_path)
graclus_clusters = graclus_nodes.merge(graclus_coded_cluster_num)
graclus_clusters = graclus_clusters.astype({'citing':object, 'citing_id':object, 'cluster_no':object}) 
cluster_data = graclus_clusters[['citing', 'cluster_no']].rename(columns={'citing':'scp'})

save_name = 'triplets_cited_cluster_scp_list_graclus'
cluster_data.to_sql(save_name, con=engine, schema=schema, index=False, if_exists='fail')

print("All Completed.")
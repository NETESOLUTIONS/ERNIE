import pandas as pd
from sqlalchemy import create_engine
from sys import argv
from collections import Counter

schema = "theta_plus"
user_name = argv[1]
password = argv[2]
start_cluster_num = argv[3]

sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)

cluster_query = """SELECT cluster_no
FROM theta_plus.imm1985_1995_all_merged_unshuffled
WHERE cluster_size BETWEEN 30 AND 350
ORDER BY cluster_no;"""

clusters = pd.read_sql(cluster_query, con=engine)
clusters_list = clusters['cluster_no'].astype(int).tolist()

if start_cluster_num == "first":
    start_num = 0
else:                     
    start_num = clusters_list.index(int(start_cluster_num))

for cluster_num in clusters_list[start_num:]:

    external_degrees_query = """
        SELECT cslu1.cluster_no as citing_cluster, ccu.citing, ccu.cited, cslu2.cluster_no as cited_cluster
        FROM theta_plus.imm1985_1995_citing_cited_union ccu
        JOIN theta_plus.imm1985_1995_cluster_scp_list_unshuffled cslu1 ON cslu1.scp = ccu.citing
        JOIN theta_plus.imm1985_1995_cluster_scp_list_unshuffled cslu2 ON cslu2.scp = ccu.cited
        WHERE cslu1.cluster_no=""" +str(cluster_num)+ """ AND cslu1.cluster_no!=cslu2.cluster_no
        UNION
        SELECT cslu1.cluster_no as citing_cluster, ccu.citing, ccu.cited, cslu2.cluster_no as cited_cluster
        FROM theta_plus.imm1985_1995_citing_cited_union ccu
        JOIN theta_plus.imm1985_1995_cluster_scp_list_unshuffled cslu1 ON cslu1.scp = ccu.citing
        JOIN theta_plus.imm1985_1995_cluster_scp_list_unshuffled cslu2 ON cslu2.scp = ccu.cited
        WHERE cslu2.cluster_no=""" +str(cluster_num)+ """ AND cslu1.cluster_no!=cslu2.cluster_no;"""

    external_degrees = pd.read_sql(external_degrees_query, con=engine)
    all_clusters = Counter(external_degrees['citing_cluster'].tolist() + external_degrees['cited_cluster'].tolist())
    del all_clusters[cluster_num] # delete the cluster for which values are being computed
    if len(all_clusters.most_common(1)) >0:
        max_edges = all_clusters.most_common(1)[0][1]
        for k,v in all_clusters.items():
            if v == max_edges:
                result_dict = {'cluster_no': cluster_num, 
                               'max_edge_match': k, 
                               'max_edges': [v]}
                pd.DataFrame.from_dict(result_dict).to_sql('superset_30_350_connected_clusters_edges', con=engine, schema=schema, if_exists='append', index=False)

print("All Completed.")
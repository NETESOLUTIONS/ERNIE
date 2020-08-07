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

    common_authors_query = """
        SELECT DISTINCT au1.cluster_no as citing_cluster, ccu.citing, ccu.cited, au2.cluster_no as cited_cluster, au1.auid
        FROM theta_plus.imm1985_1995_citing_cited_union ccu
        JOIN theta_plus.imm1985_1995_all_authors au1 ON au1.scp = ccu.citing
        JOIN theta_plus.imm1985_1995_all_authors au2 ON au2.scp = ccu.cited
        WHERE au1.cluster_no=""" +str(cluster_num)+ """ AND au1.auid=au2.auid AND au1.cluster_no!=au2.cluster_no 
        UNION
        SELECT DISTINCT au1.cluster_no as citing_cluster, ccu.citing, ccu.cited, au2.cluster_no as cited_cluster, au1.auid
        FROM theta_plus.imm1985_1995_citing_cited_union ccu
        JOIN theta_plus.imm1985_1995_all_authors au1 ON au1.scp = ccu.citing
        JOIN theta_plus.imm1985_1995_all_authors au2 ON au2.scp = ccu.cited
        WHERE au2.cluster_no=""" +str(cluster_num)+ """ AND au1.auid=au2.auid AND au1.cluster_no!=au2.cluster_no 
        ;"""
    common_authors_df = pd.read_sql(common_authors_query, con=engine)
    common_authors = Counter(common_authors_df['auid'].tolist())
    all_clusters = Counter(common_authors_df['citing_cluster'].tolist() + common_authors_df['cited_cluster'].tolist())
    del all_clusters[cluster_num] # delete the cluster for which values are being computed
    if not common_authors_df.empty:
        max_edges = all_clusters.most_common(1)[0][1]
        for k,v in all_clusters.items():
            if v == max_edges:
                result_dict = {'cluster_no': cluster_num, 
                               'total_author_instances': len(common_authors_df),
                               'count_common_authors': len(common_authors),
                               'max_edge_match_cluster': k, 
                               'max_edges': [v]}
                pd.DataFrame.from_dict(result_dict).to_sql('superset_30_350_connected_clusters_authors', con=engine, schema=schema, if_exists='append', index=False) 

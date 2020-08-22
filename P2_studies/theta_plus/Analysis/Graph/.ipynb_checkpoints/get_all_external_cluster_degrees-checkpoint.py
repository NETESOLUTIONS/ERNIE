import pandas as pd
import networkx as nx
from sqlalchemy import create_engine
from sys import argv

schema = "theta_plus"
user_name = "shreya"
password = "Akshay<3"
sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)

cluster_query = """SELECT imm1985_1995_cluster_no
FROM theta_plus.superset_30_350_mcl_graclus_all_data
WHERE graclus_half_mclsize_intersection_union_ratio >= 0.9
  AND mcl_year_conductance <= 0.5
ORDER BY imm1985_1995_cluster_no;"""

clusters = pd.read_sql(cluster_query, con=engine)
clusters_list = clusters['imm1985_1995_cluster_no'].astype(int).tolist()
clusters_list = [1673]
for cluster_num in clusters_list:
    
    citing_cited_query="""
    SELECT cslu1.cluster_no AS citing_cluster, ccu.citing, cslu2.cluster_no AS cited_cluster, ccu.cited
    FROM theta_plus.imm1985_1995_citing_cited_union ccu
    JOIN theta_plus.imm1985_1995_cluster_scp_list_unshuffled cslu1
        ON cslu1.scp = ccu.citing
    JOIN theta_plus.imm1985_1995_cluster_scp_list_unshuffled cslu2
        ON cslu2.scp = ccu.cited
    WHERE  cslu1.cluster_no!=cslu2.cluster_no
      AND cslu1.cluster_no= """ + str(cluster_num) + """ -- all external out-degrees

    UNION SELECT cslu1.cluster_no AS citing_cluster, ccu.citing, cslu2.cluster_no AS cited_cluster, ccu.cited
    FROM theta_plus.imm1985_1995_citing_cited_union ccu
    JOIN theta_plus.imm1985_1995_cluster_scp_list_unshuffled cslu1
        ON cslu1.scp = ccu.citing
    JOIN theta_plus.imm1985_1995_cluster_scp_list_unshuffled cslu2
        ON cslu2.scp = ccu.cited
    WHERE  cslu1.cluster_no!=cslu2.cluster_no
      AND cslu2.cluster_no= """ + str(cluster_num) + """; -- all external in-degrees"""
    
    cluster_scp_query="""SELECT * 
    FROM theta_plus.imm1985_1995_cluster_scp_list_unshuffled
    WHERE cluster_no = """ + str(cluster_num) + """;"""

    citing_cited = pd.read_sql(citing_cited_query, con=engine)
    G = nx.from_pandas_edgelist(citing_cited, 'citing', 'cited', create_using=nx.DiGraph())
    N=G.order()
    degrees = dict(G.degree())
    total_deg = pd.DataFrame.from_dict(degrees, orient='index', columns=['ext_cluster_total_degrees'])
    total_deg['scp'] = total_deg.index
    total_deg = total_deg.reset_index(drop=True)

    indegrees = dict(G.in_degree())
    total_in_deg = pd.DataFrame.from_dict(indegrees, orient='index', columns=['ext_cluster_in_degrees'])
    total_in_deg['scp'] = total_in_deg.index
    total_in_deg = total_in_deg.reset_index(drop=True)

    outdegrees = dict(G.out_degree())
    total_out_deg = pd.DataFrame.from_dict(outdegrees, orient='index', columns=['ext_cluster_out_degrees'])
    total_out_deg['scp'] = total_out_deg.index
    total_out_deg = total_out_deg.reset_index(drop=True)
    
    this_cluster = pd.read_sql(cluster_scp_query, con=engine)

    scp_all = this_cluster.merge(total_deg, how='left').merge(total_in_deg, how='left').merge(total_out_deg, how='left').sort_values(by=['ext_cluster_total_degrees'], ascending=False).fillna(0)
    scp_all = scp_all[['cluster_no', 'scp', 'ext_cluster_total_degrees', 'ext_cluster_in_degrees', 'ext_cluster_out_degrees']]

    scp_all.to_sql('superset_90_iu_external_cluster_degrees', con=engine, schema=schema, if_exists='append', index=False)

print("All Completed.")


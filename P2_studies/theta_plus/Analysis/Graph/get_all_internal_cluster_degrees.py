import pandas as pd
import networkx as nx
from sqlalchemy import create_engine
from sys import argv

schema = "theta_plus"
user_name = argv[1]
password = argv[2]
sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)

## For only those clusters with graclus intersect_union_ratio >= 0.9
# cluster_query = """SELECT imm1985_1995_cluster_no
# FROM theta_plus.superset_30_350_mcl_graclus_all_data
# WHERE graclus_half_mclsize_intersection_union_ratio >= 0.9
# ORDER BY imm1985_1995_cluster_no;"""

# For all superset clusters
cluster_query = """SELECT cluster_no
FROM theta_plus.imm1985_1995_all_merged_unshuffled
ORDER BY cluster_no;"""

clusters = pd.read_sql(cluster_query, con=engine)
clusters_list = clusters['cluster_no'].astype(int).tolist()

for cluster_num in clusters_list:
    
    citing_cited_query="""
    SELECT cslu1.cluster_no , ccu.citing, ccu.cited
    FROM theta_plus.imm1985_1995_citing_cited_union ccu
    JOIN theta_plus.imm1985_1995_cluster_scp_list_unshuffled cslu1
        ON cslu1.scp = ccu.citing
    JOIN theta_plus.imm1985_1995_cluster_scp_list_unshuffled cslu2
        ON cslu2.scp = ccu.cited
    WHERE cslu1.cluster_no=""" +str(cluster_num)+ """ AND cslu1.cluster_no=cslu2.cluster_no;"""

    citing_cited = pd.read_sql(citing_cited_query, con=engine)
    G = nx.from_pandas_edgelist(citing_cited, 'citing', 'cited', create_using=nx.DiGraph())

    N=G.order()
    degrees = dict(G.degree())
    total_deg = pd.DataFrame.from_dict(degrees, orient='index', columns=['int_cluster_total_degrees'])
    total_deg['scp'] = total_deg.index
    total_deg = total_deg.reset_index(drop=True)

    deg_cent = pd.DataFrame.from_dict(nx.degree_centrality(G), orient='index', columns=['int_cluster_total_degree_centrality'])
    deg_cent['scp'] = deg_cent.index
    deg_cent = deg_cent.reset_index(drop=True)

    indegrees = dict(G.in_degree())
    total_in_deg = pd.DataFrame.from_dict(indegrees, orient='index', columns=['int_cluster_in_degrees'])
    total_in_deg['scp'] = total_in_deg.index
    total_in_deg = total_in_deg.reset_index(drop=True)

    in_deg_cent = pd.DataFrame.from_dict(nx.in_degree_centrality(G), orient='index', columns=[ 'int_cluster_in_degree_centrality'])
    in_deg_cent['scp'] = in_deg_cent.index
    in_deg_cent = in_deg_cent.reset_index(drop=True)

    outdegrees = dict(G.out_degree())
    total_out_deg = pd.DataFrame.from_dict(outdegrees, orient='index', columns=['int_cluster_out_degrees'])
    total_out_deg['scp'] = total_out_deg.index
    total_out_deg = total_out_deg.reset_index(drop=True)

    out_deg_cent = pd.DataFrame.from_dict(nx.out_degree_centrality(G), orient='index', columns=[ 'int_cluster_out_degree_centrality'])
    out_deg_cent['scp'] = out_deg_cent.index
    out_deg_cent = out_deg_cent.reset_index(drop=True)

    scp_all = deg_cent.merge(total_deg).merge(total_in_deg).merge(total_out_deg).merge(in_deg_cent).merge(out_deg_cent).sort_values(by=['int_cluster_total_degree_centrality'], ascending=False)
    scp_all['cluster_no'] = cluster_num
    scp_all = scp_all[['cluster_no', 'scp', 'int_cluster_total_degrees', 'int_cluster_in_degrees', 'int_cluster_out_degrees', 'int_cluster_total_degree_centrality' , 'int_cluster_in_degree_centrality', 'int_cluster_out_degree_centrality']]
    scp_all.to_sql('imm1985_1995_internal_cluster_degrees', con=engine, schema=schema, if_exists='append', index=False)

print("All Completed.")


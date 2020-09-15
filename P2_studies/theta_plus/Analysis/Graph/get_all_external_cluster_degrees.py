import pandas as pd
import networkx as nx
from sqlalchemy import create_engine
from sys import argv

data_type = argv[1] # 'imm' or 'eco'
start_year = str(argv[2])
end_year = str(argv[3])
cluster_type = argv[4]
schema = argv[5]
user_name = argv[6]
password = argv[7]
sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)

data_table = data_type + start_year + '_' + end_year
cluster_table_name = data_table + '_cluster_scp_list_' + cluster_type
cluster_table_query = """
                    SELECT *
                    FROM """ + schema + """.""" + cluster_table_name + """
                    ORDER BY cluster_no ASC;"""

clusters = pd.read_sql(cluster_table_query, con=engine)
clusters_grouped = clusters.groupby(by='cluster_no', as_index=False).agg('count')
clusters_list = clusters_grouped['cluster_no'].astype('object').tolist()

save_name = data_table + '_external_cluster_degrees'
for cluster_num in clusters_list:
    
    citing_cited_query="""
    SELECT cslu1.cluster_no AS citing_cluster, cc.citing, cslu2.cluster_no AS cited_cluster, cc.cited
    FROM """ + schema + """.""" + data_table + """_citing_cited cc
    JOIN """ + schema + """.""" + cluster_table_name + """ cslu1
        ON cslu1.scp = cc.citing
    JOIN """ + schema + """.""" + cluster_table_name + """ cslu2
        ON cslu2.scp = cc.cited
    WHERE  cslu1.cluster_no!=cslu2.cluster_no
      AND cslu1.cluster_no= """ + str(cluster_num) + """ -- all external out-degrees

    UNION SELECT cslu1.cluster_no AS citing_cluster, cc.citing, cslu2.cluster_no AS cited_cluster, cc.cited
    FROM """ + schema + """.""" + data_table + """_citing_cited cc
    JOIN """ + schema + """.""" + cluster_table_name + """ cslu1
        ON cslu1.scp = cc.citing
    JOIN """ + schema + """.""" + cluster_table_name + """ cslu2
        ON cslu2.scp = cc.cited
    WHERE  cslu1.cluster_no!=cslu2.cluster_no
      AND cslu2.cluster_no= """ + str(cluster_num) + """; -- all external in-degrees"""
    
    cluster_scp_query="""SELECT * 
    FROM """ + schema + """.""" + cluster_table_name + """
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

    scp_all.to_sql(save_name, con=engine, schema=schema, if_exists='append', index=False)

print("All Completed.")


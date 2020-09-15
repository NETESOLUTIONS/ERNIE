import pandas as pd
import networkx as nx
from sqlalchemy import create_engine
from sys import argv

data_type = argv[1] # 'imm' or 'eco'
start_year = str(argv[2])
end_year = str(argv[3])
schema = argv[4]
user_name = argv[5]
password = argv[6]
sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)

data_table = data_type + start_year + '_' + end_year
citing_cited_table = data_table + '_citing_cited'
citing_cited = pd.read_sql_table(table_name = citing_cited_table, schema = schema, con=engine)
G = nx.from_pandas_edgelist(citing_cited, 'citing', 'cited', create_using=nx.DiGraph())
N = G.order()

degrees = dict(G.degree())
total_deg = pd.DataFrame.from_dict(degrees, orient='index', columns=['graph_total_degrees'])
total_deg['scp'] = total_deg.index
total_deg = total_deg.reset_index(drop=True)

indegrees = dict(G.in_degree())
total_in_deg = pd.DataFrame.from_dict(indegrees, orient='index', columns=['graph_in_degrees'])
total_in_deg['scp'] = total_in_deg.index
total_in_deg = total_in_deg.reset_index(drop=True)

outdegrees = dict(G.out_degree())
total_out_deg = pd.DataFrame.from_dict(outdegrees, orient='index', columns=['graph_out_degrees'])
total_out_deg['scp'] = total_out_deg.index
total_out_deg = total_out_deg.reset_index(drop=True)

scp_all = total_deg.merge(total_in_deg).merge(total_out_deg).sort_values(by=['graph_total_degrees'], ascending=False)
scp_all = scp_all[['scp', 'graph_total_degrees', 'graph_in_degrees', 'graph_out_degrees']]

save_name = data_table + '_full_graph_degrees'
scp_all.to_sql(save_name, con=engine, schema=schema, if_exists='append', index=False)
print("All Completed.")
import pandas as pd
from sys import argv

year_table = argv[1]
year_table_name = year_table + '.csv'
citing_cited_table_name = argv[2] + '.csv'
nodes_table = argv[3]
nodes_table_name = argv[3] + '.csv'

citing_cited = pd.read_csv(citing_cited_table_name)
nodes = pd.read_csv(nodes_table_name)

# Convert SCPs to 0-indexed values
nodes = nodes.sort_values(by='scp', ascending=True).reset_index(drop=True) # reproducibility
nodes['new_scp'] = nodes.index
citing_cited = citing_cited.merge(nodes, left_on='citing', right_on='scp', how='inner')
citing_cited = citing_cited.rename(columns={'new_scp':'new_citing'}).drop('scp', axis=1)
citing_cited = citing_cited.merge(nodes, left_on='cited', right_on='scp', how='inner')
citing_cited = citing_cited.rename(columns={'new_scp':'new_cited'}).drop('scp', axis=1)

# Save as tab-separated text file

save_name_citing_cited = year_table + '_leiden_input.txt'
citing_cited[['new_citing', 'new_cited']].to_csv(save_name_citing_cited, index=False, header=False, sep='\t')
save_name_nodes = nodes_table + '_coded.csv' 
nodes.to_csv(save_name_nodes, index=False, header=True)
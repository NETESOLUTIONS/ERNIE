import pandas as pd
from sys import argv
from tabulate import tabulate

leiden_output = argv[1]

clusters = pd.read_csv(leiden_output, sep='\t', names=['new_scp', 'cluster_no'])
clusters = clusters.astype('object')
nodes_coded = pd.read_csv("imm1985_nodes_coded.csv")
nodes_coded = nodes_coded.astype('object')
final_clusters = clusters.merge(nodes_coded, left_on='new_scp', right_on='new_scp', how='inner').drop(columns='new_scp')

name = leiden_output[:-4]
save_name = name + '.csv'
final_clusters.to_csv(save_name, index=False, header=True)

print('Final output saved.')

clusters_grouped = final_clusters.groupby(by='cluster_no', as_index=False).agg('count').sort_values(by='scp', ascending=False)

print("")
print(f"Cluster size distribution for {name}")
print(tabulate(clusters_grouped[['scp']].describe(), headers=['', 'cluster_sizes'], tablefmt='pretty'))
print("")
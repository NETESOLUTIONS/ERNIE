import pandas as pd
from sys import argv
from tabulate import tabulate

leiden_output = argv[1]
nodes_coded = argv[2]

clusters = pd.read_csv(leiden_output, sep='\t', names=['new_scp', 'cluster_no'])
clusters = clusters.astype('object')
nodes = pd.read_csv(nodes_coded)
nodes = nodes.astype('object')
final_clusters = clusters.merge(nodes, left_on='new_scp', right_on='new_scp', how='inner').drop(columns='new_scp')

name = leiden_output[:-4]
save_name = name + '.csv'
final_clusters.to_csv(save_name, index=False, header=True)

print('Final output saved.')

clusters_grouped = final_clusters.groupby(by='cluster_no', as_index=False).agg('count').sort_values(by='scp', ascending=False)

print("")
print(f"Cluster size distribution for {name}")
print(tabulate(clusters_grouped[['scp']].describe(), headers=['', 'cluster_sizes'], tablefmt='pretty'))
print("")
print(f"The number of clusters between size 30 and 350 is {len(clusters_grouped[(clusters_grouped['scp'] >= 30) & (clusters_grouped['scp'] <= 350)])}")
print("")
print("")
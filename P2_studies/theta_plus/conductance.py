import pandas as pd
import psycopg2

with open('/Users/shreya/Documents/ernie_password.txt') as f:
    ernie_password = f.readline()

conn=psycopg2.connect(database="ernie",user="shreya",host="localhost",password=ernie_password)
conn.set_client_encoding('UTF8')
conn.autocommit=True
curs=conn.cursor()

# Set schema
schema = "theta_plus"
set_schema = "SET SEARCH_PATH TO " + schema + ";"   
curs.execute(set_schema)


weights = ['ncf', 'now', 'sf'] 
inflation = ['20', '30', '40', '60']

# all_data_table = 'dc_bc_merged'


for name in weights:
    for val in inflation:
        
        cluster_table = name + '_' + str(val) + '_ids'

        print("Querying: ", cluster_table)

        query1 = "select dbm.cited_1, dbm.cited_2, clt1.cluster as cited_1_cluster, clt2.cluster as cited_2_cluster from dc_bc_merged as dbm join " + cluster_table + " as clt1 on dbm.cited_1 = clt1.scp join " + cluster_table + " as clt2 on dbm.cited_2 = clt2.scp"
        query2 = "select cluster, count(cluster) as cluster_counts from " + cluster_table + " group by cluster order by cluster;"
        
        conductance_data = pd.read_sql(query1, conn)
        counts_data = pd.read_sql(query2, conn)
        
        x1 = conductance_data[conductance_data.cited_2_cluster != conductance_data.cited_1_cluster][['cited_1', 'cited_1_cluster']].groupby('cited_1_cluster', as_index=False).agg('count').rename(columns = {'cited_1': 'ext_out'})
        x2 = conductance_data[conductance_data.cited_2_cluster != conductance_data.cited_1_cluster][['cited_2', 'cited_2_cluster']].groupby('cited_2_cluster', as_index=False).agg('count').rename(columns = {'cited_2': 'ext_in'})
        x3 = conductance_data[conductance_data.cited_2_cluster == conductance_data.cited_1_cluster][['cited_1', 'cited_2_cluster']].groupby('cited_2_cluster', as_index=False).agg('count').rename(columns = {'cited_1': 'int_edges'})
        x1_clusters = counts_data.merge(x1, left_on = 'cluster', right_on = 'cited_1_cluster', how = 'left')[['cluster', 'ext_out']]
        x1_clusters = x1_clusters.fillna(0)
        x2_clusters = counts_data.merge(x2, left_on = 'cluster', right_on = 'cited_2_cluster', how = 'left')[['cluster', 'ext_in']]
        x2_clusters = x2_clusters.fillna(0)
        x3_clusters = counts_data.merge(x3, left_on = 'cluster', right_on = 'cited_2_cluster', how = 'left')[['cluster', 'int_edges']]
        x3_clusters = x3_clusters.fillna(0)
        x4 = x1_clusters.merge(x2_clusters, left_on='cluster', right_on='cluster', how = 'inner')
        x5 = x4.merge(x3_clusters, left_on='cluster', right_on='cluster')
        x5['boundary'] = x5['ext_in'] + x5['ext_out']
        x5['volume'] = x5['ext_in'] + x5['ext_out'] + 2*x5['int_edges']
        x5['two_m'] = conductance_data.shape[0]*2
        x5['alt_denom'] = x5['two_m'] - x5['volume']
        x5['denom'] = x5[['alt_denom', 'volume']].min(axis=1)
        x5['conductance'] = round((x5['boundary']/x5['denom']), 2)

        save_name = '/Users/shreya/Documents/mcl_jsd/conductance/' + name + '_' + str(val) + '_conductance.csv'

        print("Done. Saving to CSV.")
        
        x5.to_csv(save_name, index = None, header=True, encoding='utf-8')


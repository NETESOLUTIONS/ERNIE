import pandas as pd
from sqlalchemy import create_engine
from sys import argv

schema = "theta_plus"
user_name = argv[1]
password = argv[2]
start_cluster_num = argv[3]

sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)

cluster_query = """SELECT cluster_no, cluster_size, num_authors
FROM theta_plus.imm1985_1995_all_merged_mcl
ORDER BY cluster_no ASC;"""

clusters = pd.read_sql(cluster_query, con=engine)
clusters_list = clusters['cluster_no'] #[(clusters['cluster_size'] >= 30) & (clusters['cluster_size'] <= 350)].astype(int).tolist()

if start_cluster_num == "first":
    start_num = 0
else:                     
    start_num = clusters_list.index(int(start_cluster_num))

for cluster_num in clusters_list[start_num:]:
    
    common_authors_query = """
        SELECT cluster_no, count(auid) as count_common_authors
        FROM theta_plus.imm1985_1995_authors_clusters_mcl
        WHERE cluster_no!=""" +str(cluster_num)+ """ AND
              auid IN (SELECT auid
                       FROM theta_plus.imm1985_1995_authors_clusters_mcl
                       WHERE cluster_no=""" +str(cluster_num)+ """)
        GROUP BY cluster_no;"""

    common_authors = pd.read_sql(common_authors_query, con=engine)
    num_authors = clusters.set_index('cluster_no').at[cluster_num, 'num_authors']
    cluster_size = clusters.set_index('cluster_no').at[cluster_num, 'cluster_size']

    all_clusters = common_authors.set_index('cluster_no').to_dict()['count_common_authors']

    for k,v in all_clusters.items():
        if (v / num_authors) >= 0.05:

            connected_cluster_size = clusters.set_index('cluster_no').at[k, 'cluster_size']
            connected_cluster_num_authors = clusters.set_index('cluster_no').at[k, 'num_authors']

            result_dict = {'cluster_no':cluster_num,
                           'cluster_size': cluster_size,
                           'cluster_num_authors': num_authors,
                           'connected_cluster_no':k, 
                           'connected_cluster_size': connected_cluster_size,
                           'connected_cluster_num_authors': connected_cluster_num_authors,
                           'count_common_authors': [v]}

            pd.DataFrame.from_dict(result_dict).to_sql('superset_30_350_connected_clusters_authors', con=engine, schema=schema, if_exists='append', index=False)


print("All Completed.")
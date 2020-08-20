import pandas as pd
from sqlalchemy import create_engine
from sys import argv
from math import floor

schema = "theta_plus"
user_name = argv[1]
password = argv[2]
start_cluster_num = argv[3]

sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)

cluster_number_query = """SELECT cluster_no
FROM theta_plus.imm1985_1995_all_merged_unshuffled
ORDER BY cluster_no ASC;"""

cluster_number = pd.read_sql(cluster_number_query, con=engine)
cluster_number_list = cluster_number['cluster_no'] 

if start_cluster_num == "first":
    start_num = 0
else:                     
    start_num = cluster_number_list.index(int(start_cluster_num))

for cluster_num in cluster_number_list[start_num:]:
       
    cluster_query = """
        SELECT cluster_no, scp, cluster_total_degrees, 
            cluster_in_degrees, cluster_out_degrees, auid
        FROM theta_plus.imm1985_1995_all_authors_internal
        WHERE cluster_no = """ + str(cluster_num) + """;"""

    cluster = pd.read_sql(cluster_query, con=engine)
    
    if len(cluster) > 0: 
        cluster_scps = cluster.drop('auid', axis=1).drop_duplicates().sort_values(by='cluster_in_degrees', 
                                                                                  ascending=False).reset_index(drop=True)

        index = floor(len(cluster_scps)*0.10)
        ten_percent = cluster_scps.at[index, 'cluster_in_degrees']

        if len(cluster_scps[cluster_scps['cluster_in_degrees'] == ten_percent]) > index:
          # limiting to not exceed top ten percent counts  
            final_ten_percent = ten_percent + 1
        else:
            final_ten_percent = ten_percent

        cluster_scps['tier'] = None

        for i in range(len(cluster_scps)):
            if cluster_scps.at[i, 'cluster_in_degrees'] >= final_ten_percent:
                cluster_scps.at[i, 'tier'] = 1
            elif cluster_scps.at[i, 'cluster_in_degrees'] == 0:
                cluster_scps.at[i, 'tier'] = 3
            else:
                cluster_scps.at[i, 'tier'] = 2

        tier_cluster = cluster.merge(cluster_scps[['scp', 'tier']], 
                                     left_on='scp', 
                                     right_on = 'scp',
                                     how='left').sort_values(by=['cluster_in_degrees', 'scp'],
                                                             ascending=False).reset_index(drop=True)

        tier_cluster.to_sql('imm1985_1995_article_tiers', con=engine, schema=schema, index=False, if_exists='append')

print("Article Tiers: All Completed.")


Article Tiers:
    
    For each cluster, we take the top ten percent of articles by citations received. The citation count at the tenth pecent is our threshold value and the number of articles at the tenth percent (ten percent of cluster size) is the threshold count. We then calculate the total number of articles in the cluster that have received citations greater than or equal to the threshold value. If the number of articles exceeds the threshold count, we increase the threshold value by 1 and denote it by final threshold value. Any article that receives citations greater than or equal to the final threshold value is labelled as Tier 1, any article that receives no citation at all in the cluster is labelled at Tier 3, and all articles in between that receive at least 1 citation, but fewer than the threshold value are labelled as Tier 2. Note that, in this method, we may have articles that receive only one citation under Tier 1.
    
Author Tiers:
    
    For each author in each cluster, we take the minimum value tier value received by the author as their tier value for that cluster.  
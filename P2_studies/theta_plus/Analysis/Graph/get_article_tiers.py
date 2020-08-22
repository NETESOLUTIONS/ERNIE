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
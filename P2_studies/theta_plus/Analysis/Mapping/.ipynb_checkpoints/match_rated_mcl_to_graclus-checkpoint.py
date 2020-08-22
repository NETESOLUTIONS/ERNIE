import pandas as pd
from sqlalchemy import create_engine
from sys import argv
import swifter
import jsd_modules as jm
import multiprocessing as mp

user_name = argv[1]
password = argv[2]
rootdir = "/erniedev_data3/theta_plus/imm_output"
rated_table = "expert_ratings"
schema = "theta_plus"
sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)

rated_data = pd.read_sql_table(table_name=rated_table, schema=schema, con=engine)
p = mp.Pool(6)
save_name = rootdir + '/imm1985_1995/rated_mcl_match_graclus.csv'

columns = ['imm1985_1995_cluster_no', 'match_year', 'mcl_cluster_no', 
           'mcl_cluster_size', 'total_intersection', 'max_match_count', 
           'max_match_prop', 'graclus_cluster_no', 'graclus_cluster_size']
final_df = pd.DataFrame(columns=columns)

for i in range(len(rated_data)):
    
    result_df = rated_data[i:i+1]
    match_dict = p.starmap(jm.match_mcl_to_graclus, [(result_df['imm1985_1995_cluster_no'], rated_data)])
    match_df = pd.DataFrame.from_dict(match_dict)
    final_df = final_df.append(match_df, ignore_index=True)

final_df.to_csv(save_name, index = None, header=True, encoding='utf-8')
print("All Completed.") 
    
# In case the connection times out:
engine = create_engine(sql_scheme)

save_name_sql = 'rated_to_graclus'
final_df.to_sql(save_name_sql, con=engine, schema=schema, index=False, if_exists='replace')
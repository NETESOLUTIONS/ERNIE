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
match_dict = p.starmap(jm.match_mcl_to_graclus, [(rated_data['imm1985_1995_cluster_no'], rated_data)])
match_df = pd.DataFrame(match_dict)
match_df.to_csv(save_name, mode = 'a', index = None, header=False, encoding='utf-8')
print("All Completed.")  
    
# In case the connection times out:
# engine = create_engine(sql_scheme)

# match_df.to_sql(save_name, con=engine, schema=schema, index=False, if_exists='fail')
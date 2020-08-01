import pandas as pd
from sqlalchemy import create_engine
from sys import argv
import swifter
import jsd_modules as jm
import multiprocessing as mp

user_name = argv[1]
password = argv[2]
start_cluster_num = int(argv[3])
rootdir = "/erniedev_data3/theta_plus/imm"
schema = "theta_plus"
sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)

p = mp.Pool(6)

tmp_dir_list = ['imm1986']
for dir_name in tmp_dir_list:
#for dir_name in dir_list:
    print(f'Working on {dir_name}')
    mcl_clusters_query = "SELECT cluster_no FROM theta_plus." + dir_name + "_all_merged_unshuffled;"
    mcl_clusters = pd.read_sql(mcl_clusters_query, con=engine)
    
    for cluster_num in range(start_cluster_num, len(mcl_clusters)+1):
        match_dict = p.starmap(jm.match_mcl_to_graclus, [(dir_name, cluster_num)])
        match_df = pd.DataFrame.from_dict(match_dict)
        # In case the connection times out:
        #engine = create_engine(sql_scheme)
        save_name_sql = dir_name + '_match_to_graclus'
        match_df.to_sql(save_name_sql, con=engine, schema=schema, index=False, if_exists='append')
    print(f'Done with {dir_name}.')

print("All Completed.") 
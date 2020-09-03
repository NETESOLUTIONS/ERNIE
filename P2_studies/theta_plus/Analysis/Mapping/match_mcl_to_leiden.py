import pandas as pd
import mapping_module as mm
import multiprocessing as mp
from sqlalchemy import create_engine
from sys import argv

user_name = argv[1]
password = argv[2]
data_type = argv[3]
start_year = int(argv[4])
end_year = int(argv[5])
leiden_input = argv[6] #quality_func_Res --> CPM_R001
rootdir = argv[7] # "/erniedev_data3/theta_plus/Leiden/"
schema = "theta_plus"
sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)

data_name = data_type + str(start_year) + '_' + str(end_year)

# Read from Postgres
mcl_name = data_name + '_cluster_scp_list_unshuffled'
mcl = pd.read_sql_table(table_name= mcl_name, schema=schema, con=engine)

# # Read directly
# mcl_name = data_name + '_cluster_scp_list_unshuffled.csv'
# mcl = pd.read_csv(mcl_name)

leiden_name = data_name + '_cluster_scp_list_leiden_' + leiden_input + '.csv'
leiden = pd.read_csv(leiden_name)

mcl_grouped = mcl.groupby(by='cluster_no', 
                          as_index=False).agg('count').sort_values(by='cluster_no', ascending=True)

# To match clusters between size 30 and 350 only:
mcl_grouped = mcl_grouped[(mcl_grouped['scp'] >= 30) & (mcl_grouped['scp'] <= 350)]

mcl_cluster_list = mcl_grouped['cluster_no'].tolist()

print("Running...")
p = mp.Pool(6)
final_df = pd.DataFrame()

for mcl_cluster_no in mcl_cluster_list[:20]:

    match_dict = p.starmap(mm.match_mcl_to_leiden, [(mcl_cluster_no, mcl, leiden)])
    match_df = pd.DataFrame.from_dict(match_dict)
    final_df = final_df.append(match_df, ignore_index=True)

save_name = rootdir + '/' + data_name + '_match_to_leiden_' + leiden_input + '.csv'   
final_df.to_csv(save_name, index = None, header=True, encoding='utf-8')

# In case the connection times out:
engine = create_engine(sql_scheme)
save_name_sql = data_name + '_match_to_leiden_' + leiden_input
final_df.to_sql(save_name_sql, con=engine, schema=schema, index=False, if_exists='fail')

print("")
print("All Completed.")    
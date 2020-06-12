import jsd_modules as jm
import pandas as pd
pd.options.mode.chained_assignment = None
import multiprocessing as mp
from sqlalchemy import create_engine
from sys import argv
import os

# name = argv[1]
# val = argv[2]
name = 'now'
val = '20'
rootdir = argv[1] # ---> /erniedev_data3/theta_plus/imm
dir_list = sorted(os.listdir(rootdir))
start_cluster_num = argv[2]
end_cluster_num = argv[3]
cluster_type = argv[4]
user_name = argv[5]
password = argv[6]

schema = "theta_plus"
sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)

tmp_dir_list = ['imm1989', 'imm1991', 'imm1992', 'imm1993', 'imm1994']
for dir_name in tmp_dir_list:
#for dir_name in dir_list:
    print(f'Working on {dir_name}')
    title_abstracts_table = dir_name + '_title_abstracts'
    all_text_data = pd.read_sql_table(table_name=title_abstracts_table, schema=schema, con=engine)
    if cluster_type == 'unshuffled':
        cluster_path = rootdir + '/' + dir_name + '/dump.' + dir_name + '_citing_cited.mci.I20.csv'
    elif cluster_type == 'shuffled':
        cluster_path = rootdir + '/' + dir_name + '/dump.' + dir_name + '_citing_cited_shuffled_1million.I20.csv'
    
    cluster_df = pd.read_csv(cluster_path)

    if end_cluster_num == 'max':
        max_val = cluster_df['cluster_no'].max()
    else:
        max_val = int(end_cluster_num)

    data_text = cluster_df.merge(all_text_data, left_on='scp', right_on='scp', how='left')[['scp', 'title', 'abstract_text', 'cluster_no']]

    save_name = rootdir + '_output/' + dir_name + '/' + dir_name + '_JSD_' + cluster_type + ".csv"
    # p = mp.Pool(mp.cpu_count())
    p = mp.Pool(6)

    for cluster_num in range(int(start_cluster_num), max_val+1):

        print(f'Working on Cluster Number {cluster_num} of {cluster_df["cluster_no"].max()} in {dir_name}_{cluster_type}')
        print(cluster_path)
        jsd_dict = p.starmap(jm.compute_jsd, [(data_text[data_text['cluster_no']==cluster_num], name, val, cluster_num)])
        jsd_df = pd.DataFrame(jsd_dict)
        jsd_df.to_csv(save_name, mode = 'a', index = None, header=False, encoding='utf-8')


    print(f'{dir_name} Completed.')
    print("")
    print("")
    
print("All Completed.")


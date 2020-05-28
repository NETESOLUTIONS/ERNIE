import jsd_modules as jm
import pandas as pd
import multiprocessing as mp
from sqlalchemy import create_engine
from glob import glob
from sys import argv
import os

with open('/home/shreya/mcl_jsd/ernie_password.txt') as f:
    ernie_password = f.readline()
     
schema = "theta_plus"
sql_scheme = 'postgresql://shreya:' + ernie_password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)

rootdir = argv[1] # ---> /erniedev_data3/theta_plus/imm/
dir_list = sorted(os.listdir(rootdir))

# name = argv[1]
# val = argv[2]
name = 'now'
val = '20'
start_cluster_num = argv[2]
cluster_type = argv[3]
max_cluster_num = argv[4]

tmp_dir_list = ['imm1985', 'imm1995']
for dir_name in tmp_dir_list:
# for dir_name in dir_list[1:2]:
    
    title_abstracts_table = dir_name + '_title_abstracts'
    all_text_data = pd.read_sql_table(table_name=title_abstracts_table, schema=schema, con=engine)
    
    if cluster_type == 'unshuffled':
        cluster_path = rootdir + dir_name + '/dump.' + dir_name + '_testcase_asjc2403_citing_cited.mci.I20.csv'
        cluster_df = pd.read_csv(cluster_path)
    elif cluster_type == 'shuffled':
        cluster_path = rootdir + dir_name + '/dump.' + dir_name + '_testcase_asjc2403_citing_cited_shuffled_1million.I20.csv'
        cluster_df = pd.read_csv(cluster_path)

    if max_cluster_num == 'max':
        max_val = cluster_df['cluster_no'].max()
    else:
        max_val = int(max_cluster_num)
    
    data_text = cluster_df.merge(all_text_data, left_on='scp', right_on='scp', how='left')[['scp', 'title', 'abstract_text', 'cluster_no']]
    
    save_name = '/home/shreya/mcl_jsd/immunology/JSD_output_' +  dir_name + '_' + cluster_type + ".csv" 
    
    # p = mp.Pool(mp.cpu_count())
    p = mp.Pool(6)
    
    for cluster_num in range(int(start_cluster_num), max_val+1):
        
        print(f'Working on Cluster Number {cluster_num} of {dir_name}_{cluster_type}')
        jsd_df = p.starmap(jm.compute_jsd, [(data_text[data_text['cluster_no']==cluster_num], name, val, cluster_num)])
        jsd_df.to_csv(save_name, mode = 'a', index = None, header=False, encoding='utf-8')


    print("ALL COMPLETED.")
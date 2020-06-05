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

rootdir = '/erniedev_data3/theta_plus/imm/'
dir_list = sorted(os.listdir(rootdir))

# name = argv[1]
# val = argv[2]
name = 'now'
val = '20'
start_cluster_num = int( argv[1])
max_cluster_num = argv[2]
cluster_type = argv[3]
repeat = int(argv[4])

jsd_output_column_names = ['weight', 'inflation', 'cluster', 'total_size', 'pre_jsd_size',
       'missing_values', 'post_jsd_size', 'jsd_nans', 'mean_jsd', 'min_jsd',
       'percentile_25_jsd', 'median_jsd', 'percentile_75_jsd', 'max_jsd',
       'std_dev_jsd', 'total_unique_unigrams', 'final_unique_unigrams',
       'size_1_unigram_prop']

with open('/home/shreya/mcl_jsd/ernie_password.txt') as f:
    ernie_password = f.readline()

# p = mp.Pool(mp.cpu_count())
p = mp.Pool(6)

#tmp_dir_list = ['imm1985', 'imm1995']
#for dir_name in tmp_dir_list:
for dir_name in dir_list:

    title_abstracts_table = dir_name + '_title_abstracts'
    all_text_data = pd.read_sql_table(table_name=title_abstracts_table, schema=schema, con=engine)

    jsd_output_file_name = '/home/shreya/mcl_jsd/immunology/' + dir_name + '/JSD_output_' + dir_name + '_'  + cluster_type + '.csv'
    jsd_output_data = pd.read_csv(jsd_output_file_name, names = jsd_output_column_names)

    cluster_counts_table = jsd_output_data[['cluster', 'pre_jsd_size']].groupby('pre_jsd_size', as_index = False).agg('count').rename(columns={'cluster':'frequency', 'pre_jsd_size':'cluster_size'}).sort_values('cluster_size', ascending=False)
    cluster_counts_table = cluster_counts_table.reset_index(drop=True)

    if max_cluster_num == 'max':
        max_val = len(cluster_counts_table)
    else:
        max_val = int(max_cluster_num)

    # jsd_data = jsd[(jsd['weight'] == name) & (jsd['inflation'] == int(val))]
    # jsd_data['random_jsd'] = 0

    save_name = '/home/shreya/mcl_jsd/immunology/' + dir_name + '/JSD_random_output_' +  dir_name + '_' + cluster_type + '.csv'

    for cluster_num in range(start_cluster_num-1, max_val):
        print("")
    #     print(f'Working on Cluster: {name} {val}.')
        print(f'The Cluster Size Number is {cluster_num+1} of {max_val} in {dir_name}')

        result_df = cluster_counts_table[cluster_num:cluster_num+1]
        result_df['random_jsd'] = p.starmap(jm.random_jsd, [(cluster_counts_table['cluster_size'][cluster_num:cluster_num+1], all_text_data, repeat)])
        result_df.to_csv(save_name, mode = 'a', index = None, header=False, encoding='utf-8')
        print(f'Done with Cluster Size Number {cluster_num+1}')
        print("")


print("")
print("")
print("ALL COMPLETED.")

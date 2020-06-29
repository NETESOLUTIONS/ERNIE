import jsd_modules as jm
import pandas as pd
pd.options.mode.chained_assignment = None
import multiprocessing as mp
from sqlalchemy import create_engine
from glob import glob
from sys import argv
import os

jsd_output_column_names = ['weight', 'inflation', 'cluster', 'total_size', 'pre_jsd_size',
       'missing_values', 'post_jsd_size', 'jsd_nans', 'mean_jsd', 'min_jsd',
       'percentile_25_jsd', 'median_jsd', 'percentile_75_jsd', 'max_jsd',
       'std_dev_jsd', 'total_unique_unigrams', 'final_unique_unigrams',
       'size_1_unigram_prop']
    
# name = argv[1]
# val = argv[2]
name = 'now'
val = '20'
rootdir = argv[1] # ---> /erniedev_data3/theta_plus/imm
dir_list = sorted(os.listdir(rootdir))
start_cluster_num = int(argv[2])
end_cluster_num = argv[3]
cluster_type = argv[4]
repeat = int(argv[5])
user_name = argv[6]
password = argv[7]

schema = "theta_plus"
sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)

# p = mp.Pool(mp.cpu_count())
p = mp.Pool(6)

tmp_dir_list = ['imm1985']
for dir_name in tmp_dir_list:
#for dir_name in dir_list:    
    print(f'Working on {dir_name}')
    title_abstracts_table = 'imm1985_1995_union_title_abstracts_processed'
    query = "SELECT edge.*, tat.processed_all_text FROM theta_plus." + dir_name + "_edge_list_" + cluster_type + " edge LEFT JOIN theta_plus." + title_abstracts_table + " tat ON edge.scp = tat.scp WHERE tat.processed_all_text is NOT NULL;"
    all_text_data = pd.read_sql(query, con=engine)

    jsd_output_file_name = rootdir + '_output/' + dir_name + '/' + dir_name + '_JSD_' + cluster_type + ".csv"
    jsd_output_data = pd.read_csv(jsd_output_file_name, names = jsd_output_column_names)

    cluster_counts_table = jsd_output_data[['cluster', 'pre_jsd_size']].groupby('pre_jsd_size', as_index = False).agg('count').rename(columns={'cluster':'frequency', 'pre_jsd_size':'cluster_size'}).sort_values('cluster_size', ascending=False)
    cluster_counts_table = cluster_counts_table.reset_index(drop=True)

    if end_cluster_num == 'max':
        max_val = len(cluster_counts_table)
    else:
        max_val = int(end_cluster_num)

    save_name = rootdir + '_output/' + dir_name + '/' +  dir_name + '_JSD_random_' + cluster_type + '.csv'

    for cluster_num in range(start_cluster_num-1, max_val):
        print("")
    #     print(f'Working on Cluster: {name} {val}.')
        print(f'The Cluster Size Number is {cluster_num+1} of {max_val} in {dir_name}')
        result_df = cluster_counts_table[cluster_num:cluster_num+1]
        print(f'The Cluster Size is {result_df["cluster_size"].values[0]}')
        result_df['random_jsd'] = p.starmap(jm.random_jsd, [(result_df['cluster_size'], all_text_data, repeat)])
        result_df.to_csv(save_name, mode = 'a', index = None, header=False, encoding='utf-8')
        print(f'Done with Cluster Size Number {cluster_num+1}')
        print("")
print("")
print("")
print("ALL COMPLETED.")

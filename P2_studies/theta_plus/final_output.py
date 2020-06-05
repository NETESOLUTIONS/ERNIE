import pandas as pd
import os
from sys import argv

rootdir = '/erniedev_data3/theta_plus/imm/'
dir_list = sorted(os.listdir(rootdir))

cluster_type = argv[1]

#tmp_dir_list = ['imm1985', 'imm1990', 'imm1995']
#for dir_name in tmp_dir_list:
for dir_name in dir_list:

    jsd_file_name = '/home/shreya/mcl_jsd/immunology/results/JSD_final_result_' + dir_name + '_' + cluster_type + '.csv'
    conductance_file_name = '/home/shreya/mcl_jsd/immunology/results/JSD_conductance_output_' + dir_name + '_' + cluster_type + '.csv'

    jsd_file = pd.read_csv(jsd_file_name)
    conductance_file = pd.read_csv(conductance_file_name)

    complete_output_full = jsd_file.merge(conductance_file, left_on='cluster', right_on='cluster', how='inner')
    complete_output_main = complete_output_full[['weight', 'inflation', 'cluster', 'total_size', 'pre_jsd_size', 'mean_jsd', 'jsd_coherence', 'conductance']].rename(columns={'total_size':'original_size', 'pre_jsd_size':'final_size', 'jsd_coherence':'coherence'})

    save_name_full = '/home/shreya/mcl_jsd/immunology/results/final/' + dir_name + '_complete_output_full_' + cluster_type + '.csv'
    save_name_main = '/home/shreya/mcl_jsd/immunology/results/final/'+ dir_name + '_complete_output_main_' + cluster_type + '.csv'

    complete_output_full.to_csv(save_name_full, index = None, header=True, encoding='utf-8')
    complete_output_main.to_csv(save_name_main, index = None, header=True, encoding='utf-8')

print("ALL COMPLETE")
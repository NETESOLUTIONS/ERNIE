import numpy as np
import swifter 
import jsd_modules as jm
import glob
import os
import pandas as pd
from sys import argv
from ast import literal_eval

# -------------------------------------------------------------------------

jsd_output_column_names = ['weight', 'inflation', 'cluster', 'total_size', 'pre_jsd_size', 'missing_values', 'post_jsd_size', 'jsd_nans', 'mean_jsd', 'min_jsd', 'percentile_25_jsd',
'median_jsd', 'percentile_75_jsd', 'max_jsd', 'std_dev_jsd','total_unique_unigrams', 'final_unigrams', 'freq_1_unigrams_prop']

jsd_random_output_column_names = ['cluster_size', 'frequency', 'random_jsd']


rootdir = argv[1] # ---> /erniedev_data3/theta_plus/imm/
dir_list = sorted(os.listdir(rootdir))

cluster_type = argv[2]

tmp_dir_list = ['imm1990']
for dir_name in tmp_dir_list:
# for dir_name in dir_list:
    
    jsd_output_name = '/home/shreya/mcl_jsd/immunology/JSD_output_' + dir_name + '_' + cluster_type + '.csv'
    jsd_output_data = pd.read_csv(jsd_output_name, names=jsd_output_column_names)
    jsd_output_data = jsd_output_data_unshuffled.sort_values(by='cluster')
    jsd_output_data = jsd_output_data_unshuffled.reset_index(drop=True)
    
    jsd_random_output_name = '/home/shreya/mcl_jsd/immunology/JSD_random_output_' + dir_name + '_' + cluster_type + '.csv'
    jsd_random_output = pd.read_csv(jsd_random_output_name, names=jsd_random_output_column_names)
    jsd_random_output = jsd_random_output.sort_values(by='cluster_size',ascending=False).reset_index(drop=True).fillna('nan')
    jsd_random_output['random_jsd'] = jsd_random_output['random_jsd'].swifter.progress_bar(False).apply(jm.fix_eval_issue)
    jsd_random_output['mean_random_jsd'] = jsd_random_output['random_jsd'].swifter.progress_bar(False).apply(jm.compute_mean)
    jsd_random_output['random_jsd_range'] = jsd_random_output['random_jsd'].swifter.progress_bar(False).apply(jm.random_jsd_range)
    
    jsd_output_data['random_jsd'] = jsd_output_data['pre_jsd_size'].swifter.progress_bar(False).apply(jm.add_random_jsd_list)
    jsd_output_data['mean_random_jsd'] = jsd_output_data['pre_jsd_size'].swifter.progress_bar(False).apply(jm.add_mean_random_jsd)
    jsd_output_data['random_jsd_range'] = jsd_output_data['pre_jsd_size'].swifter.progress_bar(False).apply(jm.add_random_jsd_range)
    jsd_output_data['jsd_coherence'] = jsd_output_data['mean_random_jsd'] - jsd_output_data['mean_jsd']
    
    save_name = '/home/shreya/mcl_jsd/immunology/JSD_final_output_' + dir_name + '_' + cluster_type + '.csv'
    jsd_output_data.to_csv(save_name, index = None, header=True, encoding='utf-8')
    
    
   
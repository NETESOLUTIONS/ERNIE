import swifter
import jsd_modules as jm
import os
import pandas as pd
from sys import argv

# -------------------------------------------------------------------------

jsd_output_column_names = ['weight', 'inflation', 'cluster', 'total_size', 'pre_jsd_size', 'missing_values', 'post_jsd_size', 'jsd_nans', 'mean_jsd', 'min_jsd', 'percentile_25_jsd',
'median_jsd', 'percentile_75_jsd', 'max_jsd', 'std_dev_jsd','total_unique_unigrams', 'final_unigrams', 'freq_1_unigrams_prop']

jsd_random_output_column_names = ['cluster_size', 'frequency', 'random_jsd']


rootdir = '/erniedev_data3/theta_plus/imm/'
dir_list = sorted(os.listdir(rootdir))

cluster_type = argv[1]

#tmp_dir_list = ['imm1985', 'imm1990', 'imm1995']
#for dir_name in tmp_dir_list:
for dir_name in dir_list:

    print(f'Working on {dir_name}')
    jsd_output_name = '/home/shreya/mcl_jsd/immunology/' +dir_name+ '/JSD_output_' + dir_name + '_' + cluster_type + '.csv'
    jsd_output_data = pd.read_csv(jsd_output_name, names=jsd_output_column_names)
    jsd_output_data = jsd_output_data.sort_values(by='cluster')
    jsd_output_data = jsd_output_data.reset_index(drop=True)

    jsd_random_output_name = '/home/shreya/mcl_jsd/immunology/' +dir_name+ '/JSD_random_output_' + dir_name + '_' + cluster_type + '.csv'
    jsd_random_output = pd.read_csv(jsd_random_output_name, names=jsd_random_output_column_names)
    jsd_random_output = jsd_random_output.sort_values(by='cluster_size',ascending=False).reset_index(drop=True).fillna('nan')

    jsd_random_output['random_jsd'] = jsd_random_output['random_jsd'].swifter.progress_bar(False).apply(jm.fix_eval_issue)
    jsd_random_output['mean_random_jsd'] = jsd_random_output['random_jsd'].swifter.progress_bar(False).apply(jm.compute_mean)
    jsd_random_output['random_jsd_range'] = jsd_random_output['random_jsd'].swifter.progress_bar(False).apply(jm.random_jsd_range)

    jsd_output_data = jsd_output_data.merge(jsd_random_output, left_on='pre_jsd_size', right_on = 'cluster_size', how='left')
    jsd_output_data['jsd_coherence'] = jsd_output_data['mean_random_jsd'] - jsd_output_data['mean_jsd']

    save_name = '/home/shreya/mcl_jsd/immunology/results/JSD_final_result_' + dir_name + '_' + cluster_type + '.csv'
    jsd_output_data.to_csv(save_name, index = None, header=True, encoding='utf-8')

print("All complete.")
"""
Command line arguments:

[1] type of weight - choose from (ncf, now, sf)
[2] inflation values - choose from (20, 30, 40, 60)
[3] number of iterations of samples

"""

from scipy.spatial import distance
from sklearn.feature_extraction.text import CountVectorizer
import sklearn
import numpy as np
import swifter  # Makes applying to datframe as fast as vectorizing
from nltk.probability import FreqDist
import string
import glob
import os
import pandas as pd
import nltk
import re
from sys import argv
from ast import literal_eval
from scipy import sparse
import multiprocessing as mp



# ------------------------------------------------------------------------------------ #

def get_frequency(processed_text_list):
    """
    Using a built-in NLTK function that generates tuples
    We get the frequency distribution of all words/n-grams in a tokenized list
    We can get the proportion of the the token as a fraction of the total corpus size  ----> N/A
    We can also sort these frequencies and proportions in descending order in a dictionary object ----> N/A

    Argument(s): 'processed_text_list' - A list of pre-processed tokens

    Output(s): freq_dict - A dictionary of tokens and their respective frequencies in descending order
    """
    # prop_dict - A dictionary of tokens and their respective proportions as a fraction of the total corpus
    # combined_dict - A dictionary whose values are both frequencies and proportions combined within a list
    # """

    word_frequency = FreqDist(word for word in processed_text_list)

#     sorted_counts = sorted(word_frequency.items(), key = lambda x: x[1], reverse = True)
#     freq_dict = dict(sorted_counts)
    freq_dict = dict(word_frequency)
#     prop_dict = {key : freq_dict[key] * 1.0 / sum(freq_dict.values()) for key, value in freq_dict.items()}
#     combined_dict = {key : [freq_dict[key], freq_dict[key] * 1.0 / sum(freq_dict.values())] for key, value in freq_dict.items()}

    return freq_dict  # , prop_dict, combined_dict


# ------------------------------------------------------------------------------------ #

def merge_vocab_dictionary(vocab_column):
    """
    Takes any number of token frequency dictionaries and merges them while summing 
    the respective frequencies and then calculates the proportion of the the tokens 
    as a fraction of the total corpus size and saves to text and CSV files


    Argument(s): vocab_column - A column of dictionary objects

    Output(s): merged_combined_dict - A list object containing the frequencies of all
               merged dictionary tokens along with their respective proportions
    """

    merged_freq_dict = {}
    for dictionary in vocab_column:
        for key, value in dictionary.items():  # d.items() in Python 3+
            merged_freq_dict.setdefault(key, []).append(1)

    for key, value in merged_freq_dict.items():
        merged_freq_dict[key] = sum(value)

#     sorted_merged_freq_dict = sorted(
#         merged_freq_dict.items(), key=lambda x: x[1], reverse=True)

#     total_sum = sum(merged_freq_dict.values())
#     merged_prop_dict = {key : merged_freq_dict[key] * 1.0 / total_sum for key, value in merged_freq_dict.items()}
#     merged_combined_dict = {key : [merged_freq_dict[key], (merged_freq_dict[key] * 1.0 / total_sum)] for key, value in merged_freq_dict.items()}

    return merged_freq_dict


# ------------------------------------------------------------------------------------ #

def remove_less_than(frequency_dict, less_than = 1):
    
    """
    We use the 
    
    Argument(s): 'frequency_dict' - a dictionary 
                 'max_frequency' - 
                 'less_than' - 
    
    Output: 'retained' - a dictionary of
    """
   
    retained_dict = {key : value for key, value in frequency_dict.items() if (value > less_than)}
    
    return retained_dict

# ------------------------------------------------------------------------------------ #

def filter_after_preprocess(processed_tokens, retained_dict):
    
    """
    We use the 
    
    Argument(s): processed_tokens  -
                 vocabulary_dict -
    
    Output: filtered 
    """
    filtered = []

    for token in processed_tokens:
        if token in retained_dict.keys():
            filtered.append(token)

    return filtered

# ------------------------------------------------------------------------------------ #

def vectorize(text, corpus_by_cluster, count_vectorizer):
    
    article_count_mat = count_vectorizer.transform([' '.join(text)])
    article_sum = sparse.diags(1/article_count_mat.sum(axis=1).A.ravel())
    article_prob_vec = (article_sum @ article_count_mat).toarray()
    
    return article_prob_vec

# ------------------------------------------------------------------------------------ #

def calculate_jsd(doc_prob_vec, cluster_prob_vec):

    jsd = distance.jensenshannon(doc_prob_vec.tolist()[0], cluster_prob_vec)
    
    return jsd
# ------------------------------------------------------------------------------------ #

def fix_eval_issue(doc):
    return literal_eval(doc)



# ------------------------------------------------------------------------------------ #

# name = argv[1]
# val = argv[2]
start_cluster_num = int(argv[1])
repeat = int(argv[2])
cluster_type = argv[3]

jsd_column_names = ['weight', 'inflation', 'cluster', 'total_size', 'pre_jsd_size',
       'missing_values', 'post_jsd_size', 'jsd_nans', 'mean_jsd', 'min_jsd',
       'percentile_25_jsd', 'median_jsd', 'percentile_75_jsd', 'max_jsd',
       'std_dev_jsd', 'total_unique_unigrams', 'final_unique_unigrams',
       'size_1_unigram_prop']

jsd_file_name = '/home/shreya/mcl_jsd/immunology/JSD_output_imm90_' + cluster_type + '.csv'


jsd_data = pd.read_csv(jsd_file_name, names = jsd_column_names)
all_data = pd.read_csv("/home/shreya/mcl_jsd/immunology/imm90_title_abstracts_processed.csv")

all_data = all_data.dropna()

# all_data['processed_all_text'] = all_data['processed_all_text'].swifter.apply(fix_eval_issue)
# all_data['processed_all_text_frequencies'] = all_data['processed_all_text_frequencies'].swifter.apply(fix_eval_issue)


def random_jsd(jsd_size, sample_data = all_data, repeat = repeat):
    
    random_jsd = []
    
    if int(jsd_size) >= 10:
    
        for i in range(repeat):
            data_text = sample_data.sample(n = int(jsd_size))
            
            data_text['processed_all_text'] = data_text['processed_all_text'].swifter.apply(fix_eval_issue)
            data_text['processed_all_text_frequencies'] = data_text['processed_all_text_frequencies'].swifter.apply(fix_eval_issue)
            
            data_all_text_frequency = merge_vocab_dictionary(data_text['processed_all_text_frequencies'])
            retained_dict = remove_less_than(data_all_text_frequency)
            data_text['filtered_text'] = data_text['processed_all_text'].swifter.apply(filter_after_preprocess, args = (retained_dict,))

            data_all_text = data_text.filtered_text.tolist()
            corpus_by_article = [' '.join(text) for text in data_all_text]
            corpus_by_cluster = [' '.join(corpus_by_article)]

            count_vectorizer = CountVectorizer(lowercase=False, vocabulary=list(set(corpus_by_cluster[0].split())))
            cluster_count_mat = count_vectorizer.fit_transform(corpus_by_cluster)

            data_text['probability_vector'] = data_text['filtered_text'].swifter.apply(vectorize, args=(corpus_by_cluster, count_vectorizer,))

            cluster_sum = sparse.diags(1/cluster_count_mat.sum(axis=1).A.ravel())
            cluster_prob_vec = (cluster_sum @ cluster_count_mat).toarray().tolist()[0]

            data_text['JS_distance'] = data_text['probability_vector'].swifter.apply(calculate_jsd, args = (cluster_prob_vec,))

            data_text = data_text.dropna()
            data_text['JS_divergence'] = np.square(data_text['JS_distance'])
            
            random_jsd.append(data_text['JS_divergence'].mean())
            
    else:
        random_jsd = None
    
    return random_jsd
        

# jsd_data = jsd[(jsd['weight'] == name) & (jsd['inflation'] == int(val))]
# jsd_data['random_jsd'] = 0

save_name = '/home/shreya/mcl_jsd/immunology/JSD_random_output_imm90_' + cluster_type + '.csv'

# p = mp.Pool(mp.cpu_count())
p = mp.Pool(6)

for cluster_num in range(start_cluster_num-1, len(jsd_data)):
    print("")
#     print(f'Working on Cluster: {name} {val}.')
    print(f'The Cluster Number is {cluster_num+1}')
    random_list = p.map(random_jsd, jsd_data['pre_jsd_size'][cluster_num:cluster_num+1])
    
    result_df = jsd_data[cluster_num:cluster_num+1]
    result_df['random_jsd'] = random_list
  
    result_df.to_csv(save_name, mode = 'a', index = None, header=False, encoding='utf-8')
    
    print(f'Done with Cluster Number {cluster_num+1}')
    print("")
    print("")

print("")
print("")
print("ALL COMPLETED.")
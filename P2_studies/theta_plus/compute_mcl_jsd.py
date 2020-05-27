#!/usr/bin/env python3
"""
Command line arguments:

[1] type of weight - choose from (ncf, now, sf)
[2] inflation values - choose from (20, 30, 40, 60)
[3] start from cluster number - ideally 1

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
import multiprocessing as mp
import time
from scipy import sparse
import preprocess_text.py


# ------------------------------------------------------------------------------------ #

# Run text pre-processing script on the entire title_abstract.csv file to save time.

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

# ----- TO PULL DATA FROM POSTGRES ----- #

import psycopg2

with open('/home/shreya/mcl_jsd/ernie_password.txt') as f:
    ernie_password = f.readline()

conn=psycopg2.connect(database="ernie",user="shreya",host="ernie2",password=ernie_password)
conn.set_client_encoding('UTF8')
conn.autocommit=True
curs=conn.cursor()

# Set schema
schema = "theta_plus"
set_schema = "SET SEARCH_PATH TO " + schema + ";"   
curs.execute(set_schema)


# weights = ['ncf', 'now', 'sf'] # ---> name
# inflation = ['20', '30', '40', '60'] # ---> val

# name = argv[1]
# val = argv[2]

name = 'now'
val = '20'
start_cluster_num = argv[1]
cluster_type = argv[2]
        
# title_abstract_table = 'top_scp_title_concat_abstract_english' 
title_abstract_table = 'imm90_title_abstracts_processed'


# cluster_table = name + '_' + val + '_ids'

cluster_table = cluster_type + '_imm1990_cluster_list'

print("Querying: ", cluster_table)

save_name = "/home/shreya/mcl_jsd/immunology/JSD_output_imm90_" + cluster_type + ".csv" 

max_query = "SELECT MAX(cluster_no) FROM " + cluster_table + ";"

curs.execute(max_query, conn)
max_cluster_number = curs.fetchone()[0]

for cluster_num in range(int(start_cluster_num), max_cluster_number+1):
            
    print("Querying Cluster Number: ", str(cluster_num))


    query = "SELECT tat.*, clt.cluster_no " + "FROM " + cluster_table +  " AS clt " + "LEFT JOIN " + title_abstract_table + " AS tat " + "ON clt.scp = tat.scp " + "WHERE clt.cluster_no=" + str(cluster_num) + ";"

    print(query)

    data_text = pd.read_sql(query, conn)
   
    print('The size of the cluster is: ', len(data_text))
    original_cluster_size = len(data_text)
    data_text = data_text.dropna()
    print('Size after removing missing titles and abstracts: ', len(data_text))
    final_cluster_size = len(data_text)
    
    if final_cluster_size < 10:
            
        result_df = pd.DataFrame({
            'weight': name, 
            'inflation': val,
            'cluster': cluster_num,
            'total_size': original_cluster_size, 
            'pre_jsd_size': final_cluster_size,
            'missing_values': (original_cluster_size-final_cluster_size,),
            'post_jsd_size': None,
            'jsd_nans': None, 
            'mean_jsd': None, 
            'min_jsd': None,
            'percentile_25_jsd': None, 
            'median_jsd': None,
            'percentile_75_jsd': None, 
            'max_jsd': None, 
            'std_dev_jsd': None,
            'total_unique_unigrams': None,
            'final_unique_unigrams':  None,
            'size_1_unigram_prop': None})

        result_df.to_csv(save_name, mode = 'a', index = None, header=False, encoding='utf-8')
        
    else:
        
        data_text['processed_all_text'] = data_text['processed_all_text'].swifter.apply(fix_eval_issue)
        data_text['processed_all_text_frequencies'] = data_text['processed_all_text_frequencies'].swifter.apply(fix_eval_issue)
        data_all_text_frequency = merge_vocab_dictionary(data_text['processed_all_text_frequencies'])

        retained_dict = remove_less_than(data_all_text_frequency)
        data_text['filtered_text'] = data_text['processed_all_text'].swifter.apply(filter_after_preprocess, args = (retained_dict,))

        mcl_all_text = data_text.filtered_text.tolist()
        corpus_by_article = [' '.join(text) for text in mcl_all_text]
        corpus_by_cluster = [' '.join(corpus_by_article)]

        count_vectorizer = CountVectorizer(lowercase=False, vocabulary=list(set(corpus_by_cluster[0].split())))
        cluster_count_mat = count_vectorizer.fit_transform(corpus_by_cluster)

        data_text['probability_vector'] = data_text['processed_all_text'].swifter.apply(vectorize, args=(corpus_by_cluster, count_vectorizer,))

        cluster_sum = sparse.diags(1/cluster_count_mat.sum(axis=1).A.ravel())
        cluster_prob_vec = (cluster_sum @ cluster_count_mat).toarray().tolist()[0]

        data_text['JS_distance'] = data_text['probability_vector'].swifter.apply(calculate_jsd, args = (cluster_prob_vec,))

        data_text = data_text.dropna()

        data_text['JS_divergence'] = np.square(data_text['JS_distance'])
        jsd_cluster_size = len(data_text)

        jsd_min = min(data_text['JS_divergence'])
        jsd_25_percentile = np.percentile(data_text['JS_divergence'], 25)
        jsd_median = np.percentile(data_text['JS_divergence'], 50)
        jsd_75_percentile = np.percentile(data_text['JS_divergence'], 75)
        jsd_max = max(data_text['JS_divergence'])
        jsd_mean = np.mean(data_text['JS_divergence'])
        jsd_std = np.std(data_text['JS_divergence'])

        print("")
        print("JSD computed.")
        print("Cluster analysis complete.")
        print("")
        print("Saving to CSV")
        print("")

        result_df = pd.DataFrame({
            'weight': name, 
            'inflation': val,
            'cluster': cluster_num,
            'total_size': original_cluster_size, 
            'pre_jsd_size': final_cluster_size,
            'missing_values': (original_cluster_size-final_cluster_size,),
            'post_jsd_size': jsd_cluster_size,
            'jsd_nans': (final_cluster_size-jsd_cluster_size), 
            'mean_jsd': jsd_mean, 
            'min_jsd': jsd_min,
            'percentile_25_jsd': jsd_25_percentile, 
            'median_jsd': jsd_median,
            'percentile_75_jsd': jsd_75_percentile, 
            'max_jsd': jsd_max, 
            'std_dev_jsd': jsd_std,
            'total_unique_unigrams': len(data_all_text_frequency),
            'final_unique_unigrams': len(retained_dict),
            'size_1_unigram_prop': (1-(len(retained_dict)/len(data_all_text_frequency)))})
        
        result_df.to_csv(save_name, mode = 'a', index = None, header=False, encoding='utf-8')
        
        print("")

print("ALL COMPLETED.")
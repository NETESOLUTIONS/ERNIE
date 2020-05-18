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
from nltk.corpus import stopwords
import glob
import os
import pandas as pd
import re
from textblob import TextBlob, Word
import nltk
from nltk.util import ngrams
import re
nltk.download('stopwords')
from sys import argv
from scipy import sparse
from ast import literal_eval
import multiprocessing as mp
import time


# ------------------------------------------------------------------------------------ #

stop_words = ['a', 'aaa', 'about', 'above', 'account', 'activity', 'addition', 'affect', 
              'after', 'again', 'against', 'age', 'ain', 'alan', 'all', 'allow', 'almost',
              'along', 'along', 'also', 'although', 'always', 'am', 'america', 'american', 
              'among', 'amount', 'an', 'analysis', 'and', 'and/or', 'another', 'any', 'apa', 
              'appear', 'application', 'apply', 'approach', 'approximately', 'are', 'area', 
              'aren', "aren't", 'as', 'aspect', 'associate', 'association', 'assume', 'at', 
              'attempt', 'author', 'average', 'base', 'basis', 'be', 'because', 'become', 'been', 
              'before', 'behavior', 'being', 'below', 'best', 'between', 'both', 'but', 'by', 
              'calculate', 'calculation', 'can', 'case', 'cause', 'certain', 'change', 
              'characteristic', 'characterize', 'conclude', 'closely', 'common', 'compare', 
              'comparison', 'complete', 'complex', 'component', 'condition', 'consider', 
              'consist', 'consistent', 'constant', 'contain', 'control', 'copyright', 'could', 
              'couldn', "couldn't", 'd', 'data', 'database', 'day', 'decrease', 'define', 
              'demonstrate', 'depend', 'describe', 'detect', 'determine', 'develop', 'did', 'didn',
              "didn't", 'differ', 'difference', 'different', 'directly', 'discuss', 'distribution', 'do', 
              'does', 'doesn', "doesn't", 'doing', 'don', "don't", 'done', 'down', 'due', 'during', 'e.g.', 
              'each', 'early', 'effect', 'effective', 'eight', 'either', 'employ', 'enough', 'especially',
              'establish', 'establish', 'estimate', 'etc', 'evaluate', 'even', 'evidence', 'examine', 
              'example', 'exhibit', 'exhibit', 'experiment', 'experimental', 'explain', 'factor', 'far', 
              'feature', 'few', 'find', 'finding', 'first', 'five', 'follow', 'for', 'form', 'formation', 
              'found', 'four', 'free', 'from', 'function', 'further', 'furthermore', 'general', 'give', 
              'good', 'great', 'group', 'had', 'hadn', "hadn't", 'has', 'hasn', "hasn't", 'have',
              'haven', "haven't", 'having', 'he', 'her', 'here', 'hers', 'herself', 'high', 'highly', 
              'him', 'himself', 'his', 'hitherto', 'how', 'however', 'human', 'i', 'if', 'important', 
              'improved', 'in', 'inc', 'include', 'increase', 'increased', 'indicate', 'individual',
              'induce', 'influence', 'information', 'initial', 'interaction', 'into', 'is', 
              'isn', "isn't", 'it', "it's", 'its', 'itself', 'just', 'kg', 'km', 'know', 'large', 'latter', 
              'least', 'less', 'level', 'likely', 'limit', 'line', 'll', 'low', 'm', 'ma', 'made', 
              'mainly', 'make', 'man', 'many', 'maximum', 'may', 'me', 'mean', 'measure', 
              'measurement', 'method', 'mg', 'might', 'mightn', "mightn't", 'ml', 'mm', 'monkey', 
              'month', 'more', 'most', 'mostly', 'mouse', 'much', 'multiple', 'must', 'mustn',
              "mustn't", 'my', 'myself', 'near', 'nearly', 'need', 'needn', "needn't", 'neither',
              'new', 'nih', 'nine', 'no', 'nor', 'normal', 'not', 'noticeable', 'now', 'number', 
              'o', 'observation', 'observe', 'obtain', 'obtained', 'occur', 'of', 'off', 'often', 
              'on', 'once', 'one', 'only', 'or', 'order', 'other', 'our', 'ours', 'ourselves', 
              'out', 'over', 'overall', 'own', 'parameter', 'part', 'particular', 'per', 'perform', 
              'perhaps', 'period', 'phase', 'physical', 'pmid', 'point', 'population', 'possible', 
              'potential', 'presence', 'present', 'press', 'previous', 'previously', 'probably', 
              'process', 'produce', 'product', 'property', 'propose', 'provide', 'psycinfo', 
              'publish', 'quantity', 'quite', 'rabbit', 'range', 'rat', 'rate', 'rather', 're', 
              'reaction', 'really', 'receive', 'recent', 'recently', 'record', 'ref', 'reference', 
              'regarding', 'relate', 'relation', 'relationship', 'relative', 'relatively', 'relevant', 
              'remain', 'report', 'represent', 'require', 'respectively', 'response', 'result', 
              'reveal', 'review', 'right', 'right reserved', 'role', 's', 'same', 'sample', 'second',
              'see', 'seem', 'seen', 'separate', 'set', 'seven', 'several', 'shan', "shan't", 'she', 
              "she's", 'should', "should've", 'shouldn', "shouldn't", 'show', 'showed', 'shown', 
              'shows', 'significant', 'significantly', 'similar', 'simple', 'since', 'six', 'size',
              'small', 'so', 'society', 'some', 'specific', 'state', 'strong', 'study', 'subject',
              'subsequent', 'such', 'suggest', 'support', 't', 'take', 'task', 'technique', 'ten', 
              'term', 'test', 'than', 'that', "that'll", 'the', 'their', 'theirs', 'them',
              'themselves', 'then', 'theory', 'there', 'therefore', 'these', 'they', 'this', 'those',
              'three', 'through', 'thus', 'time', 'to', 'together', 'too', 'total', 'two', 'type',
              'under', 'university', 'unknown', 'unlikely', 'until', 'up', 'upon', 'use', 'used', 
              'useful', 'using', 'usually', 'value', 'various', 'vary', 've', 'very', 'via', 'view', 
              'was', 'wasn', "wasn't", 'we', 'well', 'were', 'weren', "weren't", 'what', 'whatever', 
              'when', 'where', 'whereas', 'whether', 'which', 'while', 'who', 'whom', 'why', 'wiley', 
              'will', 'with', 'within', 'without', 'won', "won't", 'work', 'would', 'wouldn', 
              "wouldn't", 'y', 'yield', 'you', "you'd", "you'll", "you're", "you've", 'your', 'yours',
              'yourself', 'yourselves', 'involve', 'investigate', 'apparent', 'identify', 'assess']  # ---> updated based on results


def preprocess_text(doc, n_grams='one'):
    """
    Pre-processing using TextBlob: 
    tokenizing, converting to lower-case, and lemmatization based on POS tagging, 
    removing stop-words, and retaining tokens greater than length 2

    We can also choose to include n_grams (n = 1,2,3) in the final output

    Argument(s): 'doc' - a string of words or sentences.
                 'n_grams' - one: only unigrams (tokens consisting of one word each)
                           - two: only bigrams
                           - two_plus: unigrams + bigrams
                           - three: only trigrams 
                           - three_plus: unigrams + bigrams + trigrams

    Output: 'reuslt_singles' - a list of pre-processed tokens (individual words) of each sentence in 'doc'
            'result_ngrams' - a list of pre-processed tokens (including n-grams) of each sentence in 'doc'

    """

    blob = TextBlob(doc).lower()
#     lang = blob.detect_language()
#     print(lang)
#     if lang != 'en':
#         blob = blob.translate(to = 'en')

    result_singles = []

    tag_dict = {"J": 'a',  # Adjective
                "N": 'n',  # Noun
                "V": 'v',  # Verb
                "R": 'r'}  # Adverb

    # For all other types of parts of speech (including those not classified at all)
    # the tag_dict object maps to 'None'
    # the method w.lemmatize() defaults to 'Noun' as POS for those classified as 'None'

    for sent in blob.sentences:

        words_and_tags = [(w, tag_dict.get(pos[0])) for w, pos in sent.tags]
        lemmatized_list = [w.lemmatize(tag) for w, tag in words_and_tags]

        for i in range(len(lemmatized_list)):

            if lemmatized_list[i] not in stop_words and len(lemmatized_list[i].lower()) > 2 and not lemmatized_list[i].isdigit():
                result_singles.append(lemmatized_list[i].lower())

    result_bigrams = ['_'.join(x) for x in ngrams(result_singles, 2)]

    result_bigrams = [
        token for token in result_bigrams if token != 'psychological_association']

    result_trigrams = ['_'.join(x) for x in ngrams(result_singles, 3)]
    result_two_plus = result_singles + result_bigrams
    result_three_plus = result_singles + result_bigrams + result_trigrams

    if n_grams == 'one':
        result = result_singles
    elif n_grams == 'two':
        result = result_bigrams
    elif n_grams == 'three':
        result = result_trigrams
    elif n_grams == 'two_plus':
        result = result_two_plus
    elif n_grams == 'three_plus':
        result = result_three_plus

    return result


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
# ------------------------------------------------------------------------------------ #


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


# weights = ['ncf', 'now', 'sf'] 
# inflation = ['20', '30', '40', '60']

name = argv[1]
val = argv[2]
start_cluster_num = argv[3]
        
title_abstract_table = 'top_scp_title_concat_abstract_english'


jsd_output = pd.DataFrame()


cluster_table = name + '_' + val + '_ids'
print("Querying: ", cluster_table)


max_query = "SELECT MAX(cluster) FROM " + cluster_table + ";"

curs.execute(max_query, conn)
max_cluster_number = curs.fetchone()[0]

for cluster_num in range(int(start_cluster_num), max_cluster_number+1):
            
    print("Querying Cluster Number: ", str(cluster_num))


    query = "SELECT tat.*, clt.cluster " + "FROM " + cluster_table +  " AS clt " + "LEFT JOIN " + title_abstract_table + " AS tat " + "ON clt.scp = tat.scp " + "WHERE clt.cluster=" + str(cluster_num) + ";"

    print(query)


    mcl_data = pd.read_sql(query, conn)

    print('The size of the cluster is: ', len(mcl_data))
    original_cluster_size = len(mcl_data)
    mcl_data = mcl_data.dropna()
    print('Size after removing missing titles and abstracts: ', len(mcl_data))
    final_cluster_size = len(mcl_data)


    if final_cluster_size < 10:

        print("")
        print("The cluster size is inadequate.")
        print("Moving to next cluster.")
        print("")

    else:

        data_text = mcl_data.copy()
        data_text['scp'] = data_text.astype('str')

        data_text['all_text'] = data_text['title'] + data_text['abstract_text']
        
#         p = mp.Pool(mp.cpu_count())
#         data_text['processed_all_text'] = p.map(preprocess_text, data_text['all_text'])
#         p.close()

        data_text['processed_all_text'] = data_text['all_text'].swifter.apply(preprocess_text)
    
        print("")
        print("")
        data_text['processed_all_text_frequencies'] = data_text['processed_all_text'].swifter.apply(get_frequency)
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

        result_df.to_csv("/home/shreya/mcl_jsd/JSD_output_unigrams.csv", mode = 'a', index = None, header=False, encoding='utf-8')
        
        print("")

print("ALL COMPLETED.")
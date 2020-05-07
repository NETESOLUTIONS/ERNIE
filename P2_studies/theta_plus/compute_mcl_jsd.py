"""
Command line arguments:

[1] type of weight - choose from (ncf, now, sf)
[2] inflation values - choose from (20, 30, 40, 60)
[3] start from cluster number - ideally 1

"""



from scipy.spatial import distance
from sklearn.feature_extraction.text import TfidfTransformer
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

# ------------------------------------------------------------------------------------ #

stop_words = stopwords.words('english')
f = open('/home/shreya/mcl_jsd/nih_stopwords.txt', 'r')
stop_words.extend([word.rstrip('\n') for word in f])
f.close()
stop_words.extend(['a', 'in', 'of', 'the', 'at', 'on', 'and', 'with', 'from', 'to', 'for',
                   'some', 'but', 'not', 'their', 'human', 'mouse', 'rat', 'monkey', 'man',
                   'method', 'during', 'process', 'hitherto', 'unknown', 'many', 'these',
                   'have', 'into', 'improved', 'use', 'find', 'show', 'may', 'study', 'result',
                   'contain', 'day', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight',
                   'nine', 'ten', 'give', 'also', 'suggest', 'data', 'number', 'right reserved',
                   'right', 'reserve', 'society', 'american', 'publish', 'group', 'wiley', 'depend',
                   'upon', 'good', 'within', 'small', 'amount', 'large', 'quantity', 'control',
                   'complete', 'record', 'task', 'effect', 'single', 'database', 'ref',
                   'ref', 'university', 'press', 'psycinfo', 'apa', 'inc', 'alan', 'find', 'finding',
                   'perform', 'new', 'reference', 'noticeable', 'america', 'copyright', 'attempt', 'make',
                   'theory', 'demonstrate', 'present', 'analysis', 'other', 'due', 'receive', 'rabbit',
                   'property', 'e.g.', 'and/or', 'or', 'unlikely', 'nih', 'cause', 'best', 'well',
                   'without', 'whereas', 'whatever', 'require', 'wiley', 'aaa', 'whether', 'require',
                   'relevant', 'take', 'together', 'appear'])  # ---> updated based on results


def preprocess_text(doc, n_grams='two'):
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

def get_doc_term_mat(corpus_by_article, corpus_by_cluster):
    
    """
    Argument(s): corpus_by_article - (list of lists)
                 corpus_by_cluster - flattened list 

    Output(s): doc_term_prob_mat, cluster_prob_mat
    """

    count_vectorizer = CountVectorizer(lowercase=False, vocabulary=list(set(corpus_by_cluster[0].split())))
    cluster_count_mat = count_vectorizer.fit_transform(corpus_by_cluster)
    doc_term_count_mat = count_vectorizer.transform(corpus_by_article)

    prob_transformer = TfidfTransformer(norm='l1', use_idf=False, smooth_idf=False)
    
    doc_term_prob_mat = prob_transformer.fit_transform(doc_term_count_mat)
    cluster_prob_mat = prob_transformer.fit_transform(cluster_count_mat)
    
    return doc_term_prob_mat, cluster_prob_mat

# ------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------ #


import psycopg2

with open('/home/shreya/mcl_jsd/ernie_password.txt') as f:
    ernie_password = f.readline()

conn=psycopg2.connect(database="ernie",user="shreya",host="localhost",password=ernie_password)
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

for cluster_num in range(start_cluster_num, max_cluster_number+1):
            
    print("Querying Cluster Number: ", str(cluster_num))


    query = "SELECT clt.scp, tat.title, tat.abstract_text, clt.cluster " + "FROM " + cluster_table +  " AS clt " + "LEFT JOIN " + title_abstract_table + " AS tat " + "ON clt.scp = tat.scp " + "WHERE clt.cluster=" + str(cluster_num) + ";"

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
        data_text['processed_title'] = data_text['title'].swifter.apply(preprocess_text)
        data_text['processed_abstract'] = data_text['abstract_text'].swifter.apply(preprocess_text)

        data_text['processed_all_text'] = data_text['processed_title'] + data_text['processed_abstract']
        data_text['processed_all_text_frequencies'] = data_text['processed_all_text'].swifter.apply(get_frequency)
        data_all_text_frequency = merge_vocab_dictionary(data_text['processed_all_text_frequencies'])
        retained_dict = remove_less_than(data_all_text_frequency)
        data_text['filtered_text'] = data_text['processed_all_text'].swifter.apply(filter_after_preprocess, args = (retained_dict,))

        mcl_all_text = data_text.filtered_text.tolist()
        corpus_by_article = [' '.join(text) for text in mcl_all_text]
        corpus_by_cluster = [' '.join(corpus_by_article)]

        doc_term_prob_mat, cluster_prob_mat = get_doc_term_mat(corpus_by_article, corpus_by_cluster)
        cluster_prob_vec = cluster_prob_mat.toarray().tolist()[0]

        data_text['doc_term_prob'] = doc_term_prob_mat.toarray().tolist()

        def calculate_jsd(doc_prob_vec, cluster_prob_vec = cluster_prob_vec):

            jsd = distance.jensenshannon(doc_prob_vec, cluster_prob_vec)

            return jsd


        data_text['JS_distance'] = data_text['doc_term_prob'].swifter.apply(calculate_jsd)
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

#                 print("")
#                 print('Minimum JSD value for the cluster is: ', jsd_min)
#                 print('25th Percentile JSD value for the cluster is: ', jsd_25_percentile)
#                 print('Median JSD value for the cluster is: ', jsd_median)
#                 print('75th Percentile JSD value for the cluster is: ', jsd_75_percentile)
#                 print('Maximum JSD value for the cluster is: ', jsd_max)
#                 print('Mean JSD value for the cluster is: ', jsd_mean)
#                 print('Std Dev of JSD for the cluster is: ', np.std(data_text['JSD']))
#                 print("")


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
            'total_unique_bigrams': len(data_all_text_frequency),
            'final_unique_bigrams': len(retained_dict),
            'size_1_bigram_prop': (1-(len(retained_dict)/len(data_all_text_frequency)))})

        jsd_output = jsd_output.append(result_df)
        result_df.to_csv("/home/shreya/mcl_jsd/JSD_output.csv", mode = 'a', index = None, header=False, encoding='utf-8')

                


print("ALL COMPLETED.")
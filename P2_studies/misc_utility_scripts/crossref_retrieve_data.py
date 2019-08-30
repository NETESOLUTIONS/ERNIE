"""
Title: Cross-ref retrieve doi function
Author: Djamil Lakhdar-Hamina
Date: 08/27/2019
"""

############################################################################################################

import requests
import json
import itertools as itert
import pandas as pd

def crossref_retrieve_data(title_list):
    """
    :param : a sequence of titles to publications
    :return: a data_frame with title, doi, journal, and pub date

    Example of use:

    1.Turn the csv into pandas dataframe (or series)
    recomb_df = pd.read_csv("RECOMB_titles.csv")

    2. If it is more than 50 titles simply slice it
    sample_recomb_df= recomb_df[:50]
gi
    result= crossref_retrieve_data(input_list)
    """

    url_form = 'https://api.crossref.org/works?query.title='
    query_paramters = '&select=title,DOI,container-title&mailto=dl2774@columbia.edu&rows=1000'

    ## if the input is a list then join all the elements into one string using ' ' as a separator, check if empty dataframe
    if isinstance(title_list, pd.DataFrame):
        title_string = ' '.join(title_list['title'].tolist())
        title_split_list = title_string.replace(' ', '+')
    elif isinstance(title_list, pd.Series):
        title_string = ' '.join(title_list.tolist())
        title_split_list = title_string.replace(' ', '+')
    elif isinstance(title_list, list):
        title_string = ' '.join(title_list)
        title_split_list = title_string.replace(' ', '+')
    ## if the input is already a string of all the different publications simply add + in between ' '

    else:
        title_split_list = title_list.replace(' ', '+')

    ## form the request object, based on parameters found here https://github.com/CrossRef/rest-api-doc
    url = url_form + title_split_list + query_paramters
    rsp = requests.get(url)
    dict_object = json.loads(rsp.text)
    items_list = dict_object.get('message').get('items')

    ## initialize local variables to operate after loop
    doi_array = []
    title_array = []
    journal_array = []
    publication_date_array = []
    for item in items_list:
        if item['DOI']:
            value = item['DOI']
            doi_array.append(value)
        if item['title']:
            value = item['title'][0]
            title_array.append(value)
        if 'container-title' in item:
            value = item['container-title'][0]
            journal_array.append(value)
        if 'created' in item:
            value = item['created']['date-time']
            publication_date_array.append(value)

    ## method to generate pandas dataframe with unequal length sequences (list, series, etc.)
    data_df = pd.DataFrame(list(itert.zip_longest(title_array,
                                                  doi_array, journal_array,
                                                  publication_date_array)), columns=['Title',
                                                                                     'DOI','Journal','Publication-Date'])

    return data_df

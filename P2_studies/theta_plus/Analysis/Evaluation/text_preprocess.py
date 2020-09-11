#!/usr/bin/env python3
"""
@author: Shreya Chandrasekharan

This script pre-processes all text based information (title and abstracts)
for any clustering and outputs tokens correspoding to each document.
These tokens may then be used for any NLP computation.

Argument(s): schema                - database schema containing the table
             title_abstracts_table - a database table containing all titles and abstracts
                                     to be pre-processed 
             user_name             - database username
             password              - database password

Output:      data_text             - a new table containing the same columns as the 
                                     title_abstracts_table including a processed tokens column
"""

import jsd_modules as jm
import pandas as pd
from sqlalchemy import create_engine
from sys import argv

schema = argv[1]
title_abstracts_table = argv[2]
user_name = argv[3]
password = argv[4]

sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)

data_text = pd.read_sql_table(table_name=title_abstracts_table, schema=schema, con=engine)

data_text['all_text'] = data_text["title"] + " " + data_text["abstract_text"]
data_text['processed_all_text'] = data_text["all_text"].swifter.apply(jm.preprocess_text)
data_text['processed_all_text'] = data_text["processed_all_text"].swifter.progress_bar(False).apply(' '.join)
# Use pandas.Series.str.split() to get back list of tokens

# In case the connection times out:
engine = create_engine(sql_scheme)
save_name = title_abstracts_table + '_processed'
data_text.to_sql(save_name, con=engine, schema=schema, index=False, if_exists='fail')

print("All Completed.")
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov 19 10:09:11 2018

@author: sitaram
"""

import pandas as pd
import numpy as np
from collections import Counter
from itertools import combinations
import sys
import re

# Arguments passed are filename,instance number,source location,destination location
filename = sys.argv[1]
# number = sys.argv[2]
source_location = sys.argv[2]
destination_location = sys.argv[3]

number=re.findall(r'\d+',filename)[1]
print(filename)
print(source_location)
print(destination_location)
print(number)

print('Working on file', filename)


def combinations_function(x):
    #     print(x[0])
    if len(x) == 1:
        return [(x[0], x[0])]
    else:
        return list(combinations(x, 2))


def generate_obs_freq(df, slice_num):
    # print('calculating combinations and frequencies')
    # Group by source_id and collect all reference_issn to store as list
    df = df.groupby(['source_id'])['s_reference_issn'].apply(list).values

    # Calculating the journal pairs for each publication
    df = list(map(combinations_function, df))

    # Flattening the list and storing it as dataframe
    df = pd.DataFrame([z for x in df for z in x], columns=['A', 'B'])
    df['journal_pairs'] = df['A'] + ',' + df['B']

    # Getting the aggregated count of each journal pair
    df = df['journal_pairs'].value_counts()
    df = pd.DataFrame({'journal_pairs': df.index, 'frequency': df.values})
    # print('Done file number ',number)
    # final_counts.to_csv(destination_location+'bg_freq_'+str(number)+'.csv',index=False)
    if slice_num == 0:
        df.to_csv(destination_location + 'bg_freq_' + str(number) + '.csv', index=False)
    else:
        df.to_csv(destination_location + 'bg_freq_' + str(number) + '.csv', mode='a', index=False, header=False)


# Column names to read
fields = ['source_id', 's_reference_issn']

# Reading input file
data_set = pd.read_csv(source_location + filename, usecols=fields)

# Sorting the input file by source_id and reference_issn
# print('sorting by source_id')
data_set.sort_values(by=['source_id', 's_reference_issn'], inplace=True)
data_set.reset_index(inplace=True)

end_point = 4000000
start_point = 0
total_len = len(data_set)

if total_len < 4000000:
    # print('Entered if block')
    generate_obs_freq(data_set, 0)
else:
    # print('Entered else block')
    slice_num = 0
    source_id = data_set['source_id'][end_point]
    while end_point <= total_len:
        end_point += 1
        if source_id != data_set['source_id'][end_point]:
            # print('end_point',data_set['source_id'][end_point])
            # print('end_point-1',data_set['source_id'][end_point-1])
            generate_obs_freq(data_set.iloc[start_point:end_point, :], slice_num)
            slice_num += 1
            start_point = end_point
            end_point += 4000000
            if end_point < total_len:
                source_id = data_set['source_id'][end_point]
            if end_point > total_len:
                end_point = total_len
                generate_obs_freq(data_set.iloc[start_point:, :], slice_num)
                end_point = total_len + 1

data_set = pd.read_csv(destination_location + 'bg_freq_' + str(number) + '.csv')
data_set = data_set.groupby(by=['journal_pairs'], as_index=False)['frequency'].sum()
data_set.to_csv(destination_location + 'bg_freq_' + str(number) + '.csv', index=False)

print('Done file number ', number)

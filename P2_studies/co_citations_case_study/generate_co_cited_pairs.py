#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Dec 17 16:09:11 2019

@author: sitaram
"""

import pandas as pd
import numpy as np
import argparse
import time
from itertools import combinations
import sys

filename=sys.argv[1]
destination_file=sys.argv[2]

def combinations_function(x):
#     print(x[0])
    return list(combinations(x,2))

def generate_obs_freq(df,number):
    print('calculating combinations and frequencies')

    df=df.groupby(['scp'])['ref_sgr'].apply(list).values

    df=list(map(combinations_function,df))

    print('Flattening the list and creating citation pairs')

    df=pd.DataFrame([z for x in df for z in x],columns=['cited_1','cited_2'])

    print('calculating value count')

    # df=df.groupby(['cited_1','cited_2']).size().reset_index(name='frequency')
    df=df.drop_duplicates()

    if number==0:
        df.to_csv(destination_file,index=False)
    else:
        df.to_csv(destination_file,mode='a',index=False,header=False)

#Column names to read
fields=['scp','ref_sgr']

#Reading input file
print('Reading input file')
data_set=pd.read_csv(filename)

data_set.columns=fields

#Sorting the input file by source_id and reference_issn
print('sorting by source_id')
data_set.sort_values(by=['scp','ref_sgr'],inplace=True)
data_set.reset_index(inplace=True)

end_point=4000000
start_point=0
total_len=len(data_set)

if total_len < 4000000:
    print('Entered if block')
    generate_obs_freq(data_set,0)
else:
    print('Entered else block')
    number=0
    source_id=data_set['scp'][end_point]
    while end_point <= total_len:
        end_point+=1
        if source_id != data_set['scp'][end_point]:
            #print('end_point',data_set['source_id'][end_point])
            #print('end_point-1',data_set['source_id'][end_point-1])
            generate_obs_freq(data_set.iloc[start_point:end_point,:],number)
            number+=1
            start_point=end_point
            end_point+=4000000
            if end_point < total_len:
                source_id=data_set['scp'][end_point]
            if end_point > total_len:
                end_point=total_len
                generate_obs_freq(data_set.iloc[start_point:,:],number)
                end_point=total_len+1

print('Done writing obs_freq file')

data_set=pd.read_csv(destination_file)
data_set=data_set.drop_duplicates()
data_set.to_csv(destination_file,index=False)
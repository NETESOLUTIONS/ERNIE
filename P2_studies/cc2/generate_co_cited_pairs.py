#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov 19 10:09:11 2018

@author: sitaram
"""

import pandas as pd
import numpy as np
import datatable as dt
from collections import Counter
from itertools import combinations
import sys

#Arguments passed are filename,instance number,source location,destination location
filename=sys.argv[1]
destination_file=sys.argv[2]

def combinations_function(x):
    return list(combinations(x,2))


def generate_obs_freq(df,number):
    print('calculating combinations and frequencies')
    #Group by source_id and collect all cited_source_uid to store as list
    df=df.groupby(['source_id'])['cited_source_uid'].apply(list).values    

    #Calculating the journal pairs for each publication
    df=list(map(combinations_function, df))

    #Flattening the list and storing it as dataframe
    print('Flattening the list and creating journal_pairs')
    df=pd.DataFrame([z for x in df for z in x],columns=['cited_1','cited_2'])
    # df['journal_pairs']=df['A']+','+df['B']

    #Getting the aggregated count of each journal pair
    print('Calculating value cout')
    df=df.groupby(by=['cited_1','cited_2']).size().reset_index()
    df.columns=['cited_1','cited_2','frequency']
    # df=df['journal_pairs'].value_counts()
    # df=pd.DataFrame({'journal_pairs':df.index,'frequency':df.values})
    # print('Writing to csv file')
    # df.to_csv(destination_file,index=False)
    if number==0:
        df.to_csv(destination_file,index=False)
    else:
        df.to_csv(destination_file,mode='a',index=False,header=False)

#Column names to read
fields=['source_id','cited_source_uid']

#Reading input file
print('Reading input file')
data_set=pd.read_csv(filename,usecols=fields)

#Sorting the input file by source_id and cited_source_uid
print('sorting by source_id')
data_set.sort_values(by=['source_id','cited_source_uid'],inplace=True)
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
    source_id=data_set['source_id'][end_point]
    while end_point <= total_len:
        end_point+=1
        if source_id != data_set['source_id'][end_point]:
            #print('end_point',data_set['source_id'][end_point])
            #print('end_point-1',data_set['source_id'][end_point-1])
            generate_obs_freq(data_set.iloc[start_point:end_point,:],number)
            number+=1
            start_point=end_point
            end_point+=4000000
            if end_point < total_len:
                source_id=data_set['source_id'][end_point]
            if end_point > total_len:
                end_point=total_len
                generate_obs_freq(data_set.iloc[start_point:,:],number)
                end_point=total_len+1

print('Done writing obs_freq file')


#Read and writing with datatable to improve speed
data_set=dt.fread(destination_file)
data_set=data_set.to_pandas()

# data_set=pd.read_csv(destination_file)
data_set=data_set.groupby(by=['cited_1','cited_2'])['frequency'].sum().reset_index()
data_set.columns=['cited_1','cited_2','frequency']
data_set=dt.Frame(data_set)
data_set.to_csv(destination_file)
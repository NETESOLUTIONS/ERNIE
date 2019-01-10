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

#Arguments passed are filename,instance number,source location,destination location
filename=sys.argv[1]
number=sys.argv[2]
source_location=sys.argv[3]
destination_location=sys.argv[4]

#column_names=['source_id','source_year','source_issn','source_document_id_type',
#              'cited_source_uid','reference_year','reference_issn',
#              'reference_document_id_type']

#Column names to read
fields=['source_id','s_reference_issn']

#Reading input file
df=pd.read_csv(source_location+filename,usecols=fields)

#Sorting the input file by source_id and reference_issn
print('sorting by source_id')
df.sort_values(by=['source_id','s_reference_issn'],inplace=True)
df.reset_index(inplace=True)

print('calculating combinations and frequencies')
#Group by source_id and collect all reference_issn to store as list
journal_list=df.groupby(['source_id'])['s_reference_issn'].apply(list).values

def combinations_function(x):
#     print(x[0])
    if len(x)==1:
        return [(x[0],x[0])]
    else:
        return list(combinations(x,2))
    

#Calculating the journal pairs for each publication
pairs=list(map(combinations_function, journal_list))

#Flattening the list and storing it as dataframe
df_=pd.DataFrame([z for x in pairs for z in x],columns=['A','B'])
df_['journal_pairs']=df_['A']+','+df_['B']

#Getting the aggregated count of each journal pair
final_counts=df_['journal_pairs'].value_counts()
final_counts=pd.DataFrame({'journal_pairs':final_counts.index,'frequency':final_counts.values})
print('Done generating final file')
final_counts.to_csv(destination_location+'bg_freq_'+str(number)+'.csv',index=False)

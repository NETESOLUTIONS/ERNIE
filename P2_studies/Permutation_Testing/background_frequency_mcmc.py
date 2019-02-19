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

filename=sys.argv[1]
source_location=sys.argv[2]
destination_location=sys.argv[3]
lookup_file=sys.argv[4]


mcmc=pd.read_csv(source_location+filename)
lookup=pd.read_csv(lookup_file)
df=pd.merge(mcmc,lookup,on=['cited_source_uid'],how='inner')

#Sorting the input file by source_id and reference_issn
print('sorting by source_id')
df.sort_values(by=['source_id','reference_issn'],inplace=True)
df.reset_index(inplace=True)

print('calculating combinations and frequencies')
#Group by source_id and collect all reference_issn to store as list
journal_list=df.groupby(['source_id'])['reference_issn'].aapply(list).values


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
final_counts.to_csv(destination_location+filename.split('.')[0]+'_freq_'+'.csv',index=False)
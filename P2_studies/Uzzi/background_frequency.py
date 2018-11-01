#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 29 12:22:23 2018

@author: sitaram
"""

import pandas as pd
import numpy as np
from collections import Counter
from itertools import combinations
from os import listdir
from os.path import isfile, join
import sys

#Generating frequency for rest of the 10 files

file_name=sys.argv[1]

files = [f for f in listdir('Uzzi_data/'+file_name.split('.')[0]+'/') if isfile(join('Uzzi_data/'+file_name.split('.')[0]+'/', f))]
for file in files:
    print('Generating background network frequency for ',file)
    data_set=pd.read_csv('Uzzi_data/'+file_name.split('.')[0]+'/'+file)
    df=data_set.sort_values(by=['source_issn'])[['source_issn','reference_issn','reference_year']]

    df=df.reset_index(drop=True)
    reference_name=df['source_issn'][0]
    ll=[]
    combo=[]
    
    for index,row in df.iterrows():
        if row['source_issn']==reference_name:
            ll.append(row['reference_issn'])
        else:
            ll.sort()
            if len(ll)==1:
    #            no_of_pairs=len(ll)
                no_of_pairs=1
                combo.extend([(ll[0],ll[0])])
            else:
                no_of_pairs=((len(ll)*(len(ll)-1))/2)
                combo.extend(list(combinations(ll,2)))
            ll.clear()
            reference_name=row['source_issn']
            ll.append(row['reference_issn'])
    reference_name=df['source_issn'][0]
    
    df_=pd.DataFrame(combo,columns=['A','B'])
    df_['journal_pairs']=df_['A']+','+df_['B']

    final_counts=df_['journal_pairs'].value_counts()
    final_counts=pd.DataFrame({'journal_pairs':final_counts.index,'frequency':final_counts.values})
    final_counts.to_csv('Uzzi_data/'+file_name.split('.')[0]+'/background_network_'+file,index=False)
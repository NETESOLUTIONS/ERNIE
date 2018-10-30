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

data_set=pd.read_csv('gc_mc.csv')
print('Generating observed frequecy')

#data_set=pd.read_csv('/Users/sitaram/Documents/UZZI/gc_mc/'+str(i)+'.csv')

#df=data_set.sort_values(by=['source_id','source_issn'])[['source_id','source_issn','reference_issn']]
df=data_set.sort_values(by=['source_issn'])[['source_issn','reference_issn','reference_year']]

df=df.reset_index(drop=True)

#Get the number of pairs for each wos_id and generate column with that many values
#Then put all the reference pairs in the corresponding column

reference_name=df['source_issn'][0]
ll=[]
combo=[]
source_values=[]

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
        source_values.extend([reference_name]*int(no_of_pairs))    
        ll.clear()
        reference_name=row['source_issn']
        ll.append(row['reference_issn'])
        

df_=pd.DataFrame(combo,columns=['A','B'])

df_['source_issn']=pd.Series(source_values)
df_['journal_pairs']=df_['A']+','+df_['B']

final_counts=df_['journal_pairs'].value_counts()
final_counts=pd.DataFrame({'journal_pairs':final_counts.index,'frequency':final_counts.values})
final_counts.to_csv('observed_frequency.csv',index=False)

final_values=df_.iloc[:,2:]

full_list=pd.merge(final_values,final_counts,on='journal_pairs',how='inner')

full_list.to_csv('full_list.csv',index=False)

#Generating frequency for rest of the 10 files


files = [f for f in listdir('gc_mc/') if isfile(join('gc_mc', f))]
for file in files:
    print('Generating background network frequency for ',file)
    data_set=pd.read_csv('gc_mc/'+file)
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
            source_values.extend([reference_name]*int(no_of_pairs))    
            ll.clear()
            reference_name=row['source_issn']
            ll.append(row['reference_issn'])
    reference_name=df['source_issn'][0]
    
    df_=pd.DataFrame(combo,columns=['A','B'])
    df_['journal_pairs']=df_['A']+','+df_['B']

    final_counts=df_['journal_pairs'].value_counts()
    final_counts=pd.DataFrame({'journal_pairs':final_counts.index,'frequency':final_counts.values})
    final_counts.to_csv('gc_mc/background_network_frequency_'+file,index=False)
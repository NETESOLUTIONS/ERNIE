#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Oct 30 10:51:16 2018

@author: sitaram
"""

import pandas as pd
import numpy as np
from collections import Counter
from itertools import combinations
from os import listdir
from os.path import isfile, join
import sys

file_name=sys.argv[1]

data_set=pd.read_csv('Uzzi_data/'+file_name)
print('Generating observed frequecy')

df=data_set.sort_values(by=['source_id'])[['source_id','source_issn','reference_issn','reference_year']]

df=df.reset_index(drop=True)

#Get the number of pairs for each wos_id and generate column with that many values
#Then put all the reference pairs in the corresponding column

reference_name=df['source_id'][0]
ll=[]
combo=[]
source_values=[]

for index,row in df.iterrows():
    if row['source_id']==reference_name:
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
        reference_name=row['source_id']
        ll.append(row['reference_issn'])
        

df_=pd.DataFrame(combo,columns=['A','B'])

df_['source_id']=pd.Series(source_values)
df_['journal_pairs']=df_['A']+','+df_['B']

final_counts=df_['journal_pairs'].value_counts()
final_counts=pd.DataFrame({'journal_pairs':final_counts.index,'frequency':final_counts.values})
final_counts.to_csv('Uzzi_data/observed_frequency.csv',index=False)

final_values=df_.iloc[:,2:]

full_list=pd.merge(final_values,final_counts,on='journal_pairs',how='inner')

#full_list.to_csv('full_list_test.csv',index=False)

#Calculating mean and standard deviation
files = [f for f in listdir('Uzzi_data/'+file_name.split('.')[0]+'/') if isfile(join('Uzzi_data/'+file_name.split('.')[0]+'/', f)) and f.startswith('background')]
print('Computing mean,standard deviation and z scores')
data_set=pd.read_csv('Uzzi_data/'+file_name.split('.')[0]+'/'+files[0])
for i in range(1,len(files)):
    data_set1=pd.read_csv('Uzzi_data/'+file_name.split('.')[0]+'/'+files[0])
    #print(len(data_set1))
    data_set=data_set.append(data_set1,ignore_index=True)

#calculate mean and standard deviation
temp=data_set.groupby(['journal_pairs']).sum()

mean=temp['frequency'].mean()
std=temp.std(axis=0)

print('mean is ',str(mean))
print('standard deviation is',str(std[0]))


#Calculating z scores
full_list['z_scores']=(full_list['frequency']-mean)/std[0]
full_list.to_csv('Uzzi_data/final_list.csv',index=False)
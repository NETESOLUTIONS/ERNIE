#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Oct 31 23:07:47 2018

@author: sitaram
"""

import pandas as pd
import numpy as np
from collections import Counter
from itertools import combinations
import sys

filename=sys.argv[1]
z_scores=sys.argv[2]
destination_file=sys.argv[3]

column_names=['source_id','source_year','source_issn','source_document_id_type','cited_source_uid',
              'reference_year','reference_issn','reference_document_id_type']

fields=['source_id','cited_source_uid','reference_issn']


data_set=pd.read_csv(filename,usecols=fields)
print('Generating Lookup Table')

#Sorting the input file by source_id and reference_issn
data_set.sort_values(by=['source_id','reference_issn','cited_source_uid'],inplace=True)
data_set.reset_index(inplace=True)

reference_name=data_set['source_id'][0]
ll=[]
cc=[]
combo=[]
ui_combo=[]
source_values=[]

#Calculating the pairs for journal and cited references
print('looping through and creating pairs')
for index,row in data_set.iterrows():
    if row['source_id']==reference_name:
        ll.append(row['reference_issn'])
        cc.append(row['cited_source_uid'])
    else:
        ll.sort()
        cc.sort()
        if len(ll)==1:
            no_of_pairs=1
            combo.extend([(ll[0],ll[0])])
            ui_combo.extend([(cc[0],cc[0])]) 
        else:
            no_of_pairs=((len(ll)*(len(ll)-1))/2)
            combo.extend(list(combinations(ll,2)))
            ui_combo.extend(list(combinations(cc,2)))
        source_values.extend([reference_name]*int(no_of_pairs))    
        ll.clear()
        cc.clear()
        reference_name=row['source_id']
        ll.append(row['reference_issn'])
        cc.append(row['cited_source_uid'])
        
print('Calculating pairs done')

del(data_set)
df_c=pd.DataFrame(ui_combo,columns=['C','D'])
df_c['source_id']=pd.Series(source_values)
df_c['wos_id_pairs']=df_c['C']+','+df_c['D']

df_=pd.DataFrame(combo,columns=['A','B'])
df_c['journal_pairs']=df_['A']+','+df_['B']

del(df_)
print('len of file',len(df_c))

print('Join with z scores file to create final lookup table')
data_set=pd.read_csv(z_scores)

#Joining with z scores to develop final table
full_list=pd.merge(df_c.iloc[:,2:],data_set,on='journal_pairs',how='inner')
print('Writing to file')
full_list.to_csv(destination_file,index=False)

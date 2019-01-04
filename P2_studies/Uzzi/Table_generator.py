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

def combinations_function(x):
#     print(x[0])
    if len(x)==1:
        return [(x[0],x[0])]
    else:
        return list(combinations(x,2))

def generate_table(data_set,number):
    data_set.reset_index(inplace=True,drop=True)
    reference_name=data_set['source_id'][0]
    ll=[]
    cc=[]
    combo=[]
    ui_combo=[]
    source_values=[]

    journal_list=data_set.groupby(['source_id'])['reference_issn'].apply(list).values

    #Calculating the journal pairs for each publication
    pairs=list(map(combinations_function, journal_list))

    #Calculating the pairs for journal and cited references
    print('looping through and creating pairs')
    for index,row in data_set.iterrows():
        if row['source_id']==reference_name:
            ll.append(row['reference_issn'])
            # cc.append(row['cited_source_uid'])
        else:
            ll.sort()
            # cc.sort()
            if len(ll)==1:
                no_of_pairs=1
                # combo.extend([(ll[0],ll[0])])
                # ui_combo.extend([(cc[0],cc[0])]) 
            else:
                no_of_pairs=((len(ll)*(len(ll)-1))/2)
                # combo.extend(list(combinations(ll,2)))
                # ui_combo.extend(list(combinations(cc,2)))
            source_values.extend([reference_name]*int(no_of_pairs))    
            ll.clear()
            # cc.clear()
            reference_name=row['source_id']
            ll.append(row['reference_issn'])
            # cc.append(row['cited_source_uid'])
            
    print('Calculating pairs done')

    del(data_set)

    df_c=pd.DataFrame([z for x in pairs for z in x],columns=['A','B'])
    df_c['journal_pairs']=df_c['A']+','+df_c['B']
    df_c['source_id']=pd.Series(source_values)

    # del(df_)
    print('len of file',len(df_c))

    print('Join with z scores file to create final lookup table')
    data_set=pd.read_csv(z_scores)

    #Joining with z scores to develop final table
    full_list=pd.merge(df_c.iloc[:,2:],data_set,on='journal_pairs',how='inner')
    print('Writing to file')
    if number==0:
        full_list.to_csv(destination_file,index=False)
    else:
        full_list.to_csv(destination_file,mode='a',index=False,header=False)

filename=sys.argv[1]
z_scores=sys.argv[2]
destination_file=sys.argv[3]

column_names=['source_id','source_year','source_issn','source_document_id_type','cited_source_uid',
              'reference_year','reference_issn','reference_document_id_type']

fields=['source_id','reference_issn']

data_set=pd.read_csv(filename,usecols=fields)
print('Generating Lookup Table')

#Sorting the input file by source_id and reference_issn
data_set.sort_values(by=['source_id','reference_issn'],inplace=True)
data_set.reset_index(inplace=True,drop=True)

end_point=4000000
start_point=0
total_len=len(data_set)

if total_len < 4000000:
    print('Entered if block')
    generate_table(data_set,0)
else:
    print('Entered else block')
    number=0
    source_id=data_set['source_id'][end_point]
    while end_point <= total_len:
        end_point+=1
        if source_id != data_set['source_id'][end_point]:
            print('end_point',data_set['source_id'][end_point])
            print('end_point-1',data_set['source_id'][end_point-1])
            generate_table(data_set.iloc[start_point:end_point,:],number)
            number+=1
            start_point=end_point
            end_point+=4000000
            if end_point < total_len:
                source_id=data_set['source_id'][end_point]
            if end_point > total_len:
                end_point=total_len
                generate_table(data_set.iloc[start_point:,:],number)
                end_point=total_len+1
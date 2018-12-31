#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Nov 17 15:50:11 2018

@author: sitaram
"""

import pandas as pd
import os,sys

#location of all background network files and number of files
bg_files=sys.argv[1]
number=int(sys.argv[2])
observed_file=sys.argv[3]

obs_file=pd.read_csv(observed_file)
print('length of original frequency file ',len(obs_file['frequency'].dropna()))
obs_file.columns=['journal_pairs','obs_frequency']
file_names=os.listdir(bg_files)
file_names.sort()

#Performing left join on each file to obtain only journal pairs which have frequency
for i in range(0,number):
    data=pd.read_csv(bg_files+file_names[i])
    print("Joining on file",file_names[i])
    obs_file=pd.merge(obs_file,data,on=['journal_pairs'],how='left')
    
print('\n')
obs_file.to_csv(bg_files+'combined.csv',index=False)

#Renaming column names
column_names=['journal_pairs','obs_frequency']
column_names.extend([x for x in range(1,number+1)])
obs_file.columns=column_names

#Calculating the mean
obs_file['mean']=obs_file.iloc[:,2:].mean(axis=1)
print('length of file after 100 joins ',len(obs_file['mean'].dropna()))

#Calculating the standard deviation
obs_file['std']=obs_file.iloc[:,2:number+2].std(axis=1)
print('length of frequency ',len(obs_file['obs_frequency'].dropna()))

#Calculating z_scores
obs_file['z_scores']=(obs_file['obs_frequency']-obs_file['mean'])/obs_file['std']
print('length of files after removing null values ',len(obs_file[['journal_pairs','obs_frequency','z_scores']].dropna()))

obs_file[['journal_pairs','obs_frequency','z_scores']].dropna().to_csv(bg_files+'z_scores_file.csv',index=False)

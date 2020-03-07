#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import pandas as pd
import numpy as np
import argparse
import time
import sys


kinetics_filename=sys.argv[1]
time_lag_file=sys.argv[2]
output_filename=sys.argv[3]
final_output_filename=sys.argv[4]

# print(final_output_filename)

df=pd.read_csv(kinetics_filename)

#dropping null values
df=df.dropna()
df['co_cited_year']=df['co_cited_year'].astype(int)
df['frequency']=df['frequency'].astype(int)

y_df=pd.read_csv(time_lag_file)

y_df=y_df[['cited_1','cited_2','cited_1_year','cited_2_year','first_co_cited_year']]

# print(df.head())


zero_df=pd.merge(df,y_df,on=['cited_1','cited_2'],how='inner')

#Faulty co-cited data should be eliminated here
zero_df=zero_df[zero_df['co_cited_year']>=zero_df['first_co_cited_year']]

zero_df['pfcy']=zero_df[['cited_1_year','cited_2_year']].max(axis=1)

zero_df=zero_df.drop(columns=['cited_1_year','cited_2_year'])
print('printing zero df')
print(zero_df)

#First write code to generate 0 rows of data

#Get all data where pfcy 
#temp_df=zero_df.groupby(by=['cited_1','cited_2'],as_index=False)['first_co_cited_year','pfcy'].min()
temp_df=zero_df.groupby(by=['cited_1','cited_2'],as_index=False)['first_co_cited_year','co_cited_year','pfcy'].min()

# print(temp_df.head())
#print(temp_df[(temp_df['cited_1']==14949207) & (temp_df['cited_2']==17184389)])
#temp_df=temp_df[temp_df['pfcy'] < temp_df['first_co_cited_year']]
temp_df=temp_df[temp_df['pfcy'] < temp_df['co_cited_year']]

print('debug prints')
print(temp_df)

#temp_df.columns=['cited_1','cited_2','first_co_cited_year','pfcy']

print('debug prints')
print(temp_df)

temp_df['diff']=temp_df['co_cited_year']-temp_df['pfcy']

temp_df['cited_1']=temp_df['cited_1'].astype(int)

temp_df=temp_df.loc[temp_df.index.repeat(temp_df['diff'])]

temp_df['rank']=temp_df.groupby(by=['cited_1','cited_2'])['pfcy'].rank(method='first')
temp_df['rank']=temp_df['rank'].astype(int)
temp_df['rank']=temp_df['rank']-1

temp_df['co_cited_year']=temp_df['pfcy']+temp_df['rank']
temp_df['frequency']=0
temp_df=temp_df[['cited_1','cited_2','co_cited_year','frequency','first_co_cited_year']]

print('printing temp df')
print(temp_df)


# print(df[(df['cited_1']==4532) & (df['cited_2']==10882054)][['cited_1','cited_2','co_cited_year','frequency','first_co_cited_year']])
# tt=tt[['cited_1','cited_2','first_co_cited_year','','']]

#Merge df with y_df so that it gets first_co_cited_year column
print('length of original df',len(df))
df=pd.merge(df,y_df[['cited_1','cited_2','first_co_cited_year']],on=['cited_1','cited_2'],how='inner')
print(df.head())
print('length of original df',len(df))

#Faulty co-cited data should be eliminated here as well
print('lenght before eliminating wrong data',len(df))
df=df[df['co_cited_year']>=df['first_co_cited_year']]
print('lenght after eliminating wrong data',len(df))


print('Total data points',len(df))
final_df=df.append(temp_df).sort_values(by=['cited_1','cited_2','co_cited_year'])
print('Total data points',len(final_df))
# print(final_df[(final_df['cited_1']==4532) & (final_df['cited_2']==10882054)])
final_df=final_df.copy()
final_df.reset_index(inplace=True,drop=True)
# print(final_df[(final_df['cited_1']==4532) & (final_df['cited_2']==10882054)])
final_df['cited_1']=final_df['cited_1'].astype(int)
final_df['co_cited_year']=final_df['co_cited_year'].astype(int)



#Now generating peak_frequency,first_peak_year,min_frequency
temp_df=final_df.groupby(by=['cited_1','cited_2'],as_index=False)['frequency'].max()
print(temp_df.head())
temp_df=pd.merge(final_df,temp_df,on=['cited_1','cited_2','frequency'],how='inner')
temp_df=temp_df.groupby(by=['cited_1','cited_2'],as_index=False)['frequency','co_cited_year'].min()
print(temp_df.head())
temp_df.columns=['cited_1','cited_2','peak_frequency','first_peak_year']
print(temp_df.head())
final_df=pd.merge(final_df,temp_df,on=['cited_1','cited_2'],how='inner')
print('Size',len(final_df))
# final_df=pd.merge(final_df,temp_df,on=['cited_1','cited_2'],how='inner')
# print('Size',len(final_df))
final_df=final_df[final_df['co_cited_year'] <= final_df['first_peak_year']]
# expected size for bin 221381
print('Size after filtering from peak year',len(final_df))

final_df['co_cited_year_ranks']=final_df.groupby(by=['cited_1','cited_2'])['co_cited_year'].rank(method='first')

temp_df=final_df[final_df['co_cited_year_ranks']==1][['cited_1','cited_2','frequency']]
temp_df.columns=['cited_1','cited_2','min_frequency']
temp_df=temp_df.drop_duplicates()
final_df=final_df.drop(columns=['co_cited_year_ranks'])
print('Adding min frequency')
final_df=pd.merge(final_df,temp_df,on=['cited_1','cited_2'],how='inner')
print('Size',len(final_df))
print(final_df.head())

#Add first_possible_year
print('testing results')
print(final_df)
temp_df=final_df.groupby(by=['cited_1','cited_2'],as_index=False)['co_cited_year'].min()
temp_df.columns=['cited_1','cited_2','first_possible_year']
print('group by results')
print(temp_df)
final_df=pd.merge(final_df,temp_df,on=['cited_1','cited_2'],how='inner')

"""
Applying sleeping beauty formula
"""
final_df['l_t']=(((final_df['peak_frequency']-final_df['min_frequency'])/(final_df['first_peak_year']-final_df['first_possible_year']))*(final_df['co_cited_year']-final_df['first_possible_year']))+final_df['min_frequency']

#temporary column to get max of 1 and peak_frequency column
final_df['max_btw_1_and_freq']=1
final_df['max_btw_1_and_freq']=final_df[['frequency','max_btw_1_and_freq']].max(axis=1)

final_df['sb']=(final_df['l_t']-final_df['frequency'])/final_df['max_btw_1_and_freq']

final_df=final_df.drop(columns=['max_btw_1_and_freq'])

final_df.to_csv(output_filename,index=False)

final_df.groupby(by=['cited_1','cited_2'],as_index=False)['sb'].sum().to_csv(final_output_filename,index=False)

#Applying sleeping beauty formula for data with zeroes
# df['l_b']=(((df['peak_frequency']-df['min_frequency'])/(df['first_peak_year']-df['first_possible_year']))*(df['co_cited_year']-df['first_possible_year']))+df['min_frequency']
# df['sb']=(df['l_t']-df['frequency'])/df['frequency']
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import pandas as pd
import numpy as np
import argparse
import time
import sys

"""
Check to see if time lag calculations are correct and clean them up

"""



time_lag_file=sys.argv[1]
output_filename=sys.argv[2]



time_df=pd.read_csv(time_lag_file)

time_df=time_df.rename(columns={'first_cited_year':'orig_first_co_cited_year'})
time_df['first_co_cited_year']=time_df[['cited_1_year','cited_2_year','orig_first_co_cited_year']].max(axis=1)

time_df=time_df.dropna()

time_df=time_df[(time_df['first_co_cited_year']>1100) & (time_df['first_co_cited_year']<2100)]

time_df['cited_1']=time_df['cited_1'].astype(int)
time_df['cited_2']=time_df['cited_2'].astype(int)
time_df['orig_first_co_cited_year']=time_df['orig_first_co_cited_year'].astype(int)
time_df['cited_1_year']=time_df['cited_1_year'].astype(int)
time_df['citedcited_2_year_1']=time_df['cited_2_year'].astype(int)
time_df['first_co_cited_year']=time_df['first_co_cited_year'].astype(int)

time_df=time_df.drop_duplicates()

temp_df=time_df[['cited_1','cited_2','orig_first_co_cited_year','cited_1_year','cited_2_year','first_co_cited_year']]

temp_df.to_csv(output_filename,index=False)

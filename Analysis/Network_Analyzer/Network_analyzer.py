#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jul 12 13:16:52 2019

@author: siyu

Aim: This script takes edge list table and author list table as input in the following format:  
    <edge list table>:
      Columns:
        source: Contains the nodes.
        stype: Optional in this calculation, but useful for visualization.
        target: Contains the target nodes.
        ttype: Optional in this calculation, but useful for visualization.
    <author list table>:
      Columns:
        pub: scp number.
        auid: author id in Scopus.

Usage: python Network_analyzer.py -edge_list <table name> -auth_list <table name>
            where <edge_list> is table name contains all nodes.
                  <auth_list> is table name contains author list.
"""

import pandas as pd
import numpy as np
import sys
import psycopg2
from sqlalchemy import create_engine

in_arr = sys.argv

if '-edge_list' not in in_arr:
   print("No target edge list table specified.")
   print('USAGE: python Network_analyzer.py -edge_list <table name> -auth_list <table name>')
   raise NameError('ERROR: NO INPUT EDGE LIST TABLE NAME!')
else:
   edge_table_name = in_arr[in_arr.index('-edge_list') + 1]

if '-auth_list' not in in_arr:
   print("No input_dir is specified")
   print('USAGE: python Network_analyzer.py -edge_list <table name> -auth_list <table name>')
   raise NameError('ERROR: NO INPUT AUTHOR LIST TABLE NAME!')
else:
   auth_table_name = in_arr[in_arr.index('-auth_list') + 1]



def article_score(network):
    edges=network.groupby('target',as_index=False)['source'].count()

    edges_combine=pd.merge(network,edges,on='target',how='inner')

    first_degree_merge=pd.merge(edges_combine, edges, left_on='source_x', right_on='target',how='outer')\
    .rename(columns={'source_x':'source','target_x':'target','source_y':'n_target','target_y':'target_y','source':'n_source'})

    first_degree_merge=first_degree_merge.fillna({'n_source':0})

    calculation=first_degree_merge.groupby('target',as_index=False).agg({'n_target':['sum','count'],'n_source':'sum'})
                                      
    calculation['article_score']=calculation.apply(lambda row: row[1]/row[2]+row[3],axis=1)

    article_score=calculation[['target','article_score']].rename(columns={'target':'scp'}).sort_values(by=['article_score'], ascending=False)

    article_score.columns=article_score.columns.droplevel(1)
    return article_score

def author_score(article_score,auth_list):
    combine=pd.merge(article_score, auth_list, left_on='scp', right_on='pub', how='inner')
    author_score=combine.groupby('auid', as_index=False)['article_score'].sum()\
                        .rename(columns={'article_score':'author_score'}).sort_values(by=['author_score'], ascending=False)
    return author_score

#connect to database
engine = create_engine('postgresql+psycopg2:///ernie',echo=False)
conn=psycopg2.connect("")

#read data for calculation
network=pd.read_sql_query("SELECT source, target FROM {};".format(edge_table_name), conn)
auth_list=pd.read_sql_query("SELECT * FROM {};".format(auth_table_name), conn)

#calculate the article score and author score
article_score=article_score(network)
author_score=author_score(article_score,auth_list)

#write results to database
article_score.to_sql('article_score', con=engine, schema='public',if_exists='replace',index=False)
author_score.to_sql('author_score', con=engine, schema='public',if_exists='replace',index=False)
conn.close()





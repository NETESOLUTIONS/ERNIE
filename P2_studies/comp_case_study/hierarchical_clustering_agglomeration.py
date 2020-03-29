#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov 4 10:09:11 2019

@author: sitaram

Example:
python hierarchical_clustering_cluster.py -f ~/dblp_clustering.csv -c ~/dblp_clustering_results.csv 

workflow:
-> To calculate intra cluster edge count between clusters

"""

import pandas as pd
import numpy as np
import argparse
import time
import math

start_time=time.time()


def cluster_relations(cluster_no,dataset,cluster_size):
    # edge_relation_data=[]
    edge_relation_citation_data=[]
    counter=0

    for index,c_no in cluster_no.iteritems():

        if counter%10==0:
            print('Finished clustering',counter)
        counter+=1
        relation_clusters=dataset[dataset['cluster_no1']==c_no][['cluster_no2']]
        relation_clusters=relation_clusters['cluster_no2'].append(dataset[dataset['cluster_no2']==c_no]['cluster_no1'])
        #Obtain edge with highest normalized_co_citation_frequency value
        # max_citation_frequency=dataset[(dataset['cluster_no1']==c_no) | (dataset['cluster_no2']==c_no)]
        # max_citation_frequency=max_citation_frequency.loc[max_citation_frequency['normalized_co_citation_frequency'].idxmax()]
        # print('Cluster',max_citation_frequency.loc['cluster_no1'],'has highest normalized co-citation value of',max_citation_frequency.loc['normalized_co_citation_frequency']
        # ,'with cluster',max_citation_frequency.loc['cluster_no2'])

        # edge_relation_citation_data.append([max_citation_frequency.loc['cluster_no1'],max_citation_frequency.loc['cluster_no2'],max_citation_frequency.loc['normalized_co_citation_frequency']])
        # max_cluster=relation_clusters.value_counts().index[0]
        # max_edge_weight=relation_clusters.value_counts().iloc[0]


        #Calculate all edges
        for c_no2 in relation_clusters.value_counts().index.tolist():
            matrix_data=dataset[(dataset['cluster_no1']==c_no) | (dataset['cluster_no2']==c_no)]
            matrix_data=matrix_data[(matrix_data['cluster_no1']==c_no2) | (matrix_data['cluster_no2']==c_no2)]
            max_citation_frequency=matrix_data['normalized_co_citation_frequency'].max()
            median_citation_frequency=matrix_data['normalized_co_citation_frequency'].median()
            mean_citation_frequency=matrix_data['normalized_co_citation_frequency'].mean()
            q1_citation_frequency=matrix_data['normalized_co_citation_frequency'].quantile(0.25)
            q3_citation_frequency=matrix_data['normalized_co_citation_frequency'].quantile(0.75)
            edge_length=len(matrix_data)
            edge_relation_citation_data.append([c_no,c_no2,edge_length,max_citation_frequency,median_citation_frequency,mean_citation_frequency,q1_citation_frequency,q3_citation_frequency])



        # edge_relation_data.append([c_no,max_cluster,max_edge_weight])
        # print('Cluster',c_no,'has highest edge weight with cluster',max_cluster)

    #Convert edge_relation_data to dataframe and write to csv file
    # inter_cluster_edge_df=pd.DataFrame(edge_relation_data,columns=['cluster_no1','cluster_no2','edge_weight'])
    # inter_cluster_edge_df.sort_values(by=['cluster_no1','cluster_no2'],inplace=True)
    # inter_cluster_edge_df.reset_index(inplace=True,drop=True)
    # inter_cluster_edge_df.to_csv(args.output_file,index=False)

    inter_cluster_cocitation_edge_df=pd.DataFrame(edge_relation_citation_data,columns=['cluster_no1','cluster_no2','edge_length','max_edge_value','median_edge_value','mean_edge_value',
    'q1_edge_value','q3_edge_value'])
    inter_cluster_cocitation_edge_df.sort_values(by=['cluster_no1','cluster_no2'],inplace=True)
    inter_cluster_cocitation_edge_df.reset_index(inplace=True,drop=True)
    inter_cluster_cocitation_edge_df['cluster_no1']=inter_cluster_cocitation_edge_df['cluster_no1'].astype('int64')
    inter_cluster_cocitation_edge_df['cluster_no2']=inter_cluster_cocitation_edge_df['cluster_no2'].astype('int64')

    #We need to add cluster sizes for each of the cluster to start agglomeration
    cluster_size=pd.DataFrame({'cluster_no':cluster_size.index,'cluster_size':cluster_size.values})
    inter_cluster_cocitation_edge_df=pd.merge(inter_cluster_cocitation_edge_df,cluster_size,left_on=['cluster_no1'],right_on=['cluster_no'],how='inner')
    inter_cluster_cocitation_edge_df=pd.merge(inter_cluster_cocitation_edge_df,cluster_size,left_on=['cluster_no2'],right_on=['cluster_no'],how='inner')
    inter_cluster_cocitation_edge_df=inter_cluster_cocitation_edge_df.drop(columns=['cluster_no_x','cluster_no_y'],axis=1)
    inter_cluster_cocitation_edge_df.rename(columns={'cluster_size_x':'cluster_size1','cluster_size_y':'cluster_size2'},inplace=True)
    inter_cluster_cocitation_edge_df.to_csv(args.output_file,index=False)


def cluster_agglomeration(dataset):
    
    cluster_no=0
    # tracker={}

    #Iterate through dataset
    for index,row in dataset.iterrows():

        pair1=row['cited_1']
        pair2=row['cited_2']

        pair1_boolean=math.isnan(clustering_df[clustering_df['cluster_no']==row['cited_1']]['new_cluster_no'].iloc[0])
        pair2_boolean=math.isnan(clustering_df[clustering_df['cluster_no']==row['cited_2']]['new_cluster_no'].iloc[0])

        if not pair1_boolean and not pair2_boolean:
            #If both pairs have clusters assigned then do nothing
            pass
        elif pair1_boolean and not pair2_boolean:
            cluster=clustering_df[clustering_df['cluster_no']==row['cited_2']]['new_cluster_no'].iloc[0]
            clustering_df.loc[clustering_df['cluster_no'].isin([pair1]),'new_cluster_no']=cluster
        elif not pair1_boolean and pair2_boolean:
            cluster=clustering_df[clustering_df['cluster_no']==row['cited_1']]['new_cluster_no'].iloc[0]
            clustering_df.loc[clustering_df['cluster_no'].isin([pair2]),'new_cluster_no']=cluster
        else:
            cluster_no+=1
            clustering_df.loc[clustering_df['cluster_no'].isin([pair2]),'new_cluster_no']=cluster_no
            clustering_df.loc[clustering_df['cluster_no'].isin([pair1]),'new_cluster_no']=cluster_no


def cluster_agglomeration2(dataset):
    
    cluster_no=0
    # tracker={}

    #Iterate through dataset
    # for index,row in dataset.iterrows():
    while len(dataset) > 0:
        pair1=dataset.iloc[0][0]
        pair2=dataset.iloc[0][1]

        # print('current pairs are',pair1,'and',pair2)

        #Assign cluster number
        cluster_no+=1
        clustering_df.loc[clustering_df.iloc[:,-2].isin([pair2]),'new_cluster_no']=cluster_no
        clustering_df.loc[clustering_df.iloc[:,-2].isin([pair1]),'new_cluster_no']=cluster_no

        #Filter dataset and remove occurances of pair1 and pair2
        dataset=dataset[(dataset['cited_1']!=pair1) & (dataset['cited_2']!=pair1)]
        dataset=dataset[(dataset['cited_1']!=pair2) & (dataset['cited_2']!=pair2)]

        #Might not be required to sort since order wouldn't be changed
        # dataset.sort_values(by=[''])
        dataset.reset_index(inplace=True,drop=True)


if __name__ == "__main__":
   
    parser = argparse.ArgumentParser(description='''
     This script is used to agglomerate clusters based on normalized co-citation values
    ''', formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('-f','--filename',help='Input file name with inter-cluster edge list and max edge values',type=str,required=True)
    parser.add_argument('-c','--clustering_results_file',help='File which has clustering results',type=str,required=True)
    parser.add_argument('-o','--output_file',help='File with new cluster numbers based on agglomeration',type=str,required=True)
    args = parser.parse_args()

    #Read input file
    df=pd.read_csv(args.filename,usecols=['cited_1','cited_2','max_edge_value'])

    #Filtering out dups
    print('Length before eliminating dups',len(df))
    dups=pd.DataFrame(np.sort(df[['cited_1','cited_2']],axis=1))
    df=df[~dups.duplicated()]
    print('Length after eliminating dups',len(df))

    #sort dataset by max_edge_value and reset index
    df.sort_values(inplace=True,by=['max_edge_value','cited_1','cited_2'],ascending=False)
    df.reset_index(inplace=True,drop=True)

    #Read clustering results file
    clustering_df=pd.read_csv(args.clustering_results_file)
    clustering_df['new_cluster_no']=np.nan

    cluster_agglomeration2(df)

    print('Length after dropping null values',len(clustering_df.dropna()))

    #Have to rename column
    shape=clustering_df.shape[1]-1
    column_name='cluster_no'+str(shape)
    clustering_df.rename(columns={'new_cluster_no':column_name},inplace=True)


    clustering_df.to_csv(args.output_file,index=False)

    # cluster_relations(no_clusters,c_df,cluster_sizes)

    print('Total time',time.time()-start_time)

    # dups=pd.DataFrame(np.sort(comp,axis=1))
# comp=comp[~dups.duplicated()]
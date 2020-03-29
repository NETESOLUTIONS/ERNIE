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

start_time=time.time()


def cluster_relations(cluster_no,dataset,cluster_size):
    # edge_relation_data=[]
    edge_relation_citation_data=[]
    counter=0

    for index,c_no in cluster_no.iteritems():

        if counter%100==0:
            print('Finished looping through',counter,'clusters')
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
            # cited_1=matrix_data[matrix_data['normalized_co_citation_frequency']==matrix_data['normalized_co_citation_frequency'].max()]['cited_1'][0]
            # cited_2=matrix_data[matrix_data['normalized_co_citation_frequency']==matrix_data['normalized_co_citation_frequency'].max()]['cited_2'][0]
            # median_citation_frequency=matrix_data['normalized_co_citation_frequency'].median()
            # mean_citation_frequency=matrix_data['normalized_co_citation_frequency'].mean()
            # q1_citation_frequency=matrix_data['normalized_co_citation_frequency'].quantile(0.25)
            # q3_citation_frequency=matrix_data['normalized_co_citation_frequency'].quantile(0.75)
            edge_length=len(matrix_data)
            edge_relation_citation_data.append([c_no,c_no2,edge_length,max_citation_frequency])



        # edge_relation_data.append([c_no,max_cluster,max_edge_weight])
        # print('Cluster',c_no,'has highest edge weight with cluster',max_cluster)

    #Convert edge_relation_data to dataframe and write to csv file
    # inter_cluster_edge_df=pd.DataFrame(edge_relation_data,columns=['cluster_no1','cluster_no2','edge_weight'])
    # inter_cluster_edge_df.sort_values(by=['cluster_no1','cluster_no2'],inplace=True)
    # inter_cluster_edge_df.reset_index(inplace=True,drop=True)
    # inter_cluster_edge_df.to_csv(args.output_file,index=False)

    # inter_cluster_cocitation_edge_df=pd.DataFrame(edge_relation_citation_data,columns=['cited_1','cited_2','cluster_no1','cluster_no2','edge_count','max_edge_value'])
    inter_cluster_cocitation_edge_df=pd.DataFrame(edge_relation_citation_data,columns=['cluster_no1','cluster_no2','edge_count','max_edge_value'])
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
    inter_cluster_cocitation_edge_df.rename(columns={'cluster_no1':'cited_1','cluster_no2':'cited_2'},inplace=True)
    inter_cluster_cocitation_edge_df.to_csv(args.output_file,index=False)


if __name__ == "__main__":
   
    parser = argparse.ArgumentParser(description='''
     This script is used to generate clusters based on normalized co-citation values
    ''', formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('-f','--filename',help='Input file name with co-citation pairs and normalized frequency values',type=str,required=True)
    parser.add_argument('-c','--clustering_results_file',help='File which has clustering results',type=str,required=True)
    parser.add_argument('-o','--output_file',help='File with edge weight relations between clusters',type=str,required=True)
    args = parser.parse_args()

    #Read input file
    df=pd.read_csv(args.filename,usecols=['cited_1','cited_2','normalized_co_citation_frequency'])

    #Read clustering results file
    clustering_df=pd.read_csv(args.clustering_results_file)

    
    clustering_df=clustering_df.iloc[:,::clustering_df.shape[1]-1]

    print(clustering_df.head())

    clustering_df.columns=['source_id','cluster_no']
    clustering_df=clustering_df.dropna()

    #Eliminating all clusters with only 2 nodes
    # cluster_sizes=clustering_df.iloc[:,-1].value_counts()
    cluster_sizes=clustering_df['cluster_no'].value_counts()
    cluster_sizes=cluster_sizes[cluster_sizes > 2]
    clustering_df=clustering_df[clustering_df['cluster_no'].isin(cluster_sizes.index.tolist())]


    #Merge to obtain cluster numbers
    c_df=pd.merge(df,clustering_df,left_on=['cited_1'],right_on=['source_id'],how='inner')

    c_df=pd.merge(c_df,clustering_df,left_on=['cited_2'],right_on=['source_id'],how='inner')

    c_df=c_df.drop(columns=['source_id_x','source_id_y'],axis=1)

    c_df.rename(columns={'cluster_no_x':'cluster_no1','cluster_no_y':'cluster_no2'},inplace=True)

    #Filter all rows which intra-cluster relation
    c_df=c_df[c_df['cluster_no1'] != c_df['cluster_no2']]


    no_clusters=clustering_df['cluster_no'].nunique()
    no_clusters=c_df[['cluster_no1']]
    no_clusters=no_clusters['cluster_no1'].append(c_df['cluster_no2'])
    no_clusters=no_clusters.drop_duplicates().reset_index(drop=True)
    print('Total numner of clusters',len(no_clusters))

    cluster_relations(no_clusters,c_df,cluster_sizes)

    print('Total time',time.time()-start_time)
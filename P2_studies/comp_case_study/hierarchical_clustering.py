#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 28 10:09:11 2019

@author: sitaram

Example:
python hierarchical_clustering.py -f ~/dblp_clustering.csv -o ~/dblp_clustering_results.csv -t 0.999


workflow:
-> Filter based on threshold
-> Clusters should be between 1 <= cluster_size <= 500
-> Clusters above that size should be combined and re-clustered using increasing threshold
-> Continue above process until no nodes are left
"""

import pandas as pd
import numpy as np
import argparse
import time

start_time=time.time()
cluster_no=0

def cluster(dataset,threshold):
    filtered_list=[]
    count=0
    global cluster_no
    # for row in range(0,3):
    while(len(dataset) > 0):
        """
        cluster_no      ->      keeps track of the cluster_no
        full_list       ->      For a given cited_1,cited_2 stores all pubs
        dataset         ->      Input dataset 
        count           ->      used to track how many pubs per pair are clustered. Only for verification
        """
        # cluster_no+=1
        full_list=[]
        temp_list=[]
        # print('Dataset size',len(dataset))
        # print('Current row is')
        # print(dataset.iloc[0])
        node_1,node_2=dataset['cited_1'].iloc[0],dataset['cited_2'].iloc[0]
        full_list.extend([node_1,node_2])

        temp_list.extend(dataset[(dataset['cited_1'].isin([node_1,node_2]))]['cited_2'].tolist())
        temp_list.extend(dataset[(dataset['cited_2'].isin([node_1,node_2]))]['cited_1'].tolist())
        # print(temp_df.head())
        # temp_list=list(set(temp_list))


        #Removing nodes which are already used
        for node in [node_1,node_2]:
            if node in temp_list:
                temp_list.remove(node)

        full_list.extend(temp_list)

        #Filter dataframe
        # print('Length before filtering',len(dataset))
        dataset=dataset[~dataset['cited_1'].isin([node_1,node_2])]
        dataset=dataset[~dataset['cited_2'].isin([node_1,node_2])]
        # print('Length after filtering',len(dataset))

        while(len(temp_list) > 0):
            local_list=[]
            local_list.extend(dataset[dataset['cited_1'].isin(temp_list)]['cited_2'].tolist())
            local_list.extend(dataset[dataset['cited_2'].isin(temp_list)]['cited_1'].tolist())
            local_list=list(set(local_list))

            #Removing nodes which are already used
            for node in temp_list:
                if node in local_list:
                    local_list.remove(node)

            #Filter dataset
            # print('Length before filtering',len(dataset))
            dataset=dataset[~dataset['cited_1'].isin(temp_list)]
            dataset=dataset[~dataset['cited_2'].isin(temp_list)]
            # print('Length after filtering',len(dataset))

            full_list.extend(local_list)
            temp_list=local_list

        
        count+=len(full_list)

        if 1 <= len(full_list) <= 100:
            # filtered_list.extend(full_list)
        #print('length of full list',len(full_list))

        #Updating dataframe with cluster_no
            # print('threshold value',threshold,'cluster size',len(full_list))
            # if cluster_no==0:
            #     print('threshold value',threshold,'cluster size',len(full_list))
            cluster_no+=1

            unique_df.loc[unique_df['source_id'].isin(full_list),'cluster_no']=cluster_no
        else:
            filtered_list.extend(full_list)
            print('Filtered nodes length',len(filtered_list))
        # print('Total pubs added',count)
        # print('Total number of actual pubs',len(unique_df))

        #Resetting index
        dataset.reset_index(inplace=True,drop=True)

    return filtered_list




if __name__ == "__main__":
   
    parser = argparse.ArgumentParser(description='''
     This script is used to generate clusters based on normalized co-citation values
    ''', formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('-f','--filename',help='Input file name with co-citation pairs and normalized frequency values',type=str,required=True)
    parser.add_argument('-o','--output_file',help='Output file name',type=str,required=True)
    parser.add_argument('-t','--threshold',help='Threshold value to filter based on normalized co-citation',type=float)
    args = parser.parse_args()

    
    print('Reading input file')
    df=pd.read_csv(args.filename,usecols=['cited_1','cited_2','normalized_co_citation_frequency'])
    threshold_df=pd.read_csv(args.filename,usecols=['normalized_co_citation_frequency'])
    # filtered_nodes=[]

    # norm_df=df['normalized_co_citation_frequency'].quantile(0.6)

    """
    If threshold argument is provided file will be filtered, else entire data frame will be 
    used for clustering
    """
    if args.threshold:
        df=df[df['normalized_co_citation_frequency']>df['normalized_co_citation_frequency'].quantile(args.threshold)]

    #Creaitng pandas Series with all pubs
    unique_df=df[['cited_1']]
    unique_df=unique_df['cited_1'].append(df['cited_2'].reset_index(drop=True))
    
    #dropping duplicates
    unique_df.drop_duplicates(inplace=True)
    unique_df.reset_index(inplace=True,drop=True)

    unique_df=pd.DataFrame({'source_id':unique_df.values})
    unique_df['cluster_no']=np.nan

    # print(unique_df.head())

    print('Sorting input file by normalized co-citation frequency and reset index')
    df.sort_values(by=['normalized_co_citation_frequency','cited_1','cited_2'],inplace=True,ascending=False)
    df.reset_index(drop=True,inplace=True)
    f_df=df #Another name which will be used for now

    print('Total number of edges before clustering',len(df))
    print('Calling cluster generation function')


    filtered_nodes=cluster(df,args.threshold)

    #Filtered data set
    # args.threshold+=0.1
    # f_df=df[(df['cited_1'].isin(filtered_nodes)) | (df['cited_2'].isin(filtered_nodes))]
    # f_df=f_df[f_df['normalized_co_citation_frequency']>f_df['normalized_co_citation_frequency'].quantile(args.threshold)]

    #Continue looping until filtered nodes is null
    # while filtered_nodes:
    values_range=[0.6,0.7,0.8,0.9,0.91,0.92,0.93,0.94,0.95,0.96,0.97,0.98,0.99,0.999]
    values_range1=[0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,0.91,0.92,0.93,0.94,0.95,0.96,0.97,0.98,0.99,0.999]
    for i in values_range:
    # while filtered_nodes:
        args.threshold=i
        # args.threshold+=0.1
        print('Running on threshold',args.threshold)
        print('Edge length before filtering',len(f_df))
        f_df=f_df[(f_df['cited_1'].isin(filtered_nodes)) | (f_df['cited_2'].isin(filtered_nodes))]
        print('Edges not clustered from before round',len(f_df))

        #Below 3 lines are part of original method exp1 ,exp2
        norm_df=threshold_df['normalized_co_citation_frequency'].quantile(args.threshold)
        print('Filter value being used',norm_df)
        f_df=f_df[f_df['normalized_co_citation_frequency'] > norm_df]


        # Below is for my method exp3
        # f_df=f_df[f_df['normalized_co_citation_frequency']>f_df['normalized_co_citation_frequency'].quantile(args.threshold)]
        print('Edge length after filtering',len(f_df))
        filtered_nodes=cluster(f_df,args.threshold) 
    print('Clustering done')
    print('Total number of edges after clustering',len(df))
    
    #Writing results 
    # unique_df['cluster_no']=pd.to_numeric(unique_df['cluster_no'],downcast='integer')
    unique_df=unique_df.dropna()
    unique_df['cluster_no']=unique_df['cluster_no'].astype('int64')
    unique_df.to_csv(args.output_file,index=False)
    print('Total time',time.time()-start_time)
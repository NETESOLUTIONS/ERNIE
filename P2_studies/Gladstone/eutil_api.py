#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 20 15:03:06 2018

@author: siyu
"""
from Bio import Entrez
import pandas as pd
#import sys

#esummary_search_base="https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?"
pmid=[]
with open('pmid_final_list.txt','r') as f:
    for line in f:
        pmid.append(line.strip())
 
#Get pmids by searching terms   
def esearch(terms,start):
    Entrez.email = 'your.email@example.com'
    handle = Entrez.esearch(db='pubmed',
                            term=terms,
                           retmax=500,
                           retstart=start,
                           idtype='pmid',)
    records = Entrez.read(handle)
    return records

#Get detailed publication records
def efetch(id_list,start):
    ids = ','.join(id_list)
    Entrez.email = 'your.email@example.com'
    handle = Entrez.efetch(db='pubmed',
                           retmode='xml',
                           retmax=500,
                           retstart=start,
                           id=ids)
    records = Entrez.read(handle)
    return records

#Change input terms for different search
terms='stem cell English[la]'
search_ids=esearch(terms,0)
count=search_ids['Count']
repeat=int(count)//500
pmid=list(search_ids['IdList'])
if repeat > 0:
    for i in range(500,int(count),500):
        search_ids=esearch('ipsc',i)
        pmid.extend(list(search_ids['IdList']))

#Get full records from efetch
articles=[]
for i in range(0,len(pmid),500):
    records=efetch(pmid,i)
    articles.extend(list(records['PubmedArticle']))

#records=efetch(pmid)
#articles=records['PubmedArticle']

#pub_summary=pd.DataFrame()
author_summary=pd.DataFrame()
pmid_summary=[]
row2=[]
for article in articles:
    if 'AuthorList' in article['MedlineCitation']['Article'].keys():
        for author in article['MedlineCitation']['Article']['AuthorList']:
            #row2={}
            #row2['PMID']=article['MedlineCitation']['PMID']
            '''
            if 'ForeName' in author.keys():
                row2['first_name']=author['ForeName']
            else:
                row2['first_name']=""
                
            if 'LastName' in author.keys():   
                row2['last_name']=author['LastName']
            else:
                row2['last_name']=""
            '''    
            if author['AffiliationInfo'] != []:
                for i in range(0, len(author['AffiliationInfo'])):
                    #row2['Affiliation']=author['AffiliationInfo'][i]['Affiliation']
                    gladstone=author['AffiliationInfo'][i]['Affiliation'].lower()
                    row2.append(gladstone)
                    if 'gladstone' in gladstone:
                        pmid_summary.append(article['MedlineCitation']['PMID'])             
            #else:
                #row2['Affiliation']=""
            #author_summary=author_summary.append(row2,ignore_index=True)

gladstone=author_summary[author_summary['Affiliation'].str.contains('gladstone', na=False, case=False)]
pmid_gladstone=[str(i) for i in gladstone['PMID']]
summary=[str(i) for i in pmid_summary]
count1=list(set(pmid_gladstone))
count2=list(set(summary))
#pub_summary.to_csv('pub_info.csv',index=False)
#author_summary.to_csv('author_info.csv',index=False)
with open('pmid_gladstone.txt','w') as f:
    for item in count:
        f.write("%s\n" % item)

Entrez.email = 'your.email@example.com'
test0= Entrez.efetch(db='pubmed',
                    retmode='xml',
                    id='23340407')
test = Entrez.read(test0)
'''

def esummary(id_list):
    ids = ','.join(id_list)
    #Entrez.email = 'your.email@example.com'
    handle = Entrez.esummary(db='pubmed',
                           retmode='xml',
                           id=ids)
    records = Entrez.read(handle)    
    return records
'''


'''
    row1={}
    row1['PMID']=article['MedlineCitation']['PMID']
    
    keys=article['MedlineCitation']['Article']['Journal']['JournalIssue']['PubDate'].keys()
    row1['PubDate']=""
    for key in keys:
        row1['PubDate']=row1['PubDate']+' '+article['MedlineCitation']['Article']['Journal']['JournalIssue']['PubDate'][key]
    row1['PubDate'].strip()   
    
    row1['Title']=article['MedlineCitation']['Article']['ArticleTitle']
    row1['Journal']=article['MedlineCitation']['Article']['Journal']['Title']
    pub_summary=pub_summary.append(row1,ignore_index=True)
'''    




#!/usr/bin/env bash

'''Author: Sitaram Devarakonda

This script given an input of grants Ex: R01MH092862 searches in pubmed for all pubmed ids which cite given grant

Ex: python eutils_grants.py input_filename.csv output_filename.csv email@nete.com'''

import pandas as pd
import os,sys
from Bio import Entrez #Using biopython module to obtain pubmed id
import time
import csv

#Input filename with all grants
input_filename=sys.argv[1]

#Output filename 
output_filename=sys.argv[2]

#User email address should be provided for contact incase we overwhelm pubmed with requests
email_address=sys.argv[3]

#Start time
start_time=time.time()


#Assigning email address
Entrez.email=email_address

input_data=pd.read_csv(input_filename)
final_data=[]

#opening output file to write data
outputFile=open(output_filename,'w',newline='')
outputWriter=csv.writer(outputFile)
outputWriter.writerow(['grant_number','pubmed_id'])

#Iterate through input file
for index,row in input_data.iterrows():
    overload_time=time.time()
    print('Searching grant {}'.format(row['grant_number']))
    #search using ROIs and the field name GRNT
    grant=Entrez.esearch(db="pubmed",term=row['grant_number']+'[GRNT]')
    
    #parse the returned data which returns a dictionary
    pmid=Entrez.read(grant)

    #Iterate through IdList which contains all pubmed ids and write to csv
    for id in pmid['IdList']:
        outputWriter.writerow([row['grant_number'],id])
    #To maintain a time interval of 4 seconds for each request
    if time.time()-overload_time < 4:
        # print('sleeping')
        time.sleep(4-(time.time()-overload_time))


outputFile.close()
print('Done, Total time is',time.time()-start_time)

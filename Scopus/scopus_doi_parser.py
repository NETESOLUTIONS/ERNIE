#!/usr/bin/python
# -*- coding: utf-8 -*-

#Parse test/csv files for DOI's
#This works on scopus data

import time,os
import psycopg2
import sys
import re
import argparse
import PyPDF2
from habanero import cn
import csv,json
import requests

#start time
start_time=time.time()

#Input file
file_name=sys.argv[1]
base_name=os.path.dirname(file_name)

#regex for doi's
# doiRegex=re.compile(r'10\.\w*/\w*')
doiRegex=re.compile(r'(10[.][0-9]{4,}(?:[.][0-9]+)*/(?:(?!["&\'<>])\S)+)')
#List of doi
doi_list=[]
final_result=[]
wos_doi=[]
crossref_doi=[]

#Parse pdf files and look for doi


#extrat doi's from pdf files
def pdf_doi(file_name):
    global doiRegex,doi_list
    fileObject = open(file_name,'rb')
    pdfObject=PyPDF2.PdfFileReader(fileObject)
    for i in range(pdfObject.numPages):
        contents=pdfObject.getPage(i).extractText()
        match=doiRegex.findall(contents)
        if match:
            doi_list.extend([x.strip('.') for x in match])
    fileObject.close()

#extract doi's from txt files
def txt_doi(file_name):
    global doiRegex,doi_list
    print('Parsing text file')
    with open(file_name) as f:
        line=f.readline()
        while line:
            match=doiRegex.findall(line)
            if match:
                doi_list.extend([x.strip('.') for x in match])
            line=f.readline()

#extract doi's from csv files
def csv_doi(file_name):
    global doiRegex,doi_list
    fileObject=open(file_name,'r')
    csvObject=csv.reader(fileObject)
    for row in csvObject:
        line=' '.join(row)
        match=doiRegex.findall(line)
        if match:
            doi_list.extend([x.strip('.') for x in match])
    fileObject.close()


#determine file format
file_type=file_name.split('.')
if file_type[-1] == 'pdf':
    pdf_doi(file_name)
    #Call pdf method
elif file_type[-1] == 'csv':
    csv_doi(file_name)
    #Call csv method
else:
    txt_doi(file_name)
    #Call txt method  


#Final list of doi's
print('Doi\'s collected')
for i in set(doi_list):
    print(i)


postgres_conn=psycopg2.connect("")
#obtain records from crossref
def crossref_publications(doi_missed):
    global final_result
    for i in set(doi_missed):
        try:
            crossrefObject=cn.content_negotiation(ids = i,format='citeproc-json')
        # print('Calling ',i)
            data=json.loads(crossrefObject)
            if 'published-print' in data.keys():
                final_result.append(['crossref',data['title'],data['published-print']['date-parts'][0][0],data['DOI']])
            else:
                final_result.append(['crossref',data['title'],data['published-online']['date-parts'][0][0],data['DOI']])
        except requests.exceptions.HTTPError as error:
            print('DOI not found ',error)
            crossref_doi.append(i)

        

def get_publications(conn):
    global final_result,wos_doi
    print('Getting doi details')
    curs=conn.cursor()
    curs.execute('''SELECT spi.scp, st.title, sspd.publication_year, spi.document_id
    FROM public.scopus_publication_identifiers spi
       INNER JOIN public.scopus_titles st ON st.scp = spi.scp
       INNER JOIN public.scopus_source_publication_details sspd ON sspd.scp = spi.scp
    AND spi.document_id IN %s and spi.document_id_type=%s AND st.language='English' ''',(tuple(set(doi_list)),'doi'))

    results=curs.fetchall()

    #writing files to csv file
    for row in results:
        final_result.append(list(row))
        wos_doi.append(row[3])
        # print(list(row))

    #obtaining missed doi's to search in crossref    
    doi_missed=[x for x in doi_list if x not in set(wos_doi)]
    if len(doi_missed) > 0:
        crossref_publications(doi_missed)
    print('No of doi\'s not found in scopus ',len(crossref_doi))
    for i in crossref_doi:
        print(i)
    curs.close()

get_publications(postgres_conn)

#write results to file

fileWriter=open(os.path.join(base_name,'doi_results.csv'),'w')
csvWriter=csv.writer(fileWriter)
csvWriter.writerow(['source_id','document_title','publication_year','doi'])
csvWriter.writerows(final_result)
fileWriter.close()

print('Results written to file ',os.path.join(base_name,'doi_results.csv'))

postgres_conn.close()

print('Total duration ',time.time()-start_time)
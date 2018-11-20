#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Nov  9 13:36:48 2018

@author: sitaram
"""

from __future__ import print_function
import sys,os
import psycopg2

filename=sys.argv[2]

print('filename ',os.path.basename(filename))

wos_id=[]

with open(filename) as f:
    contents=f.readlines()
    contents=[x.strip() for x in contents]
    wos_id=[x.split(',')[0]+':'+x.split(',')[1] for x in contents]
    wos_id=[(x,) for x in wos_id]
    
#print(wos_id)
print('Number of wos_id '+ str(len(wos_id)))


# Establishing connection to the database for running upsert commands once the parsing is done
try:
    conn = psycopg2.connect("")
    with conn:
        with conn.cursor() as curs:
            
            delete_query="""Delete from wos_publications where source_id = %s"""
            curs.executemany(delete_query,wos_id)            
            row_count=curs.rowcount
            print('Records deleted from wos_publications',row_count)

            delete_query="""Delete from wos_grants where source_id = %s"""
            curs.executemany(delete_query,wos_id)            
            row_count=curs.rowcount
            print('Records deleted from wos_grants',row_count)
            
            delete_query="""Delete from wos_document_identifiers where source_id = %s"""
            curs.executemany(delete_query,wos_id)            
            row_count=curs.rowcount
            print('Records deleted from wos_document_identifiers',row_count)

            delete_query="""Delete from wos_keywords where source_id = %s"""
            curs.executemany(delete_query,wos_id)            
            row_count=curs.rowcount
            print('Records deleted from wos_keywords',row_count)
                  
            delete_query="""Delete from wos_abstracts where source_id = %s"""
            curs.executemany(delete_query,wos_id)            
            row_count=curs.rowcount
            print('Records deleted from wos_abstracts',row_count)
            
            delete_query="""Delete from wos_addresses where source_id = %s"""
            curs.executemany(delete_query,wos_id)            
            row_count=curs.rowcount
            print('Records deleted from wos_addresses',row_count)
                  
            delete_query="""Delete from wos_titles where source_id = %s"""
            curs.executemany(delete_query,wos_id)            
            row_count=curs.rowcount
            print('Records deleted from wos_titles',row_count)
                  
            delete_query="""Delete from wos_publication_subjects where source_id = %s"""
            curs.executemany(delete_query,wos_id)            
            row_count=curs.rowcount
            print('Records deleted from wos_publication_subjects',row_count)
                  
            delete_query="""Delete from wos_authors where source_id = %s"""
            curs.executemany(delete_query,wos_id)            
            row_count=curs.rowcount
            print('Records deleted from wos_authors',row_count)
                  
            delete_query="""Delete from wos_references where source_id = %s"""
            curs.executemany(delete_query,wos_id)            
            row_count=curs.rowcount
            print('Records deleted from wos_references',row_count)
            print('########################################')      
        conn.commit()
    conn.close()
            
except (Exception, psycopg2.Error) as error:
    print("Error while deleting PostgreSQL table", error)   

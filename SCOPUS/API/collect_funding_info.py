'''
 Author:    VJ Davey
 Date:      01/17/2019
'''
import pandas as pd
import psycopg2
from psycopg2 import sql
import ScopusInterface as si
import argparse

parser = argparse.ArgumentParser(description='''
 Collect funding information where available for the authors used in the NSF study
''', formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument('-d','--postgres_dbname',help='the database to query in the PostgreSQL server',required=True)
parser.add_argument('-k','--api_key',help='the port hosting the PostgreSQL service on the server', required=True)
args = parser.parse_args()

fields="title,identifier,eid,fund-sponsor,fund-acr,fund-no"
final_df=pd.DataFrame(columns=fields.split(','))

conn=psycopg2.connect(dbname=args.postgres_dbname)
cur=conn.cursor()
sql="SELECT DISTINCT author_id FROM cci_s_author_search_results WHERE author_id !='NO AUTHOR ID';"
cur.execute(sql)

for idx,row in enumerate(cur.fetchall()):
    auth_id=row[0]
    results = si.document_search("AU-ID({})".format(auth_id),args.api_key, field=fields)
    if results==None:
        continue
    final_df=final_df.append(results['documents'],ignore_index=True)
    if idx%5==0:
        final_df=final_df.drop_duplicates().reset_index(drop=True)
        final_df.to_csv('documents_funding_info.csv', encoding='utf8')
final_df=final_df.drop_duplicates().reset_index(drop=True)
final_df.to_csv('documents_funding_info.csv', encoding='utf8')

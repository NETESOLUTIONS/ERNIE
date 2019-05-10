'''
 Author:    VJ Davey
 Date:      05/9/2019
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

fields="title,identifier,eid,doi,fund-sponsor,fund-acr,fund-no"
final_df=pd.DataFrame(columns=fields.split(','))
final_df['award_number']=None
final_df['official_center_name']=None

conn=psycopg2.connect(dbname=args.postgres_dbname)
cur=conn.cursor()
sql='''SELECT DISTINCT award_number,official_center_name
        FROM cci_award_names;'''
cur.execute(sql)

for idx,row in enumerate(cur.fetchall()):
    award_number=row[0]
    official_center_name=row[1]
    results = si.document_search("fund-no(*{}*)".format(award_number),args.api_key, field=fields,view="COMPLETE")
    if results==None:
        continue
    append_df=results['documents'] ; append_df['award_number']=award_number ; append_df['official_center_name']=official_center_name
    final_df=final_df.append(append_df,ignore_index=True)
    if idx%5==0:
        final_df=final_df.drop_duplicates().reset_index(drop=True)
        final_df.to_csv('award_search_results.csv', encoding='utf8')
final_df=final_df.drop_duplicates().reset_index(drop=True)
final_df.to_csv('award_search_results.csv', encoding='utf8',index=False)

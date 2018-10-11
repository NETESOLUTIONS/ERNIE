'''
    Author: VJ Davey
'''
import re
import ScopusInterface as si
import psycopg2
import pandas; import os
from time import sleep
import argparse
api_key=os.environ['SCOPUS_API_KEY']
parser = argparse.ArgumentParser(description='''
author_name_search.py
    This script utilizes the ScopusInterface script with a provided CSV file of preprocessed
     author name strings to collect potentially matching Author IDs. Data
     is uploaded directly into the cci_s_author_search_results_stg table and/or additionally
     output as a CSV file on demand.

    Requires trust connection to local DB.
''', formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument('-f','--csv_file',help='The path to the CSV file containing the title/DOI information to search for',type=str,required=True)
parser.add_argument('-k','--api_key',help='The key to use with the SCOPUS APIs',type=str,default=api_key)
parser.add_argument('-d','--database',help='The PostgreSQL database to direct output',type=str,required=True)
parser.add_argument('-o','--output_file',help='The name/location to direct output. Please specify the full path.',type=str,default=None)
args = parser.parse_args()
api_key=args.api_key
author_df=pandas.read_csv(args.csv_file, dtype=str)[['Surname','Given_Name','Phase','Award_Number,First_Year']]
author_df=author_df.fillna('')
conn=psycopg2.connect(database=args.database)
cur=conn.cursor()
cur.execute("TRUNCATE TABLE cci_s_author_search_results_stg")
cur.execute("ALTER SEQUENCE cci_s_author_search_results_stg_seq restart with 1;")
conn.commit()
for row in author_df.itertuples():
    surname_submission=re.sub(r'[\(\)]','',row.Surname)
    given_name_submission=re.sub(r'[\(\)]','',row.Given_Name)
    sleep(.1)
    auth_search_results,query=si.author_search(title_submission,api_key,search_result_limit=10,query_return=True)
    for author_id in doc_search_results['authors']:
        cur.execute('''
            INSERT INTO cci_s_document_search_results_stg(surname,given_name,author_id,award_number,
          phase,first_year,manual_selection,query_string) VALUES
                (\'{}\',\'{}\',\'{}\',\'{}\',\'{}\',\'{}\',\'{}\',\'{}\',\'{}\')
            '''.format(row.Surname,row.Given_Name,author_id,
                    row.Award_Number, row.Phase, row.First_Year, 0,query))
        #TODO: add else condition for NO AUTHOR ID
    conn.commit()
if args.output_file!=None:
    cur.execute("COPY cci_s_author_search_results_stg TO \'{}\' CSV HEADER".format(args.output_file))

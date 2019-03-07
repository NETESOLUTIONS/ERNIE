'''
Import data from ERNIE postgres and generate a Chord Diagram
Author: VJ Davey
'''
import psycopg2
import argparse
import pandas as pd
import numpy as np
import chord
from math import ceil

def fibonacci(n,memo):
    if (n < 2):
        return 1
    if n in memo:
        return memo[n]
    else:
        memo[n] = fibonacci(n-1,memo) + fibonacci(n-2,memo)
        return memo[n]

def fibonacci_color(h,s,l,a=0.9,num_colors=3):
    color_list=[]
    memo={}
    for i in range(num_colors):
        h = ((h+fibonacci(i+1,memo))%200) +100
        s = s#((s+fibonacci(i+1,memo))% 20) + 30
        l = l#((l-fibonacci(i+1,memo))% 20) + 30
        color_list+=["hsla({},{},{},{})".format(h,s,l,a)]
    return color_list



# Collect user input and possibly override defaults based on that input
parser = argparse.ArgumentParser(description='''
 This script interfaces with the PostgreSQL database and then generates a Sankey diagram
''', formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument('-ph','--postgres_host',help='the server hosting the PostgreSQL server',default='localhost',type=str)
parser.add_argument('-pd','--postgres_dbname',help='the database to query in the PostgreSQL server',type=str,required=True)
parser.add_argument('-pp','--postgres_port',help='the port hosting the PostgreSQL service on the server', default='5432',type=int)
parser.add_argument('-U','--postgres_user',help='the PostgreSQL user to log in as',required=True)
parser.add_argument('-W','--postgres_password',help='the password of the PostgreSQL user',required=True)
parser.add_argument('-A','--award_numbers',help='a string containing a comma seperated list of award_numbers (e.g "1038028,1305427")',required=True)
parser.add_argument('-S','--start_year',help='the lower end of the publication year range to consider',default='1930')
parser.add_argument('-E','--end_year',help='the upper end of the publication year range to consider',default='2018')
args = parser.parse_args()
postgres_dsn={'host':args.postgres_host,'dbname':args.postgres_dbname,'port':args.postgres_port,'user':args.postgres_user,'password':args.postgres_password}
postgres_conn=psycopg2.connect(" ".join("{}={}".format(k,postgres_dsn[k]) for k in postgres_dsn))
award_numbers=tuple(args.award_numbers.split(','))
start_year=args.start_year
end_year=args.end_year
print(award_numbers)
# select coauthor pairs to form ideogram edges and interconnected ribbons
coauthor_df=pd.read_sql_query('''
                    WITH
                    award_author_documents AS
                    (
                      SELECT DISTINCT
                       concat(foo.given_name,' ', foo.surname) as name,
                       a.scopus_id,
                       (SELECT b.publication_year FROM cci_s_documents b WHERE a.scopus_id=b.scopus_id) as publication_year
                      FROM cci_s_author_document_mappings a
                      INNER JOIN
                      (SELECT author_id,surname,given_name
                            FROM cci_s_author_search_results
                            WHERE award_number IN %(award_numbers)s
                            AND author_id IN (SELECT author_id FROM chackoge.sl_sr_combined)
                      ) foo
                      ON a.author_id=foo.author_id
                    ),
                    co_author_links AS
                    (
                        SELECT a.name as auth1,b.name as auth2, a.scopus_id
                        FROM award_author_documents a
                        JOIN award_author_documents b
                        ON a.scopus_id=b.scopus_id
                        WHERE
                        a.publication_year BETWEEN %(start_year)s AND %(end_year)s
                        AND a.name > b.name -- NOTE: This is done to avoid double counts
                    )

                    SELECT auth1,auth2,n_links
                    FROM
                    (
                      -- Collect intranetwork links between authors
                     SELECT auth1,auth2,count(scopus_id) as n_links
                     FROM co_author_links
                     GROUP BY auth1,auth2
                    ) foo
                    ORDER BY auth1;
''',params={'award_numbers':award_numbers,'start_year':start_year,'end_year':end_year}, con=postgres_conn)
# Build a sorted list of author_ids
print(coauthor_df)
print(sum(coauthor_df['n_links']))
unique_authors_series=sorted(coauthor_df['auth1'].append(coauthor_df['auth2']).unique())
unique_authors=sorted(coauthor_df['auth1'].append(coauthor_df['auth2']).unique())
unique_authors={unique_authors[i]:i for i in range(len(unique_authors))}
print(unique_authors)
# Create and populate an NxN Matrix for the unique authors in the list: M[i][j] = COUNT(coauthor pairs)
data_matrix=np.zeros((len(unique_authors),len(unique_authors)),dtype=int)
for row in coauthor_df.itertuples():
    #print("{} and {} have {} documents together".format(row.auth1,row.auth2,row.n_links))
    i = unique_authors[row.auth1]
    j = unique_authors[row.auth2]
    data_matrix[i,j]+=row.n_links
    data_matrix[j,i]+=row.n_links #NOTE: sum of matrix will exceed expected value due to double count here
print(data_matrix.shape)
data_df=pd.DataFrame(data_matrix)
for axis in ['columns', 'index']:
    data_df=data_df.rename({i:unique_authors_series[i] for i in range(data_matrix.shape[0])}, axis=axis)
print(data_df)
data_df.to_csv('author_collaboration_matrix.csv')
three_col_df=data_df.stack().reset_index()
three_col_df=three_col_df.rename({'level_0':'Author1','level_1':'Author2',0:'Number Of Collaborations'}, axis='columns')
print(three_col_df)
three_col_df.to_csv('author_collaboration_three_cols.csv',index=False)


labels=list(unique_authors)
seed_color=[180, 65, 35, .85]
colors=fibonacci_color(seed_color[0],seed_color[1],seed_color[2],seed_color[3],num_colors=data_matrix.shape[0])
print('length_colors:{}'.format(len(colors)))
title='Prather Center Chord Diagram'
dimensions=1200
hover_text={
            'inside':'',
            'outside':'{} has appeared on a document {} times with {} ',
            'ideogram':'{} <br> Has {} links to other authors in this network'
    }
chord.buildDiagram(data_matrix,dimensions,labels,colors,title,hover_text)

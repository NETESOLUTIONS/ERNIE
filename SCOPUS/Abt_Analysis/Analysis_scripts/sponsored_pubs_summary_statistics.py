'''
This script uses the SCOPUS data on ERNIE to generate data expected in the Abt tables
This script is revised to use an updated version of the documents table, cci_s_documents_jeroen_updated,
 that uses document citation counts from a frozen dataset
'''
import psycopg2
import argparse
import pandas as pd
import numpy as np
import chord
from math import ceil

# Collect user input and possibly override defaults based on that input
parser = argparse.ArgumentParser(description='''
 This script interfaces with the PostgreSQL database and then creates summary tables for the Abt project
''', formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument('-ph','--postgres_host',help='the server hosting the PostgreSQL server',default='localhost',type=str)
parser.add_argument('-pd','--postgres_dbname',help='the database to query in the PostgreSQL server',type=str,required=True)
parser.add_argument('-pp','--postgres_port',help='the port hosting the PostgreSQL service on the server', default='5432',type=int)
parser.add_argument('-U','--postgres_user',help='the PostgreSQL user to log in as',required=True)
parser.add_argument('-W','--postgres_password',help='the password of the PostgreSQL user',required=True)
args = parser.parse_args()
postgres_dsn={'host':args.postgres_host,'dbname':args.postgres_dbname,'port':args.postgres_port,'user':args.postgres_user,'password':args.postgres_password}
postgres_conn=psycopg2.connect(" ".join("{}={}".format(k,postgres_dsn[k]) for k in postgres_dsn))

# Collect a dataframe on the number of papers per center where the papers are known sponsor linked papers
def total_pubs_per_center(postgres_conn):
    df = pd.read_sql_query('''
    SELECT award_number,
          (SELECT publication_year FROM cci_s_documents_jeroen_updated b WHERE a.scopus_id=b.scopus_id) as publication_year,
          count(1) as n_pubs
    FROM cci_s_award_paper_matches a
    WHERE scopus_id in (SELECT scopus_id FROM cci_s_documents_jeroen_updated)
      AND award_number in (SELECT award_number FROM cci_phase_awards where phase is not null)
    GROUP BY award_number, publication_year
    ORDER BY award_number, publication_year;
    ''', con=postgres_conn)
    return (df)

# Collect a dataframe on the number of citations per center where the papers are known sponsor linked papers
def total_citations_per_center(postgres_conn):
    df = pd.read_sql_query('''
    SELECT award_number,publication_year,sum(n_citations) as sum_citations
    FROM
    (
      SELECT award_number,
          (SELECT publication_year FROM cci_s_documents_jeroen_updated b WHERE a.scopus_id=b.scopus_id) as publication_year,
          (SELECT scopus_cited_by_count FROM cci_s_documents_jeroen_updated b WHERE a.scopus_id=b.scopus_id) as n_citations
      FROM cci_s_award_paper_matches a
      WHERE scopus_id in (SELECT scopus_id FROM cci_s_documents_jeroen_updated)
        AND award_number in (SELECT award_number FROM cci_phase_awards where phase is not null)
      ) foo
    GROUP BY award_number, publication_year
    ORDER BY award_number, publication_year;
    ''', con=postgres_conn)
    return (df)

# Collect a dataframe for centile information for sponsor linked papers
def sponsored_centiles(postgres_conn):
    df = pd.read_sql_query('''
    WITH award_author_documents AS
    (
      SELECT a.award_number,
             a.author_id,
             a.first_year,
             b.scopus_id,
             (SELECT c.publication_year FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as publication_year,
             (SELECT c.scopus_cited_by_count FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as n_citations
        FROM cci_s_author_search_results a
        INNER JOIN cci_s_author_document_mappings b -- May need to be chopped down to give a more fine tuned look at viable author ids
        ON a.author_id=b.author_id
        INNER JOIN sl_sr_all_authors_combined d
        ON a.author_id=d.author_id
        WHERE a.award_number='COMP'
        OR a.award_number IN (SELECT award_number FROM cci_phase_awards WHERE phase IN ('II'))
        AND scopus_id NOT IN (SELECT scopus_id FROM cci_s_award_paper_matches)
    ),
    sponsored_documents AS
    (
      SELECT award_number,
             (SELECT DISTINCT b.first_year FROM cci_phase_awards b WHERE a.award_number=b.award_number) as first_year,
             scopus_id,
             (SELECT b.publication_year FROM cci_s_documents_jeroen_updated b WHERE a.scopus_id=b.scopus_id) as publication_year,
             (SELECT b.scopus_cited_by_count FROM cci_s_documents_jeroen_updated b WHERE a.scopus_id=b.scopus_id) as n_citations
        FROM cci_s_award_paper_matches  a
    )

    SELECT
      award_number,
      sponsored,
      publication_year,
      min(centile) as min,
      percentile_cont(0.25) WITHIN GROUP (ORDER BY centile) as pct_25,
      percentile_cont(0.50) WITHIN GROUP (ORDER BY centile) as pct_50,
      percentile_cont(0.75) WITHIN GROUP (ORDER BY centile) as pct_75,
      max(centile) as max,avg(centile) as mean
    FROM(
      SELECT scopus_id,sponsored,award_number,publication_year,n_citations, cume_dist() over (PARTITION BY publication_year ORDER BY n_citations)*100 as centile
      FROM (
              SELECT DISTINCT award_number, first_year,scopus_id,publication_year,n_citations,'UNKNOWN' as sponsored
              FROM award_author_documents
              WHERE publication_year BETWEEN first_year AND first_year+5

              UNION ALL

              SELECT DISTINCT award_number, first_year,scopus_id,publication_year,n_citations,'SPONSORED' as sponsored
              FROM sponsored_documents
              WHERE first_year IS NOT NULL
              AND publication_year IS NOT NULL

          ) foo
      ) bar
      GROUP BY award_number,sponsored,publication_year
      HAVING sponsored='SPONSORED'
      ORDER BY avg(centile);
    ''', con=postgres_conn)
    return (df)

# Collect a dataframe for centile information for sponsor linked papers
def sponsored_centile_list(postgres_conn):
    df = pd.read_sql_query('''
    WITH award_author_documents AS
    (
      SELECT a.award_number,
             a.author_id,
             a.first_year,
             b.scopus_id,
             (SELECT c.publication_year FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as publication_year,
             (SELECT c.scopus_cited_by_count FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as n_citations
        FROM cci_s_author_search_results a
        INNER JOIN cci_s_author_document_mappings b -- May need to be chopped down to give a more fine tuned look at viable author ids
        ON a.author_id=b.author_id
        INNER JOIN sl_sr_all_authors_combined d
        ON a.author_id=d.author_id
        WHERE a.award_number='COMP'
        OR a.award_number IN (SELECT award_number FROM cci_phase_awards WHERE phase IN ('II'))
        AND scopus_id NOT IN (SELECT scopus_id FROM cci_s_award_paper_matches)
    ),
    sponsored_documents AS
    (
      SELECT award_number,
             (SELECT DISTINCT b.first_year FROM cci_phase_awards b WHERE a.award_number=b.award_number) as first_year,
             scopus_id,
             (SELECT b.publication_year FROM cci_s_documents_jeroen_updated b WHERE a.scopus_id=b.scopus_id) as publication_year,
             (SELECT b.scopus_cited_by_count FROM cci_s_documents_jeroen_updated b WHERE a.scopus_id=b.scopus_id) as n_citations
        FROM cci_s_award_paper_matches  a
    )

    SELECT
        scopus_id,
        centile,
        publication_year,
        award_number
    FROM(
      SELECT scopus_id,sponsored,award_number,publication_year,n_citations, cume_dist() over (PARTITION BY publication_year ORDER BY n_citations)*100 as centile
      FROM (
              SELECT DISTINCT award_number, first_year,scopus_id,publication_year,n_citations,'UNKNOWN' as sponsored
              FROM award_author_documents
              WHERE publication_year BETWEEN first_year AND first_year+5

              UNION ALL

              SELECT DISTINCT award_number, first_year,scopus_id,publication_year,n_citations,'SPONSORED' as sponsored
              FROM sponsored_documents
              WHERE first_year IS NOT NULL
              AND publication_year IS NOT NULL

          ) foo
      ) bar WHERE sponsored='SPONSORED'
      ORDER BY centile DESC;
    ''', con=postgres_conn)
    return (df)

# Collect a dataframe for centile information for sponsor linked papers
def sponsored_centile_list_w_extra_awards(postgres_conn):
    df = pd.read_sql_query('''
    WITH award_author_documents AS
    (
      SELECT a.award_number,
             a.author_id,
             a.first_year,
             b.scopus_id,
             (SELECT c.publication_year FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as publication_year,
             (SELECT c.scopus_cited_by_count FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as n_citations
        FROM cci_s_author_search_results a
        INNER JOIN cci_s_author_document_mappings b -- May need to be chopped down to give a more fine tuned look at viable author ids
        ON a.author_id=b.author_id
        INNER JOIN sl_sr_all_authors_combined d
        ON a.author_id=d.author_id
        WHERE a.award_number='COMP'
        OR a.award_number IN (SELECT award_number FROM cci_phase_awards WHERE phase IN ('II'))
        AND scopus_id NOT IN (SELECT scopus_id FROM cci_s_award_paper_matches)
    ),
    sponsored_documents AS
    (
      SELECT award_number,
             (SELECT DISTINCT b.first_year FROM cci_phase_awards b WHERE a.award_number=b.award_number) as first_year,
             scopus_id,
             (SELECT b.publication_year FROM cci_s_documents_jeroen_updated b WHERE a.scopus_id=b.scopus_id) as publication_year,
             (SELECT b.scopus_cited_by_count FROM cci_s_documents_jeroen_updated b WHERE a.scopus_id=b.scopus_id) as n_citations
        FROM cci_s_award_paper_matches  a
    )

    SELECT
        scopus_id,
        centile,
        publication_year,
        award_number
    FROM(
      SELECT scopus_id,sponsored,award_number,publication_year,n_citations, cume_dist() over (PARTITION BY publication_year ORDER BY n_citations)*100 as centile
      FROM (
              SELECT DISTINCT award_number, first_year,scopus_id,publication_year,n_citations,'UNKNOWN' as sponsored
              FROM award_author_documents
              WHERE publication_year BETWEEN first_year AND first_year+5

              UNION ALL

              SELECT DISTINCT award_number, first_year,scopus_id,publication_year,n_citations,'SPONSORED' as sponsored
              FROM sponsored_documents
              WHERE publication_year IS NOT NULL

          ) foo
      ) bar WHERE sponsored='SPONSORED'
      ORDER BY centile DESC;
    ''', con=postgres_conn)
    return (df)

# perc_pubs_per_center_with_n_or_more_participants
def perc_pubs_per_center_with_n_or_more_participants(postgres_conn):
    df = pd.read_sql_query('''
    WITH award_author_documents AS
            (
              SELECT a.award_number,
                     a.author_id,
                     a.first_year,
                     b.scopus_id,
                     (SELECT c.publication_year FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as publication_year
                FROM cci_s_author_search_results a
                INNER JOIN cci_s_author_document_mappings b
                ON a.author_id=b.author_id
                INNER JOIN sl_sr_all_authors_combined d
                ON a.author_id=d.author_id
                WHERE a.award_number!='COMP'
            )
            SELECT sum(CASE WHEN n_participants >=  THEN 1 ELSE 0 END)::decimal/sum(1) as percentage_pubs_with_n_or_more_participants
            FROM(
                SELECT DISTINCT scopus_id,count(author_id) as n_participants
                FROM award_author_documents
                WHERE scopus_id in (SELECT scopus_id FROM cci_s_award_paper_matches
                                    WHERE scopus_id in (SELECT scopus_id FROM cci_s_documents_jeroen_updated)
                                    AND award_number in (SELECT award_number FROM cci_phase_awards where phase is not null))
                GROUP BY scopus_id
                ORDER BY scopus_id
            ) foo;
    ''', con=postgres_conn)
    return (df)






n_pubs_df = total_pubs_per_center(postgres_conn)
n_pubs_df_pivot=n_pubs_df.pivot(index='award_number',columns='publication_year',values='n_pubs')
print(n_pubs_df_pivot)
n_pubs_df_pivot.to_csv('sponsored_papers_n_pubs.csv')

n_citations_df = total_citations_per_center(postgres_conn)
n_citations_df_pivot=n_citations_df.pivot(index='award_number',columns='publication_year',values='sum_citations')
print(n_citations_df_pivot)
n_citations_df_pivot.to_csv('sponsored_papers_n_citations.csv')

avg_centiles_df = sponsored_centiles(postgres_conn)
avg_centiles_df_pivot=avg_centiles_df.pivot(index='award_number',columns='publication_year',values='mean')
print(avg_centiles_df_pivot)
avg_centiles_df_pivot.to_csv('sponsored_papers_avg_centiles.csv')

centile_list_df = sponsored_centile_list(postgres_conn)
print(centile_list_df)
centile_list_df.to_csv('sponsored_centile_list.csv',index=False)

centile_list_df_w_extra_awards = sponsored_centile_list_w_extra_awards(postgres_conn)
print(centile_list_df_w_extra_awards)
centile_list_df_w_extra_awards.to_csv('sponsored_centile_list_w_extra_awards.csv',index=False)

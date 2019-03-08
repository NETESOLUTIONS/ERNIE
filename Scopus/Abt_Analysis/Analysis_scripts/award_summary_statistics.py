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

# Collect data on the mean number of publications per center (average of the count of distinct documents per center) for a specific year
def mean_pubs_per_center(distance,phases,continuing,conn):
    cur=conn.cursor()
    cur.execute('''
    WITH award_author_documents AS
              (
                SELECT a.award_number,
                       a.author_id,
                       a.first_year,
                       b.scopus_id,
                       (SELECT c.publication_year FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as publication_year,
                       (SELECT c.scopus_cited_by_count FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as n_citations
                  FROM cci_s_author_search_results a
                  INNER JOIN cci_s_author_document_mappings b
                  ON a.author_id=b.author_id
                  INNER JOIN sl_sr_all_personel_and_comp d
                  ON a.author_id=d.author_id
                  WHERE a.award_number!='COMP'
                  AND a.award_number IN (SELECT award_number FROM cci_phase_awards
                                            WHERE phase IN %(phases)s
                                            AND phase_ii_or_has_phase_ii = %(continuing)s)

              )
              SELECT avg(n_pubs),stddev_pop(n_pubs) FROM
                (
                  SELECT award_number, count(distinct scopus_id) as n_pubs
                    FROM award_author_documents
                    WHERE publication_year = first_year + %(distance)s
                    GROUP BY award_number
                  ) foo;
    ''',{'distance':distance, 'phases':phases, 'continuing':continuing})
    results=cur.fetchone()
    mean_pubs=results[0]
    std_dev=results[1]
    return (mean_pubs,std_dev)

# Collect data on the mean number of citations per center (average of the sum of citations for all documents per center) for a specific year
def mean_citations_per_center(distance,phases,continuing,conn):
    cur=conn.cursor()
    cur.execute('''
    WITH award_author_documents AS
            (
              SELECT a.award_number,
                     a.author_id,
                     a.first_year,
                     b.scopus_id,
                     (SELECT c.publication_year FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as publication_year,
                     (SELECT c.scopus_cited_by_count FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as n_citations
                FROM cci_s_author_search_results a
                INNER JOIN cci_s_author_document_mappings b
                ON a.author_id=b.author_id
                INNER JOIN sl_sr_all_personel_and_comp d
                ON a.author_id=d.author_id
                WHERE a.award_number!='COMP'
                AND a.award_number IN (SELECT award_number FROM cci_phase_awards
                                          WHERE phase IN %(phases)s
                                          AND phase_ii_or_has_phase_ii = %(continuing)s)
            )
            SELECT avg(citation_sum),stddev_pop(citation_sum) FROM
              (
                SELECT award_number, sum(n_citations) as citation_sum
                  FROM award_author_documents
                  WHERE publication_year = first_year + %(distance)s
                  GROUP BY award_number
                ) foo;
    ''',{'distance':distance, 'phases':phases, 'continuing':continuing})
    results=cur.fetchone()
    mean_citations=results[0]
    std_dev=results[1]
    return (mean_citations,std_dev)

# Collect data on the mean number of pubs per participant per center (average of the count of distinct documents per author per center) for a specific year
def mean_pubs_per_participant(distance,phases,continuing,conn):
    cur=conn.cursor()
    cur.execute('''
    WITH award_author_documents AS
                (
                  SELECT a.award_number,
                         a.author_id,
                         a.first_year,
                         b.scopus_id,
                         (SELECT c.publication_year FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as publication_year,
                         (SELECT c.scopus_cited_by_count FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as n_citations
                    FROM cci_s_author_search_results a
                    INNER JOIN cci_s_author_document_mappings b
                    ON a.author_id=b.author_id
                    INNER JOIN sl_sr_all_personel_and_comp d
                    ON a.author_id=d.author_id
                    WHERE a.award_number!='COMP'
                    AND a.award_number IN (SELECT award_number FROM cci_phase_awards
                                              WHERE phase IN %(phases)s
                                              AND phase_ii_or_has_phase_ii = %(continuing)s)
                )
                SELECT avg(n_pubs),stddev_pop(n_pubs) FROM
                  (
                    SELECT award_number,author_id,count(distinct scopus_id) as n_pubs
                      FROM award_author_documents
                      WHERE publication_year = first_year + %(distance)s
                      GROUP BY award_number,author_id
                    ) foo;
    ''',{'distance':distance, 'phases':phases, 'continuing':continuing})
    results=cur.fetchone()
    mean_pubs=results[0]
    std_dev=results[1]
    return (mean_pubs,std_dev)

# Collect data on the mean number of citations per author per center (average of the sum of citations for all documents per author per center) for a specific year
def mean_citations_per_participant(distance,phases,continuing,conn):
    cur=conn.cursor()
    cur.execute('''
    WITH award_author_documents AS
              (
                SELECT a.award_number,
                       a.author_id,
                       a.first_year,
                       b.scopus_id,
                       (SELECT c.publication_year FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as publication_year,
                       (SELECT c.scopus_cited_by_count FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as n_citations
                  FROM cci_s_author_search_results a
                  INNER JOIN cci_s_author_document_mappings b
                  ON a.author_id=b.author_id
                  INNER JOIN sl_sr_all_personel_and_comp d
                  ON a.author_id=d.author_id
                  WHERE a.award_number!='COMP'
                  AND a.award_number IN (SELECT award_number FROM cci_phase_awards
                                            WHERE phase IN %(phases)s
                                            AND phase_ii_or_has_phase_ii = %(continuing)s)
              )
              SELECT avg(citation_sum),stddev_pop(citation_sum) FROM
                (
                  SELECT award_number,author_id,sum(n_citations) as citation_sum
                    FROM award_author_documents
                    WHERE publication_year = first_year + %(distance)s
                    GROUP BY award_number,author_id
                  ) foo;
    ''',{'distance':distance, 'phases':phases, 'continuing':continuing})
    results=cur.fetchone()
    mean_citations=results[0]
    std_dev=results[1]
    return (mean_citations,std_dev)

# Collect data on the percent of publications with n or more participants
def perc_pubs_per_center_with_n_or_more_participants(distance,phases,continuing,n_participants,conn):
    cur=conn.cursor()
    cur.execute('''
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
              INNER JOIN sl_sr_all_personel_and_comp d
              ON a.author_id=d.author_id
              WHERE a.award_number!='COMP'
              AND a.award_number IN (SELECT award_number FROM cci_phase_awards
                                        WHERE phase IN %(phases)s
                                        AND phase_ii_or_has_phase_ii = %(continuing)s)
          )
          SELECT avg(percentage_pubs_with_n_or_more_participants),stddev_pop(percentage_pubs_with_n_or_more_participants) FROM
          (
            SELECT award_number,sum(CASE WHEN n_participants >= %(n_participants)s THEN 1 ELSE 0 END)::decimal/sum(1) as percentage_pubs_with_n_or_more_participants
            FROM(
                SELECT award_number,scopus_id,count(author_id) as n_participants
                FROM award_author_documents
                WHERE publication_year = first_year + %(distance)s
                GROUP BY award_number,scopus_id
            ) foo
            GROUP BY award_number
          ) bar;
    ''',{'distance':distance, 'phases':phases, 'n_participants':n_participants, 'continuing':continuing})
    results=cur.fetchone()
    percentage=results[0]
    std_dev=results[1]
    return (percentage,std_dev)

# Collect data on the percent of publications with n or more participants
def perc_pubs_per_center_with_num_participants_in_range(distance,phases,continuing,range,conn):
    cur=conn.cursor()
    cur.execute('''
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
              INNER JOIN sl_sr_all_personel_and_comp d
              ON a.author_id=d.author_id
              WHERE a.award_number!='COMP'
              AND a.award_number IN (SELECT award_number FROM cci_phase_awards
                                        WHERE phase IN %(phases)s
                                        AND phase_ii_or_has_phase_ii = %(continuing)s)
          )
          SELECT avg(percentage_pubs_with_num_participants_in_range),stddev_pop(percentage_pubs_with_num_participants_in_range) FROM
          (
            SELECT award_number,sum(CASE WHEN n_participants IN %(range)s THEN 1 ELSE 0 END)::decimal/sum(1) as percentage_pubs_with_num_participants_in_range
            FROM(
                SELECT award_number,scopus_id,count(author_id) as n_participants
                FROM award_author_documents
                WHERE publication_year = first_year + %(distance)s
                GROUP BY award_number,scopus_id
            ) foo
            GROUP BY award_number
          ) bar;
    ''',{'distance':distance, 'phases':phases, 'range':range, 'continuing':continuing})
    results=cur.fetchone()
    percentage=results[0]
    std_dev=results[1]
    return (percentage,std_dev)

# Collect data on the mean number of publications per author in the comparison group
def mean_pubs_per_comp_participant(distance,conn):
    cur=conn.cursor()
    cur.execute('''
    WITH award_author_documents AS
                (
                  SELECT a.award_number,
                         a.author_id,
                         a.first_year,
                         b.scopus_id,
                         (SELECT c.publication_year FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as publication_year,
                         (SELECT c.scopus_cited_by_count FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as n_citations
                    FROM cci_s_author_search_results a
                    INNER JOIN cci_s_author_document_mappings b
                    ON a.author_id=b.author_id
                    INNER JOIN sl_sr_all_personel_and_comp d
                    ON a.author_id=d.author_id
                    WHERE a.award_number='COMP'
                )
                SELECT avg(n_pubs),stddev_pop(n_pubs) FROM
                  (
                    SELECT award_number,author_id,count(distinct scopus_id) as n_pubs
                      FROM award_author_documents
                      WHERE publication_year = first_year + %(distance)s
                      GROUP BY award_number,author_id
                    ) foo;
    ''',{'distance':distance})
    results=cur.fetchone()
    mean_pubs=results[0]
    std_dev=results[1]
    return (mean_pubs,std_dev)

# Collect data on the mean number of citations per author in the comparison group
def mean_citations_per_comp_participant(distance,conn):
    cur=conn.cursor()
    cur.execute('''
    WITH award_author_documents AS
                (
                  SELECT a.award_number,
                         a.author_id,
                         a.first_year,
                         b.scopus_id,
                         (SELECT c.publication_year FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as publication_year,
                         (SELECT c.scopus_cited_by_count FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as n_citations
                    FROM cci_s_author_search_results a
                    INNER JOIN cci_s_author_document_mappings b
                    ON a.author_id=b.author_id
                    INNER JOIN sl_sr_all_personel_and_comp d
                    ON a.author_id=d.author_id
                    WHERE a.award_number='COMP'
                )
                SELECT avg(citation_sum),stddev_pop(citation_sum) FROM
                  (
                    SELECT award_number,author_id,sum(n_citations) as citation_sum
                      FROM award_author_documents
                      WHERE publication_year = first_year + %(distance)s
                      GROUP BY award_number,author_id
                    ) foo;
    ''',{'distance':distance})
    results=cur.fetchone()
    mean_citations=results[0]
    std_dev=results[1]
    return (mean_citations,std_dev)

# Collect centile data on the productivity (breakdown of count of publications per author) for a center, only considering publications from the authors during the range of funding
def productivity_centile_calculations_center(center,conn):
    cur=conn.cursor()
    cur.execute('''
        WITH award_author_documents AS
              (
                SELECT a.award_number,
                       a.author_id,
                       a.first_year,
                       b.scopus_id,
                       (SELECT c.publication_year FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as publication_year,
                       (SELECT c.scopus_cited_by_count FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as n_citations
                  FROM cci_s_author_search_results a
                  INNER JOIN cci_s_author_document_mappings b
                  ON a.author_id=b.author_id
                  INNER JOIN sl_sr_all_personel_and_comp d
                  ON a.author_id=d.author_id
                  WHERE a.award_number=%(center)s
                  --OR a.award_number='COMP'

              )
              SELECT min(n_pubs) as min,
                percentile_disc(0.25) WITHIN GROUP (ORDER BY n_pubs) as pct_25,
                percentile_disc(0.50) WITHIN GROUP (ORDER BY n_pubs) as pct_50,
                percentile_disc(0.75) WITHIN GROUP (ORDER BY n_pubs) as pct_75,
                max(n_pubs) as max,avg(n_pubs) as mean
              FROM(
                SELECT author_id,n_pubs,ntile(100) over (order by n_pubs) as centile FROM
                  (
                    SELECT author_id,count(distinct scopus_id) as n_pubs
                    FROM award_author_documents
                    WHERE publication_year BETWEEN first_year AND first_year+5
                    GROUP BY author_id
                  ) foo
                ) bar;
        ''',{'center':center})
    results=cur.fetchone()
    return (results)

# Collect percentile data on the impact of all centers and the background set (breakdown of centiles of citations, grouped by year. Then calculate centiles by center on the citation centiles)
def phase_II_centile_calculations_center_and_comp(conn):
    cur=conn.cursor()
    cur.execute('''
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
                  INNER JOIN sl_sr_all_personel_and_comp d
                  ON a.author_id=d.author_id
                  WHERE a.award_number='COMP'
                  OR a.award_number IN (SELECT award_number FROM cci_phase_awards WHERE phase IN ('II'))
              )
              SELECT
                award_number,
                min(centile) as min,
                percentile_cont(0.25) WITHIN GROUP (ORDER BY centile) as pct_25,
                percentile_cont(0.50) WITHIN GROUP (ORDER BY centile) as pct_50,
                percentile_cont(0.75) WITHIN GROUP (ORDER BY centile) as pct_75,
                max(centile) as max,avg(centile) as mean
              FROM(
                SELECT scopus_id,award_number,publication_year,n_citations, cume_dist() over (PARTITION BY publication_year ORDER BY n_citations)*100 as centile
                FROM (
                        SELECT DISTINCT award_number, first_year,scopus_id,publication_year, n_citations
                        FROM award_author_documents
                        WHERE publication_year BETWEEN first_year AND first_year+5
                    ) foo

                ) bar
                GROUP BY award_number
                ORDER BY avg(centile);
        ''')
    results=cur.fetchone()
    return (results)

# Run the loop for the following combinations of centers
# Adjust the phase combos to consider Phase I only awards, and Phase I awards which went on to have Phase II funding
# Later, ask if we want a similar table to the above, which consider only phase II awards
phase_combos=[ [('I',),'FALSE']]
final_df=pd.DataFrame()
for phase_combo in phase_combos:
    output_df=pd.DataFrame()
    for i in range(-5,13): # Consider the time period 5 years before to 13 years after the period of funding
        mppc=mean_pubs_per_center(i,phase_combo[0],phase_combo[1], postgres_conn)
        mcpc=mean_citations_per_center(i,phase_combo[0],phase_combo[1], postgres_conn)
        mppp=mean_pubs_per_participant(i,phase_combo[0],phase_combo[1], postgres_conn)
        mcpp=mean_citations_per_participant(i,phase_combo[0],phase_combo[1], postgres_conn)
        mppcp=mean_pubs_per_comp_participant(i,postgres_conn)
        mcpcp=mean_citations_per_comp_participant(i,postgres_conn)
        column=pd.Series([mppc[0],mcpc[0],mppp[0],mcpp[0]])
        print()
        print ("PHASES CONSIDERED: {}".format(phase_combo[0]))
        print("Mean Pubs Per Center for First Year + ({}) : {:.4f}  - with Standard Deviation: {:.4f} ".format(i,mppc[0],mppc[1]))
        print("Mean Citations Per Center for First Year + ({}) : {:.4f} - with Standard Deviation: {:.4f} ".format(i,mcpc[0],mcpc[1]))
        print("Mean Publications Per Participant for First Year + ({}) : {:.4f} - with Standard Deviation: {:.4f} ".format(i,mppp[0],mppp[1]))
        print("Mean Citations Per Participant for First Year + ({}) : {:.4f} - with Standard Deviation: {:.4f} ".format(i,mcpp[0],mcpp[1]))
        for set in [('2',), ('3','4'), ('5','6')]:
            pppc=perc_pubs_per_center_with_num_participants_in_range(i,phase_combo[0],phase_combo[1],set,postgres_conn)
            column=column.append(pd.Series([pppc[0]]),ignore_index=True)
            print("% Pubs Per Center with {} CCI Participants for First Year + ({}) : {:.4f} % - with Standard Deviation: {:.4f} %".format(set,i,pppc[0],pppc[1]))
        for num in ['7']:
            pppc=perc_pubs_per_center_with_n_or_more_participants(i,phase_combo[0],phase_combo[1],num,postgres_conn)
            column=column.append(pd.Series([pppc[0]]),ignore_index=True)
            print("% Pubs Per Center with {} or More CCI Participants for First Year + ({}) : {:.4f} % - with Standard Deviation: {:.4f} %".format(num,i,pppc[0],pppc[1]))
        column=column.append(pd.Series([mppcp[0],mcpcp[0]]),ignore_index=True)
        print("Mean Publications Per Comparison Participant for First Year + ({}) : {:.4f} - with Standard Deviation: {:.4f} ".format(i,mppcp[0],mppcp[1]))
        print("Mean Citations Per Comparison Participant for First Year + ({}) : {:.4f} - with Standard Deviation: {:.4f} ".format(i,mcpcp[0],mcpcp[1]))
        print()
        output_df['{}'.format(i)] = column
    output_df=output_df.rename({0:'Mean N pubs per center (all scopus)',1:'Mean N citations per center (all scopus)',
                    2:'Mean N pubs per participant (all scopus)',3:'Mean N citation per participant (all scopus)',
                    4:'Mean % Pubs Per Center with 2 CCI Participants',5:'Mean % Pubs Per Center with 3-4 CCI Participants',
                    6:'Mean % Pubs Per Center with 5-6 CCI Participants',7:'Mean % Pubs Per Center with more than 6 CCI Participants',
                    8:'Mean N pubs per Comparison PI',9:'Mean N citation per Comparison PI'}, axis='index')
    output_df.to_csv('phase_I_only.csv')
    print(output_df)


phase_combos=[ [('I',),'TRUE']]
final_df=pd.DataFrame()
for phase_combo in phase_combos:
    output_df=pd.DataFrame()
    for i in range(-5,3): # Consider the time period 5 years before to 13 years after the period of funding
        mppc=mean_pubs_per_center(i,phase_combo[0],phase_combo[1], postgres_conn)
        mcpc=mean_citations_per_center(i,phase_combo[0],phase_combo[1], postgres_conn)
        mppp=mean_pubs_per_participant(i,phase_combo[0],phase_combo[1], postgres_conn)
        mcpp=mean_citations_per_participant(i,phase_combo[0],phase_combo[1], postgres_conn)
        mppcp=mean_pubs_per_comp_participant(i,postgres_conn)
        mcpcp=mean_citations_per_comp_participant(i,postgres_conn)
        column=pd.Series([mppc[0],mcpc[0],mppp[0],mcpp[0]])
        print()
        print ("PHASES CONSIDERED: {}".format(phase_combo[0]))
        print("Mean Pubs Per Center for First Year + ({}) : {:.4f}  - with Standard Deviation: {:.4f} ".format(i,mppc[0],mppc[1]))
        print("Mean Citations Per Center for First Year + ({}) : {:.4f} - with Standard Deviation: {:.4f} ".format(i,mcpc[0],mcpc[1]))
        print("Mean Publications Per Participant for First Year + ({}) : {:.4f} - with Standard Deviation: {:.4f} ".format(i,mppp[0],mppp[1]))
        print("Mean Citations Per Participant for First Year + ({}) : {:.4f} - with Standard Deviation: {:.4f} ".format(i,mcpp[0],mcpp[1]))
        for set in [('2',), ('3','4'), ('5','6')]:
            pppc=perc_pubs_per_center_with_num_participants_in_range(i,phase_combo[0],phase_combo[1],set,postgres_conn)
            column=column.append(pd.Series([pppc[0]]),ignore_index=True)
            print("% Pubs Per Center with {} CCI Participants for First Year + ({}) : {:.4f} % - with Standard Deviation: {:.4f} %".format(set,i,pppc[0],pppc[1]))
        for num in ['7']:
            pppc=perc_pubs_per_center_with_n_or_more_participants(i,phase_combo[0],phase_combo[1],num,postgres_conn)
            column=column.append(pd.Series([pppc[0]]),ignore_index=True)
            print("% Pubs Per Center with {} or More CCI Participants for First Year + ({}) : {:.4f} % - with Standard Deviation: {:.4f} %".format(num,i,pppc[0],pppc[1]))
        column=column.append(pd.Series([mppcp[0],mcpcp[0]]),ignore_index=True)
        print("Mean Publications Per Comparison Participant for First Year + ({}) : {:.4f} - with Standard Deviation: {:.4f} ".format(i,mppcp[0],mppcp[1]))
        print("Mean Citations Per Comparison Participant for First Year + ({}) : {:.4f} - with Standard Deviation: {:.4f} ".format(i,mcpcp[0],mcpcp[1]))
        print()
        output_df['{}'.format(i)] = column
    output_df=output_df.rename({0:'Mean N pubs per center (all scopus)',1:'Mean N citations per center (all scopus)',
                    2:'Mean N pubs per participant (all scopus)',3:'Mean N citation per participant (all scopus)',
                    4:'Mean % Pubs Per Center with 2 CCI Participants',5:'Mean % Pubs Per Center with 3-4 CCI Participants',
                    6:'Mean % Pubs Per Center with 5-6 CCI Participants',7:'Mean % Pubs Per Center with more than 6 CCI Participants',
                    8:'Mean N pubs per Comparison PI',9:'Mean N citation per Comparison PI'}, axis='index')
    output_df.to_csv('phase_I_with_phase_II.csv')
    print(output_df)


phase_combos=[ [('II',),'TRUE']]
final_df=pd.DataFrame()
for phase_combo in phase_combos:
    output_df=pd.DataFrame()
    for i in range(0,10): # Consider the time period 5 years before to 13 years after the period of funding
        mppc=mean_pubs_per_center(i,phase_combo[0],phase_combo[1], postgres_conn)
        mcpc=mean_citations_per_center(i,phase_combo[0],phase_combo[1], postgres_conn)
        mppp=mean_pubs_per_participant(i,phase_combo[0],phase_combo[1], postgres_conn)
        mcpp=mean_citations_per_participant(i,phase_combo[0],phase_combo[1], postgres_conn)
        mppcp=mean_pubs_per_comp_participant(i,postgres_conn)
        mcpcp=mean_citations_per_comp_participant(i,postgres_conn)
        column=pd.Series([mppc[0],mcpc[0],mppp[0],mcpp[0]])
        print()
        print ("PHASES CONSIDERED: {}".format(phase_combo[0]))
        print("Mean Pubs Per Center for First Year + ({}) : {:.4f}  - with Standard Deviation: {:.4f} ".format(i,mppc[0],mppc[1]))
        print("Mean Citations Per Center for First Year + ({}) : {:.4f} - with Standard Deviation: {:.4f} ".format(i,mcpc[0],mcpc[1]))
        print("Mean Publications Per Participant for First Year + ({}) : {:.4f} - with Standard Deviation: {:.4f} ".format(i,mppp[0],mppp[1]))
        print("Mean Citations Per Participant for First Year + ({}) : {:.4f} - with Standard Deviation: {:.4f} ".format(i,mcpp[0],mcpp[1]))
        for set in [('2',), ('3','4'), ('5','6')]:
            pppc=perc_pubs_per_center_with_num_participants_in_range(i,phase_combo[0],phase_combo[1],set,postgres_conn)
            column=column.append(pd.Series([pppc[0]]),ignore_index=True)
            print("% Pubs Per Center with {} CCI Participants for First Year + ({}) : {:.4f} % - with Standard Deviation: {:.4f} %".format(set,i,pppc[0],pppc[1]))
        for num in ['7']:
            pppc=perc_pubs_per_center_with_n_or_more_participants(i,phase_combo[0],phase_combo[1],num,postgres_conn)
            column=column.append(pd.Series([pppc[0]]),ignore_index=True)
            print("% Pubs Per Center with {} or More CCI Participants for First Year + ({}) : {:.4f} % - with Standard Deviation: {:.4f} %".format(num,i,pppc[0],pppc[1]))
        column=column.append(pd.Series([mppcp[0],mcpcp[0]]),ignore_index=True)
        print("Mean Publications Per Comparison Participant for First Year + ({}) : {:.4f} - with Standard Deviation: {:.4f} ".format(i,mppcp[0],mppcp[1]))
        print("Mean Citations Per Comparison Participant for First Year + ({}) : {:.4f} - with Standard Deviation: {:.4f} ".format(i,mcpcp[0],mcpcp[1]))
        print()
        output_df['{}'.format(i)] = column
    output_df=output_df.rename({0:'Mean N pubs per center (all scopus)',1:'Mean N citations per center (all scopus)',
                    2:'Mean N pubs per participant (all scopus)',3:'Mean N citation per participant (all scopus)',
                    4:'Mean % Pubs Per Center with 2 CCI Participants',5:'Mean % Pubs Per Center with 3-4 CCI Participants',
                    6:'Mean % Pubs Per Center with 5-6 CCI Participants',7:'Mean % Pubs Per Center with more than 6 CCI Participants',
                    8:'Mean N pubs per Comparison PI',9:'Mean N citation per Comparison PI'}, axis='index')
    output_df.to_csv('phase_II_only.csv')
    print(output_df)

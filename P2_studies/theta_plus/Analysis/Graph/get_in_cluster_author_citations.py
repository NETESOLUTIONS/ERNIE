"""
How many in-cluster citations (SCPs)?
How many of these come from authors in the 95th percentile?
"""

import numpy
import pandas as pd
from sys import argv
from sqlalchemy import create_engine

user_name = argv[1]
password = argv[2]
schema = "theta_plus"
sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)

rated_table = 'expert_ratings'
rated_clusters_table = pd.read_sql_table(rated_table, schema=schema, con=engine)
rated_clusters = rated_clusters_table['imm1985_1995_cluster_no'].tolist()

for cluster_num in rated_clusters:    
    
    citing_cited_query ="""SELECT cluster_no, citing, cited
                    FROM   (SELECT cluster_no, scp
                           FROM theta_plus.imm1985_1995_cluster_scp_list_mcl
                            WHERE cluster_no=""" + str(cluster_num) + """ ) rated_scp1
                    JOIN theta_plus.imm1985_1995_citing_cited_union ccu1 ON rated_scp1.scp = ccu1.citing
                     WHERE ccu1.cited in (SELECT scp FROM theta_plus.imm1985_1995_cluster_scp_list_mcl
                            WHERE cluster_no=""" + str(cluster_num) + """)
                    UNION SELECT cluster_no, citing, cited
                      FROM (SELECT cluster_no, scp
                           FROM theta_plus.imm1985_1995_cluster_scp_list_mcl
                            WHERE cluster_no=""" + str(cluster_num) + """) rated_scp1
                      JOIN theta_plus.imm1985_1995_citing_cited_union ccu1 ON rated_scp1.scp = ccu1.cited
                      WHERE ccu1.citing in (SELECT scp FROM theta_plus.imm1985_1995_cluster_scp_list_mcl
                            WHERE cluster_no=""" + str(cluster_num) + """) ; """
    
    citing_cited = pd.read_sql(citing_cited_query, con=engine)
    
    all_possible_95_query =""" SELECT set_1.cluster_no, set_1.scp scp_1, set_2.scp scp_2
               FROM (SELECT DISTINCT scps.cluster_no, scps.scp
                     FROM (SELECT cslu.cluster_no, cslu.scp, sa.auid
                           FROM theta_plus.imm1985_1995_cluster_scp_list_mcl cslu
                           LEFT JOIN public.scopus_authors sa ON cslu.scp = sa.scp
                           WHERE cslu.cluster_no=""" + str(cluster_num) + """) scps
                           JOIN (SELECT authors.cluster_no, authors.auid
                                 FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                                       FROM theta_plus.imm1985_1995_cluster_scp_list_mcl cslu
                                        LEFT JOIN public.scopus_authors sa ON cslu.scp = sa.scp
                                        WHERE cslu.cluster_no=""" + str(cluster_num) + """
                                        GROUP BY cslu.cluster_no, sa.auid) authors
                                        JOIN theta_plus.imm1985_1995_all_merged_unshuffled amu
                                            ON authors.cluster_no = amu.cluster_no
                                        WHERE authors.num_articles >= amu.p_95_author_count ) authors_95
                                ON scps.auid = authors_95.auid and scps.cluster_no = authors_95.cluster_no) set_1
                            JOIN (SELECT DISTINCT scps.cluster_no, scps.scp
                            FROM (SELECT cslu.cluster_no, cslu.scp, sa.auid
                                  FROM theta_plus.imm1985_1995_cluster_scp_list_mcl cslu
                                  LEFT JOIN public.scopus_authors sa ON cslu.scp = sa.scp
                                  WHERE cslu.cluster_no=""" + str(cluster_num) + """) scps
                                  JOIN(SELECT authors.cluster_no, authors.auid
                                       FROM (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                                             FROM theta_plus.imm1985_1995_cluster_scp_list_mcl cslu
                                             LEFT JOIN public.scopus_authors sa ON cslu.scp = sa.scp
                                             WHERE cslu.cluster_no=""" + str(cluster_num) + """
                            GROUP BY cslu.cluster_no, sa.auid) authors
                           JOIN theta_plus.imm1985_1995_all_merged_unshuffled amu ON authors.cluster_no = amu.cluster_no
                           WHERE authors.num_articles >= amu.p_95_author_count ) authors_95
                                ON scps.auid = authors_95.auid and scps.cluster_no = authors_95.cluster_no) set_2
                            ON set_1.scp < set_2.scp; """

    all_possible_95 = pd.read_sql(all_possible_95_query, con=engine)
    citing_cited['edge_set'] = citing_cited[['citing', 'cited']].values.tolist()
    citing_cited['edge_set'] = tuple(citing_cited['edge_set'].apply(lambda x: sorted(x, reverse=False)))
    all_possible_95['edge_set'] = [tuple(x) for x in all_possible_95[['scp_1', 'scp_2']].to_numpy()]
    counts = [edge for edge in all_possible_95['edge_set'].tolist() if edge in citing_cited['edge_set'].tolist()]
    
    result_dict = {'cluster_no': cluster_num,
                   'in_cluster_citations': [len(citing_cited)],
                   'coauthor_citations_95': len(counts)}
    
    result_df = pd.DataFrame.from_dict(result_dict)
    
    result_df.to_sql('rated_coauthor_citations', schema=schema, con=engine, if_exists='append', index=False)
    
print("All completed.")
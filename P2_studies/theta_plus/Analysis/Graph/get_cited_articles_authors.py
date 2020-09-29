import numpy
import pandas as pd
from sys import argv
from sqlalchemy import create_engine

user_name = argv[1]
password = argv[2]
start_cluster_num = int(argv[3])

schema = "theta_plus"
sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)
save_name_sql = 'imm1985_1995_cited_articles_authors'

imm1985_1995_all_merged = pd.read_sql("SELECT cluster_no from theta_plus.imm1985_1995_all_merged_mcl;", con=engine)
imm1985_1995_all_merged = imm1985_1995_all_merged.sort_values('cluster_no').reset_index(drop=True)

imm1985_1995_all_merged['count_cited_articles'] = None
imm1985_1995_all_merged['max_count_cited_articles'] = None
imm1985_1995_all_merged['max_cited_article'] = None

imm1985_1995_all_merged['count_cited_authors'] = None
imm1985_1995_all_merged['max_count_cited_authors'] = None
imm1985_1995_all_merged['max_cited_authors'] = None

for cluster_num in imm1985_1995_all_merged['cluster_no'][start_cluster_num-1:]:
    
    cited_articles_query = ("""
            SELECT all_union.cited, count(all_union.cited) count_cited
              FROM
                  (SELECT cluster_no, citing, cited

                    FROM
                          (SELECT cluster_no, scp
                           FROM theta_plus.imm1985_1995_cluster_scp_list_mcl
                            WHERE cluster_no=
                            """
                         + str(cluster_num) +
                            """
                            ) rated_scp1

                    JOIN theta_plus.imm1985_1995_citing_cited_union ccu1

                     ON rated_scp1.scp = ccu1.citing
                     WHERE ccu1.cited in (SELECT scp
                           FROM theta_plus.imm1985_1995_cluster_scp_list_mcl
                            WHERE cluster_no=
                            """
                         + str(cluster_num) +
                            """
                            )

                  UNION SELECT cluster_no, citing, cited

                    FROM
                          (SELECT cluster_no, scp
                           FROM theta_plus.imm1985_1995_cluster_scp_list_mcl
                            WHERE cluster_no=
                            """
                         + str(cluster_num) +
                            """
                            ) rated_scp1

                    JOIN theta_plus.imm1985_1995_citing_cited_union ccu1

                     ON rated_scp1.scp = ccu1.cited
                     WHERE ccu1.citing in (SELECT scp
                           FROM theta_plus.imm1985_1995_cluster_scp_list_mcl
                            WHERE cluster_no=
                            """
                        + str(cluster_num) +
                            """
                            )
                    ) all_union
                GROUP BY all_union.cited;
            """)
    
    cited_articles = pd.read_sql(cited_articles_query, con=engine)
    imm1985_1995_all_merged.at[cluster_num-1, 'count_cited_articles'] = len(cited_articles)
    if len(cited_articles) > 0:
        max_val_articles = int(cited_articles['count_cited'].max())
        imm1985_1995_all_merged.at[cluster_num-1, 'max_count_cited_articles'] = max_val_articles
        if type(cited_articles.set_index('count_cited').at[max_val_articles, 'cited']) == numpy.int64:
            max_cited_article = int(cited_articles.set_index('count_cited').at[max_val_articles, "cited"])
        elif type(cited_articles.set_index('count_cited').at[max_val_articles, 'cited']) == numpy.ndarray:
            max_cited_article = ' '.join(str(article) for article in cited_articles.set_index('count_cited').at[max_val_articles, "cited"])
        imm1985_1995_all_merged.at[cluster_num-1, 'max_cited_article'] = max_cited_article
    else:
        imm1985_1995_all_merged.at[cluster_num-1, 'max_count_cited_articles'] = None
        imm1985_1995_all_merged.at[cluster_num-1, 'max_cited_article'] = None
    
    cited_authors_query =("""
        SELECT num_authors.author_cited, count(author_cited) count_cited
        FROM
        (SELECT sa1.auid author_citing, sa2.auid author_cited
        FROM
              (SELECT all_union.cluster_no, all_union.scp, all_union.citing, all_union.cited
              FROM
                  (SELECT cluster_no, scp, citing, cited

                    FROM
                          (SELECT cluster_no, scp
                           FROM theta_plus.imm1985_1995_cluster_scp_list_mcl
                            WHERE cluster_no=
                            """
                         + str(cluster_num) +
                            """
                            ) rated_scp1

                    JOIN theta_plus.imm1985_1995_citing_cited_union ccu1

                     ON rated_scp1.scp = ccu1.citing
                     WHERE ccu1.cited in (SELECT scp
                           FROM theta_plus.imm1985_1995_cluster_scp_list_mcl
                            WHERE cluster_no=
                            """
                         + str(cluster_num) +
                            """
                            )

                  UNION SELECT cluster_no, scp, citing, cited

                    FROM
                          (SELECT cluster_no, scp
                           FROM theta_plus.imm1985_1995_cluster_scp_list_mcl
                            WHERE cluster_no=
                            """
                         + str(cluster_num) +
                            """
                            ) rated_scp1

                    JOIN theta_plus.imm1985_1995_citing_cited_union ccu1

                     ON rated_scp1.scp = ccu1.cited
                     WHERE ccu1.citing in (SELECT scp
                           FROM theta_plus.imm1985_1995_cluster_scp_list_mcl
                            WHERE cluster_no=
                            """
                        + str(cluster_num) +
                            """)
                    ) all_union ) cluster1

            JOIN public.scopus_authors sa1
            ON cluster1.citing = sa1.scp

            JOIN public.scopus_authors sa2
            ON cluster1.cited = sa2.scp

            GROUP BY sa1.auid, sa2.auid) num_authors
            GROUP BY num_authors.author_cited;
    
                """)
    cited_authors = pd.read_sql(cited_authors_query, con=engine)
    imm1985_1995_all_merged.at[cluster_num-1, 'count_cited_authors'] = len(cited_authors)
    if len(cited_authors) > 0:
        max_val_authors = int(cited_authors['count_cited'].max())
        imm1985_1995_all_merged.at[cluster_num-1, 'max_count_cited_authors'] = max_val_authors
        if type(cited_authors.set_index('count_cited').at[max_val_authors, 'author_cited']) == numpy.ndarray:
            max_cited_authors = ' '.join(str(author) for author in cited_authors.set_index('count_cited').at[max_val_authors, 'author_cited'])
        elif type(cited_authors.set_index('count_cited').at[max_val_authors, 'author_cited']) == numpy.int64:
            max_cited_authors = int(cited_authors.set_index('count_cited').at[max_val_authors, 'author_cited'])
        imm1985_1995_all_merged.at[cluster_num-1, 'max_cited_authors'] = max_cited_authors
    else:
        imm1985_1995_all_merged.at[cluster_num-1, 'max_count_cited_authors'] = None
        imm1985_1995_all_merged.at[cluster_num-1, 'max_cited_authors'] = None
    
    imm1985_1995_all_merged[cluster_num-1:cluster_num].to_sql(save_name_sql, con=engine, schema=schema, index=False, if_exists='append')
    
print("All completed.")
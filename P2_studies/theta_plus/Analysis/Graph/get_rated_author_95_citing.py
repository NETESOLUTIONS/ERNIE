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
    
    citing_authors_95_query = """SELECT  coalesce(count(DISTINCT citing_author), 0) AS counts
    FROM
            (SELECT cslu.cluster_no, ccu.citing, ccu.cited, sa.auid citing_author
            FROM theta_plus.imm1985_1995_cluster_scp_list_mcl cslu
            LEFT JOIN theta_plus.imm1985_1995_citing_cited ccu ON cslu.scp = ccu.citing
            LEFT JOIN public.scopus_authors sa ON sa.scp=ccu.citing
            WHERE cslu.cluster_no=""" + str(cluster_num) + """ AND
                  sa.auid IN (SELECT authors.auid
                          FROM
                                (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                                FROM theta_plus.imm1985_1995_cluster_scp_list_mcl cslu
                                LEFT JOIN public.scopus_authors sa
                                    ON cslu.scp = sa.scp
                                WHERE cslu.cluster_no=""" + str(cluster_num) + """
                                GROUP BY cslu.cluster_no, sa.auid) authors

                          LEFT JOIN theta_plus.imm1985_1995_all_merged_unshuffled amu
                            ON authors.cluster_no = amu.cluster_no
                          WHERE authors.num_articles >= amu.p_95_author_count)) citing_95

    JOIN
            (SELECT cslu.cluster_no, ccu.citing, ccu.cited, sa.auid cited_author
            FROM theta_plus.imm1985_1995_cluster_scp_list_mcl cslu
            LEFT JOIN theta_plus.imm1985_1995_citing_cited ccu ON cslu.scp = ccu.cited
            LEFT JOIN public.scopus_authors sa ON sa.scp=ccu.cited
            WHERE cslu.cluster_no=""" + str(cluster_num) + """ AND
                  sa.auid IN (SELECT authors.auid
                          FROM
                                (SELECT cslu.cluster_no, sa.auid, count(sa.auid) num_articles
                                FROM theta_plus.imm1985_1995_cluster_scp_list_mcl cslu
                                LEFT JOIN public.scopus_authors sa
                                    ON cslu.scp = sa.scp
                                WHERE cslu.cluster_no=""" + str(cluster_num) + """
                                GROUP BY cslu.cluster_no, sa.auid) authors

                          LEFT JOIN theta_plus.imm1985_1995_all_merged_unshuffled amu
                            ON authors.cluster_no = amu.cluster_no
                          WHERE authors.num_articles >= amu.p_95_author_count)) cited_95

    ON citing_95.citing = cited_95.citing AND citing_95.cited = cited_95.cited;"""
    
    citing_authors_95 = pd.read_sql(citing_authors_95_query, con=engine)
    citing_authors_95_count = citing_authors_95.at[0, 'counts'].item()
    
    result_dict = {'cluster_no': cluster_num,
                   'count_citing_authors_95': [citing_authors_95_count]}
    
    result_df = pd.DataFrame.from_dict(result_dict)
    result_df.to_sql('rated_author_95_citing', schema=schema, con=engine, if_exists='append', index=False)
    
print("All completed.")
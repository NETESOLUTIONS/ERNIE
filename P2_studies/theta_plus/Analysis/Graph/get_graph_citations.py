import pandas as pd
from sqlalchemy import create_engine
from sys import argv

user_name = argv[1]
password = argv[2]
rated_table = "expert_ratings"
schema = "theta_plus"
sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)

rated_clusters_table = pd.read_sql_table(rated_table, schema=schema, con=engine)
rated_clusters = rated_clusters_table['imm1985_1995_cluster_no'].tolist()

def safe_div(x):
    """
    For cases where 0/0 return None
    
    Argument(s): x          - row of pandas dataframe (supply columns as indices)
    Output:      x[0]/x[1]  - division where denominator is not 0, else None
    """
    if x[1] == 0:
        return None
    return x[0] / x[1]

for cluster_num in rated_clusters:
    
    query = """
    SELECT in_cluster.cluster_no, in_cluster.scp, count_cited as in_cluster_cited,
      CASE WHEN all_cited.all_cluster_count IS NOT NULL THEN all_cited.all_cluster_count
           WHEN all_cited.all_cluster_count IS NULL THEN 0 END AS in_graph_cited
    FROM

      (SELECT cluster_no, scp,
             CASE WHEN count_cited IS NOT NULL THEN count_cited
                  WHEN count_cited IS NULL THEN 0 END AS count_cited

      FROM
              (SELECT *
              FROM theta_plus.imm1985_1995_cluster_scp_list_mcl
              WHERE cluster_no=
              """ + str(cluster_num) + """
              ) select_scp
      LEFT JOIN
            (SELECT all_union.cited, count(all_union.cited) count_cited
            FROM
                (SELECT cluster_no, citing, cited

                  FROM
                    (SELECT cluster_no, scp
                     FROM theta_plus.imm1985_1995_cluster_scp_list_mcl
                     WHERE cluster_no=
                  """ + str(cluster_num) + """
                      ) rated_scp1

                  JOIN theta_plus.imm1985_1995_citing_cited_union ccu1

                   ON rated_scp1.scp = ccu1.citing
                   WHERE ccu1.cited in (SELECT scp
                         FROM theta_plus.imm1985_1995_cluster_scp_list_mcl
                         WHERE cluster_no= 
                  """ + str(cluster_num) + """
                          )

                UNION SELECT cluster_no, citing, cited

                  FROM
                    (SELECT cluster_no, scp
                     FROM theta_plus.imm1985_1995_cluster_scp_list_mcl
                     WHERE cluster_no=
                  """ + str(cluster_num) + """
                      ) rated_scp1

                  JOIN theta_plus.imm1985_1995_citing_cited_union ccu1

                   ON rated_scp1.scp = ccu1.cited
                   WHERE ccu1.citing in (SELECT scp
                     FROM theta_plus.imm1985_1995_cluster_scp_list_mcl
                      WHERE cluster_no= 
                  """ + str(cluster_num) + """
                      )
                  ) all_union
              GROUP BY all_union.cited) cited_scp

      ON select_scp.scp = cited_scp.cited) in_cluster

      LEFT JOIN

      (SELECT cluster_no, cited, count(cited) all_cluster_count
      FROM
          (SELECT cluster_no, scp
           FROM theta_plus.imm1985_1995_cluster_scp_list_mcl
           WHERE cluster_no= 
              """ + str(cluster_num) + """
            ) rated_scp1
      JOIN theta_plus.imm1985_1995_citing_cited_union ccu1
          ON rated_scp1.scp = ccu1.cited
      GROUP BY cluster_no, cited)   all_cited

    ON in_cluster.scp=all_cited.cited AND in_cluster.cluster_no=all_cited.cluster_no
    """

    table = pd.read_sql(query, con=engine)
    table['cited_cluster_by_graph'] = table[['in_cluster_cited', 'in_graph_cited']].apply(safe_div, axis=1)
    table.to_sql('rated_graph_citations', schema=schema, con=engine, index=False, if_exists='append')
    
print("All Completed.")
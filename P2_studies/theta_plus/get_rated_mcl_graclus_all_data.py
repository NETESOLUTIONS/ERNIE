import pandas as pd
from sqlalchemy import create_engine
from sys import argv

user_name = "shreya"
password = "Akshay<3"
schema = "theta_plus"
sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)


main_table_query = """
SELECT er.expert_rating, er.imm1985_1995_cluster_no, s.current_cluster_size AS imm1985_1995_cluster_size, 
       s.match_year, s.match_cluster_no mcl_year_cluster_no
FROM theta_plus.expert_ratings er
JOIN theta_plus.superset_to_year_match_30_350 s
  ON er.imm1985_1995_cluster_no = s.current_cluster_number;
"""


main_table = pd.read_sql(main_table_query, con=engine)
main_table.name = 'rated_mcl_graclus_all_data'

main_table['mcl_year_cluster_size'] = None
main_table['mcl_year_conductance'] = None
main_table['mcl_year_coherence'] = None
main_table['mcl_year_int_edges'] = None
main_table['mcl_year_boundary'] = None
main_table['mcl_year_sum_article_score'] = None
main_table['mcl_year_max_article_score'] = None
main_table['mcl_year_median_article_score'] = None

main_table['graclus_100_cluster_no'] = None
main_table['graclus_100_cluster_size'] = None
main_table['graclus_100_to_mcl_ratio'] = None
main_table['graclus_100_total_intersection'] = None
main_table['graclus_100_total_union'] = None
main_table['graclus_100_intersection_union_ratio'] = None
main_table['graclus_100_multiple_options'] = None

main_table['graclus_100_conductance'] = None
main_table['graclus_100_coherence'] = None
main_table['graclus_100_int_edges'] = None
main_table['graclus_100_boundary'] = None
main_table['graclus_100_sum_article_score'] = None
main_table['graclus_100_max_article_score'] = None
main_table['graclus_100_median_article_score'] = None

main_table['graclus_half_mclsize_cluster_no'] = None
main_table['graclus_half_mclsize_cluster_size'] = None
main_table['graclus_half_mclsize_to_mcl_ratio'] = None
main_table['graclus_half_mclsize_total_intersection'] = None
main_table['graclus_half_mclsize_total_union'] = None
main_table['graclus_half_mclsize_intersection_union_ratio'] = None
main_table['graclus_half_mclsize_multiple_options'] = None

main_table['graclus_half_mclsize_conductance'] = None
main_table['graclus_half_mclsize_coherence'] = None
main_table['graclus_half_mclsize_int_edges'] = None
main_table['graclus_half_mclsize_boundary'] = None
main_table['graclus_half_mclsize_sum_article_score'] = None
main_table['graclus_half_mclsize_max_article_score'] = None
main_table['graclus_half_mclsize_median_article_score'] = None


print(f'Working on table: {schema}.{main_table.name}')
print(f'The size of the table is {len(main_table)}')
for i in range(len(main_table)):
    
    match_year = 'imm' +  str(main_table.at[ i, 'match_year'])
    
    mcl_year_table_name = match_year + "_all_merged_unshuffled"
    mcl_year_cluster_no = str(main_table.at[ i, 'mcl_year_cluster_no'])
    mcl_year_query = "SELECT cluster_size, conductance, coherence, int_edges, boundary, sum_article_score, max_article_score, median_article_score FROM theta_plus." + mcl_year_table_name + " WHERE cluster_no=" + mcl_year_cluster_no + ";"
    
    graclus_100_cluster_no_query = "SELECT * FROM theta_plus." + match_year + "_match_to_graclus WHERE mcl_cluster_no=" + mcl_year_cluster_no + ";"
    graclus_100_cluster_no_table = pd.read_sql(graclus_100_cluster_no_query, con=engine)
    
    graclus_100_cluster_no = str(graclus_100_cluster_no_table.at[0, 'graclus_cluster_no'])
    graclus_100_cluster_size = graclus_100_cluster_no_table.at[0, 'graclus_cluster_size']
    graclus_100_to_mcl_ratio = graclus_100_cluster_no_table.at[0, 'graclus_to_mcl_ratio']
    graclus_100_total_intersection = graclus_100_cluster_no_table.at[0, 'total_intersection']
    graclus_100_total_union = graclus_100_cluster_no_table.at[0, 'total_union']
    graclus_100_intersection_union_ratio = graclus_100_cluster_no_table.at[0, 'intersect_union_ratio']
    graclus_100_multiple_options = graclus_100_cluster_no_table.at[0, 'multiple_options']

    graclus_100_table_name = match_year + "_all_merged_graclus"
    graclus_100_query = "SELECT coherence, conductance, int_edges, boundary, sum_article_score, max_article_score, median_article_score FROM theta_plus." + graclus_100_table_name + " WHERE cluster_no=" + graclus_100_cluster_no + ";"
    
    graclus_half_mclsize_cluster_no_query = "SELECT * FROM theta_plus." + match_year + "_match_to_graclus_half_mclsize WHERE mcl_cluster_no=" + mcl_year_cluster_no + ";"
    graclus_half_mclsize_cluster_no_table = pd.read_sql(graclus_half_mclsize_cluster_no_query, con=engine)
    
    graclus_half_mclsize_cluster_no = str(graclus_half_mclsize_cluster_no_table.at[0, 'graclus_cluster_no'])
    graclus_half_mclsize_cluster_size = graclus_half_mclsize_cluster_no_table.at[0, 'graclus_cluster_size']
    graclus_half_mclsize_to_mcl_ratio = graclus_half_mclsize_cluster_no_table.at[0, 'graclus_to_mcl_ratio']
    graclus_half_mclsize_total_intersection = graclus_half_mclsize_cluster_no_table.at[0, 'total_intersection']
    graclus_half_mclsize_total_union = graclus_half_mclsize_cluster_no_table.at[0, 'total_union']
    graclus_half_mclsize_intersection_union_ratio = graclus_half_mclsize_cluster_no_table.at[0, 'intersect_union_ratio']
    graclus_half_mclsize_multiple_options = graclus_half_mclsize_cluster_no_table.at[0, 'multiple_options']

    graclus_half_mclsize_table_name = match_year + "_all_merged_graclus_half_mclsize"
    graclus_half_mclsize_query = "SELECT coherence, conductance, int_edges, boundary, sum_article_score, max_article_score, median_article_score FROM theta_plus." + graclus_half_mclsize_table_name + " WHERE cluster_no=" + graclus_half_mclsize_cluster_no + ";"
    
    mcl_year_table = pd.read_sql(mcl_year_query, con=engine)
    graclus_100_table = pd.read_sql(graclus_100_query, con=engine)
    graclus_half_mclsize_table = pd.read_sql(graclus_half_mclsize_query, con=engine)
    
    main_table.at[i, 'mcl_year_cluster_size'] = (mcl_year_table.at[0, 'cluster_size'])
    main_table.at[i, 'mcl_year_conductance'] = (mcl_year_table.at[0, 'conductance'])
    main_table.at[i,'mcl_year_coherence'] = mcl_year_table.at[0, 'coherence']
    main_table.at[i,'mcl_year_int_edges'] =  mcl_year_table.at[0, 'int_edges']
    main_table.at[i,'mcl_year_boundary'] = mcl_year_table.at[0, 'boundary']
    main_table.at[i,'mcl_year_sum_article_score'] = mcl_year_table.at[0, 'sum_article_score']
    main_table.at[i,'mcl_year_max_article_score'] = mcl_year_table.at[0, 'max_article_score']
    main_table.at[i,'mcl_year_median_article_score'] = mcl_year_table.at[0, 'median_article_score']
    
    main_table.at[i,'graclus_100_cluster_no'] = graclus_100_cluster_no
    main_table.at[i,'graclus_100_cluster_size'] = graclus_100_cluster_size 
    main_table.at[i,'graclus_100_to_mcl_ratio'] = graclus_100_to_mcl_ratio
    main_table.at[i,'graclus_100_total_intersection'] = graclus_100_total_intersection 
    main_table.at[i,'graclus_100_total_union'] = graclus_100_total_union
    main_table.at[i,'graclus_100_intersection_union_ratio'] = graclus_100_intersection_union_ratio
    main_table.at[i,'graclus_100_multiple_options'] = graclus_100_multiple_options
    
    main_table.at[i,'graclus_100_conductance'] = graclus_100_table.at[0, 'conductance']
    main_table.at[i,'graclus_100_coherence'] = graclus_100_table.at[0, 'coherence']
    main_table.at[i,'graclus_100_int_edges'] = graclus_100_table.at[0, 'int_edges']
    main_table.at[i,'graclus_100_boundary'] = graclus_100_table.at[0, 'boundary']
    main_table.at[i,'graclus_100_sum_article_score'] = graclus_100_table.at[0, 'sum_article_score']
    main_table.at[i,'graclus_100_max_article_score'] = graclus_100_table.at[0, 'max_article_score']
    main_table.at[i,'graclus_100_median_article_score'] = graclus_100_table.at[0, 'median_article_score']
    
    main_table.at[i,'graclus_half_mclsize_cluster_no'] = graclus_half_mclsize_cluster_no
    main_table.at[i,'graclus_half_mclsize_cluster_size'] = graclus_half_mclsize_cluster_size 
    main_table.at[i,'graclus_half_mclsize_to_mcl_ratio'] = graclus_half_mclsize_to_mcl_ratio 
    main_table.at[i,'graclus_half_mclsize_total_intersection'] = graclus_half_mclsize_total_intersection 
    main_table.at[i,'graclus_half_mclsize_total_union'] = graclus_half_mclsize_total_union 
    main_table.at[i,'graclus_half_mclsize_intersection_union_ratio'] = graclus_half_mclsize_intersection_union_ratio
    main_table.at[i,'graclus_half_mclsize_multiple_options'] = graclus_half_mclsize_multiple_options 
    
    main_table.at[i,'graclus_half_mclsize_conductance'] = graclus_half_mclsize_table.at[0, 'conductance']
    main_table.at[i,'graclus_half_mclsize_coherence'] = graclus_half_mclsize_table.at[0, 'coherence']
    main_table.at[i,'graclus_half_mclsize_int_edges'] = graclus_half_mclsize_table.at[0, 'int_edges']
    main_table.at[i,'graclus_half_mclsize_boundary'] = graclus_half_mclsize_table.at[0, 'boundary']
    main_table.at[i,'graclus_half_mclsize_sum_article_score'] = graclus_half_mclsize_table.at[0, 'sum_article_score']
    main_table.at[i,'graclus_half_mclsize_max_article_score'] = graclus_half_mclsize_table.at[0, 'max_article_score']
    main_table.at[i,'graclus_half_mclsize_median_article_score'] = graclus_half_mclsize_table.at[0, 'median_article_score']

print("Done updating table.")
main_table = main_table.astype(float)
main_table.to_sql('rated_mcl_graclus_all_data', schema=schema, con=engine, if_exists='replace', index=False)
print("All completed.")
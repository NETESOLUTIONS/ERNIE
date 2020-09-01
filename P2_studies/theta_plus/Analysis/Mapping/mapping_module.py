# ------------------------------------------------------------------------------------ #    
    
schema = "theta_plus"
sql_scheme = 'postgresql://' + "user_name" + ':' + "password" + '@localhost:5432/ernie' # ---> supply credentials
engine = create_engine(sql_scheme)
    
def match_rated_mcl_to_graclus(imm1985_1995_cluster_no, rated_data):
    
    match_year = '19' + str(rated_data.set_index('imm1985_1995_cluster_no').at[int(imm1985_1995_cluster_no), 'match_year'])
    mcl_cluster_no = rated_data.set_index('imm1985_1995_cluster_no').at[int(imm1985_1995_cluster_no), 'match_cluster_no']
    mcl_match_year = 'imm' + match_year + '_cluster_scp_list_unshuffled'
    graclus_match_year = 'imm' + match_year + '_cluster_scp_list_graclus'

    mcl_query = "SELECT * FROM theta_plus." + mcl_match_year + " AS mmy WHERE mmy.cluster_no = " + str(mcl_cluster_no) + ';'
    mcl_data = pd.read_sql(mcl_query, con=engine)
    mcl_cluster_size = len(mcl_data)
    common_nodes = mcl_data['scp'].to_list()
    graclus_query = "SELECT * FROM theta_plus." + graclus_match_year + ';'
    graclus_data = pd.read_sql(graclus_query, con=engine)

    common_graclus_clusters = list(set(graclus_data['cluster_no'][graclus_data['scp'].isin(common_nodes)].to_list()))
    merged_data_intersect = mcl_data[['scp']].merge(graclus_data[graclus_data['cluster_no'].isin(common_graclus_clusters)], how='inner')
    total_in_graclus = len(merged_data_intersect)
    grouped_merged_data_intersect = merged_data_intersect.groupby(by='cluster_no', as_index=False).agg('count')
    max_match_count = grouped_merged_data_intersect['scp'].max()
    
    graclus_cluster_no = grouped_merged_data_intersect.set_index('scp').at[max_match_count, 'cluster_no']
    graclus_cluster_size = len(graclus_data[graclus_data['cluster_no'] == graclus_cluster_no])
    
    graclus_to_mcl_ratio = round(graclus_cluster_size/mcl_cluster_size, 3)
    
    graclus_cluster_query = "SELECT * FROM theta_plus." + graclus_match_year + " AS mmy WHERE mmy.cluster_no = " + str(graclus_cluster_no) + ';'
    graclus_cluster_data = pd.read_sql(graclus_cluster_query, con=engine)
    
    merged_data_union = mcl_data[['scp']].merge(graclus_cluster_data[['scp']], how='outer')
    intersect_check = max_match_count == len(mcl_data[['scp']].merge(graclus_cluster_data[['scp']], how='inner'))
    

    result_dict = {'imm1985_1995_cluster_no': int(imm1985_1995_cluster_no), 
                   'match_year': match_year, 
                   'mcl_cluster_no': mcl_cluster_no, 
                   'mcl_cluster_size': mcl_cluster_size,
                   'graclus_cluster_no': graclus_cluster_no, 
                   'graclus_cluster_size' : graclus_cluster_size,
                   'graclus_to_mcl_ratio': graclus_to_mcl_ratio,
                   'total_in_graclus': total_in_graclus, 
                   'total_intersection': max_match_count,
                   'total_union': len(merged_data_union),
                   'intersect_union_ratio': max_match_count/len(merged_data_union),
                   'intersect_check': intersect_check
                   }
    
    return result_dict



# ------------------------------------------------------------------------------------ #    

def match_superset_year(current_cluster_no, current_year, compare_year, current_year_name, compare_year_name):

        current_cluster_size = len(current_year[current_year["cluster_no"]==current_cluster_no])

        current_grouped = current_year[current_year['cluster_no']==current_cluster_no].merge(compare_year, 
                                                          left_on = 'scp', 
                                                          right_on = 'scp', 
                                                          how='inner')[['cluster_no_y', 'scp']].groupby('cluster_no_y', as_index = False).agg('count')
        current_total_intersection = current_grouped["scp"].sum()
        current_max_count = current_grouped["scp"].max()
        current_max_prop = round(current_max_count/current_cluster_size, 3)

        if (current_total_intersection > 0):#and max_prop >= 0.4:
            compare_cluster_no = current_grouped["cluster_no_y"][current_grouped["scp"] == current_max_count].values[0]
            compare_cluster_size = len(compare_year[compare_year["cluster_no"]==compare_cluster_no])
            compare_max_prop = round(current_max_count/compare_cluster_size, 3)
        else:
            compare_cluster_no = None
            compare_cluster_size = None
            compare_max_prop = None

        current_cluster_number_key = current_year_name + '_cluster_number'
        current_cluster_size_key = current_year_name + '_cluster_size'
        compare_cluster_number_key = compare_year_name + '_cluster_number'
        compare_cluster_prop_key = compare_year_name+ '_max_prop'
        compare_cluster_size_key = compare_year_name+ '_cluster_size'
        compare_to_current_cluster_prop_key = compare_year_name + '_' + current_year_name + '_max_prop'

        match_dict = {
                'current_year': current_year_name,
                current_cluster_number_key: current_cluster_no,
                current_cluster_size_key: current_cluster_size,
                compare_cluster_number_key: compare_cluster_no,
                compare_cluster_size_key: compare_cluster_size,
                compare_cluster_prop_key: current_max_prop,
                compare_to_current_cluster_prop_key: compare_max_prop
                        }

        return match_dict
    
    
# ------------------------------------------------------------------------------------ #    
    
    
def match_mcl_to_graclus(dir_name, cluster_num):
    
    mcl_data_query = "SELECT * FROM theta_plus." + dir_name + "_cluster_scp_list_unshuffled WHERE cluster_no = " + str(cluster_num) + ";"
    mcl_data = pd.read_sql(mcl_data_query, con=engine)
    mcl_cluster_size = len(mcl_data)
    common_nodes = mcl_data['scp'].to_list()
    graclus_query = "SELECT * FROM theta_plus." + dir_name + '_cluster_scp_list_graclus;'
    graclus_data = pd.read_sql(graclus_query, con=engine)

    common_graclus_clusters = list(set(graclus_data['cluster_no'][graclus_data['scp'].isin(common_nodes)].to_list()))
    merged_data_intersect = mcl_data[['scp']].merge(graclus_data[graclus_data['cluster_no'].isin(common_graclus_clusters)], how='inner')

    grouped_merged_data_intersect = merged_data_intersect.groupby(by='cluster_no', as_index=False).agg('count')
    max_match_count = int(grouped_merged_data_intersect['scp'].max())

    graclus_cluster_no = grouped_merged_data_intersect.set_index('scp').at[max_match_count, 'cluster_no']
    if type(graclus_cluster_no) == np.int64:
        graclus_cluster_size = len(graclus_data[graclus_data['cluster_no'] == graclus_cluster_no])
        indicator = 0
    elif type(graclus_cluster_no) == np.ndarray:
        graclus_cluster_no = graclus_cluster_no[0]
        graclus_cluster_size = len(graclus_data[graclus_data['cluster_no'] == graclus_cluster_no])
        indicator = 1

    graclus_to_mcl_ratio = round(graclus_cluster_size/mcl_cluster_size, 3)

    graclus_cluster_query = "SELECT * FROM theta_plus." + dir_name + "_cluster_scp_list_graclus WHERE cluster_no = " + str(graclus_cluster_no) + ";"
    graclus_cluster_data = pd.read_sql(graclus_cluster_query, con=engine)

    merged_data_union = mcl_data[['scp']].merge(graclus_cluster_data[['scp']], how='outer')
        
    result_dict = {'mcl_cluster_no': int(cluster_num), 
                   'mcl_cluster_size': int(mcl_cluster_size),
                   'graclus_cluster_no': int(graclus_cluster_no), 
                   'graclus_cluster_size' : int(graclus_cluster_size),
                   'graclus_to_mcl_ratio': graclus_to_mcl_ratio,
                   'total_intersection': max_match_count,
                   'total_union': len(merged_data_union),
                   'intersect_union_ratio': round(max_match_count/len(merged_data_union), 4),
                   'multiple_options': indicator
                   }

    return result_dict


# ------------------------------------------------------------------------------------ #    
    
    
def match_mcl_to_enriched(dir_name, cluster_num):
    
    mcl_data_query = "SELECT * FROM theta_plus." + dir_name + "_cluster_scp_list_unshuffled WHERE cluster_no = " + str(cluster_num) + ";"
    mcl_data = pd.read_sql(mcl_data_query, con=engine)
    mcl_cluster_size = len(mcl_data)
    common_nodes = mcl_data['scp'].to_list()
    enriched_query = "SELECT * FROM theta_plus." + dir_name + '_enriched_cluster_scp_list_unshuffled;'
    enriched_data = pd.read_sql(enriched_query, con=engine)

    common_enriched_clusters = list(set(enriched_data['cluster_no'][enriched_data['scp'].isin(common_nodes)].to_list()))
    merged_data_intersect = mcl_data[['scp']].merge(enriched_data[enriched_data['cluster_no'].isin(common_enriched_clusters)], how='inner')

    grouped_merged_data_intersect = merged_data_intersect.groupby(by='cluster_no', as_index=False).agg('count')
    max_match_count = int(grouped_merged_data_intersect['scp'].max())

    enriched_cluster_no = grouped_merged_data_intersect.set_index('scp').at[max_match_count, 'cluster_no']
    if type(enriched_cluster_no) == np.int64:
        enriched_cluster_size = len(enriched_data[enriched_data['cluster_no'] == enriched_cluster_no])
        indicator = 0
    elif type(enriched_cluster_no) == np.ndarray:
        enriched_cluster_no = enriched_cluster_no[0]
        enriched_cluster_size = len(enriched_data[enriched_data['cluster_no'] == enriched_cluster_no])
        indicator = 1

    enriched_to_mcl_ratio = round(enriched_cluster_size/mcl_cluster_size, 3)

    enriched_cluster_query = "SELECT * FROM theta_plus." + dir_name + "_enriched_cluster_scp_list_unshuffled WHERE cluster_no = " + str(enriched_cluster_no) + ";"
    enriched_cluster_data = pd.read_sql(enriched_cluster_query, con=engine)

    merged_data_union = mcl_data[['scp']].merge(enriched_cluster_data[['scp']], how='outer')
        
    result_dict = {'mcl_cluster_no': int(cluster_num), 
                   'mcl_cluster_size': int(mcl_cluster_size),
                   'enriched_cluster_no': int(enriched_cluster_no), 
                   'enriched_cluster_size' : int(enriched_cluster_size),
                   'enriched_to_mcl_ratio': enriched_to_mcl_ratio,
                   'total_intersection': max_match_count,
                   'total_union': len(merged_data_union),
                   'intersect_union_ratio': round(max_match_count/len(merged_data_union), 4),
                   'multiple_options': indicator
                   }

    return result_dict
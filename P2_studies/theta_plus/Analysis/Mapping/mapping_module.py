from sqlalchemy import create_engine
import pandas as pd
import numpy as np

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

def match_superset_year(superset_cluster_no, superset, compare_year, superset_name, compare_year_name):
    
    superset_cluster = superset[superset["cluster_no"]==superset_cluster_no]
    superset_cluster_size = len(superset_cluster)
    superset_cluster = superset_cluster.rename(columns={'cluster_no':'superset_cluster_no'})
    compare_year = compare_year.rename(columns={'cluster_no':'compare_cluster_no'})
    superset_grouped = superset_cluster[['scp']].merge(compare_year, 
                                              left_on = 'scp', 
                                              right_on = 'scp', 
                                              how='inner').groupby('compare_cluster_no', as_index = False).agg('count')

    if len(superset_grouped) > 0:
        superset_nodes_found = superset_grouped["scp"].sum()
        superset_max_count = superset_grouped["scp"].max()

        # Proportion of nodes in the superset cluster that are found in the best-matching 
        # compare year cluster
        superset_max_overlap_prop = round(superset_max_count/superset_cluster_size, 4)

        compare_cluster_no = superset_grouped.set_index('scp').at[superset_max_count, 'compare_cluster_no']
        if type(compare_cluster_no) == np.ndarray:
            compare_cluster_no = compare_cluster_no[0] # Choosing the first cluster that matches
            indicator = 1 # More than one best-matching option
        elif type(compare_cluster_no) == np.int64:
            indicator = 0 # Only one best-matching option

        compare_cluster = compare_year[compare_year["compare_cluster_no"]==compare_cluster_no]
        compare_cluster_size = len(compare_cluster)

        total_intersection = len(superset_cluster.merge(compare_cluster, left_on='scp', right_on='scp', how='inner'))
        total_union = len(superset_cluster.merge(compare_cluster, left_on='scp', right_on='scp', how='outer'))
        intersect_union_ratio = round(total_intersection/total_union, 4)

    else:
        superset_nodes_found = None
        superset_max_count = None
        superset_max_overlap_prop = None
        compare_cluster_no = None
        compare_cluster_size = None
        total_intersection = None
        total_union = None
        intersect_union_ratio = None
        indicator = None        

    superset_cluster_number_key = superset_name + '_cluster_number'
    superset_cluster_size_key = superset_name + '_cluster_size'
    compare_cluster_number_key = compare_year_name + '_cluster_number'
    compare_cluster_size_key = compare_year_name + '_cluster_size'
    compare_superset_nodes_found_key = compare_year_name + '_superset_nodes_found'
    compare_cluster_max_overlap_prop_key = compare_year_name + '_max_overlap_prop'
    compare_cluster_intersection_key = compare_year_name + '_intersection'
    compare_cluster_union_key = compare_year_name + '_union'
    compare_cluster_intersect_union_ratio_key = compare_year_name + '_intersect_union_ratio'
    
#     nonlocal superset_max_overlap_prop # mitigate UnboundLocalError
    match_dict = {
            'superset': superset_name,
            superset_cluster_number_key: superset_cluster_no,
            superset_cluster_size_key: superset_cluster_size,
            compare_cluster_number_key: compare_cluster_no,
            compare_cluster_size_key: compare_cluster_size,
            compare_superset_nodes_found_key: superset_nodes_found,
            compare_cluster_max_overlap_prop_key: superset_max_overlap_prop,
            compare_cluster_intersection_key: total_intersection,
            compare_cluster_union_key: total_union,
            compare_cluster_intersect_union_ratio_key: intersect_union_ratio,
            'multiple_options': indicator}

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

# ------------------------------------------------------------------------------------ #    

def match_mcl_to_leiden(mcl_cluster_no, mcl, leiden):

    mcl_cluster = mcl[mcl["cluster_no"]==mcl_cluster_no]
    mcl_cluster_size = len(mcl_cluster)
    mcl_cluster = mcl_cluster.rename(columns={'cluster_no':'mcl_cluster_no'})
    leiden = leiden.rename(columns={'cluster_no':'leiden_cluster_no'})
    mcl_grouped = mcl_cluster[['scp']].merge(leiden, 
                                              left_on = 'scp', 
                                              right_on = 'scp', 
                                              how='inner').groupby('leiden_cluster_no', as_index = False).agg('count')

    if len(mcl_grouped) > 0:
        mcl_max_count = mcl_grouped["scp"].max()

        # Proportion of nodes in the mcl cluster that are found in the best-matching 
        # leiden cluster
        mcl_max_overlap_prop = round(mcl_max_count/mcl_cluster_size, 4)

        leiden_cluster_no = mcl_grouped.set_index('scp').at[mcl_max_count, 'leiden_cluster_no']
        if type(leiden_cluster_no) == np.ndarray:
            leiden_cluster_no = leiden_cluster_no[0] # Choosing the first cluster that matches
            indicator = 1 # More than one best-matching option
        elif type(leiden_cluster_no) == np.int64:
            indicator = 0 # Only one best-matching option

        leiden_cluster = leiden[leiden["leiden_cluster_no"]==leiden_cluster_no]
        leiden_cluster_size = len(leiden_cluster)

        total_intersection = len(mcl_cluster.merge(leiden_cluster, left_on='scp', right_on='scp', how='inner'))
        total_union = len(mcl_cluster.merge(leiden_cluster, left_on='scp', right_on='scp', how='outer'))
        intersect_union_ratio = round(total_intersection/total_union, 4)

    else:
        mcl_max_count = None
        mcl_max_overlap_prop = None
        leiden_cluster_no = None
        leiden_cluster_size = None
        total_intersection = None
        total_union = None
        intersect_union_ratio = None
        indicator = None        
    
    match_dict = {
            'mcl_cluster_number': mcl_cluster_no,
            'mcl_cluster_size': mcl_cluster_size,
            'leiden_cluster_number': leiden_cluster_no,
            'leiden_cluster_size': leiden_cluster_size,
            'leiden_cluster_max_overlap_prop': mcl_max_overlap_prop,
            'total_intersection': total_intersection,
            'total_union': total_union,
            'intersect_union_ratio': intersect_union_ratio,
            'multiple_options': indicator}

    return match_dict
    
# ------------------------------------------------------------------------------------ #    
    
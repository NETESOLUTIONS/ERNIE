import pandas as pd
import mapping_module as mm
import multiprocessing as mp
from sqlalchemy import create_engine
from sys import argv

user_name = argv[1]
password = argv[2]
data_type = argv[3]
start_year = int(argv[4])
end_year = int(argv[5])
rootdir = "/erniedev_data3/theta_plus/" + data_type + "_output"
schema = "theta_plus"
sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)

year_names_list = []
for year in range(start_year, end_year+1):
    name = data_type + str(year)
    year_names_list.append(name)

year_list = []

superset_name = data_type + str(start_year) + '_' + str(end_year)
superset_cluster_scp_table = superset_name + '_cluster_scp_list_unshuffled'

superset = pd.read_sql_table(table_name=superset_cluster_scp_table, schema=schema, con=engine)

for i in range(len(year_names_list)):
    table_name = year_names_list[i] + '_cluster_scp_list_unshuffled'
    year_list.append(pd.read_sql_table(table_name=table_name, schema=schema, con=engine))
    year_list[i].name = year_names_list[i]

p = mp.Pool(6)    
for compare_year in year_list[:1]:
    final_df = pd.DataFrame()
    print(f'Working on {compare_year.name}')
    for superset_cluster_no in range(1, len(superset)):

        match_dict = p.starmap(mm.match_superset_year, [(superset_cluster_no, superset, compare_year, superset_name, compare_year.name)])
        match_df = pd.DataFrame.from_dict(match_dict)
        final_df = final_df.append(match_df, ignore_index=True)
    
    save_name = rootdir + '/' + superset_name + '/match_to_' + compare_year.name + '.csv'
    final_df.to_csv(save_name, index = None, header=True, encoding='utf-8')
    
    # In case the connection times out:
    engine = create_engine(sql_scheme)
    save_name_sql = compare_year.name + '_superset_match'
    final_df.to_sql(save_name_sql, con=engine, schema=schema, index=False, if_exists='fail')
    print(f'{compare_year.name} completed.')
    print("")
print("All Completed.")    
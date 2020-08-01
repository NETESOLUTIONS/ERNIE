import pandas as pd
import jsd_modules as jm
import multiprocessing as mp
from sqlalchemy import create_engine
from sys import argv

user_name = argv[1]
password = argv[2]
rootdir = "/erniedev_data3/theta_plus/imm_output"
schema = "theta_plus"
sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)

year_names_list = ['imm1985','imm1986','imm1987','imm1988','imm1989','imm1990',
                   'imm1991','imm1992','imm1993','imm1994','imm1995']

year_list = []

current_year = pd.read_sql_table(table_name='imm1985_1995_cluster_scp_list_unshuffled', 
                                 schema=schema, con=engine)
current_year.name = 'imm1985_1995'   

for i in range(len(year_names_list)):
    table_name = year_names_list[i] + '_cluster_scp_list_unshuffled'
    year_list.append(pd.read_sql_table(table_name=table_name, schema=schema, con=engine))
    name = 'imm19' + str(85+i) # ---> year starts from 1985
    year_list[i].name = name

p = mp.Pool(6)    
for compare_year in year_list[:1]:
    final_df = pd.DataFrame()
    print(f'Working on {compare_year.name}')
    for current_cluster_no in range(1, len(current_year)):
        print(current_cluster_no)
        match_dict = p.starmap(jm.match_superset_year, [(current_cluster_no, current_year, compare_year, current_year.name, compare_year.name)])
        match_df = pd.DataFrame.from_dict(match_dict)
        final_df = final_df.append(match_df, ignore_index=True)
        
    save_name = rootdir + '/imm1985_1995/match_to_' + compare_year.name + '.csv'
    final_df.to_csv(save_name, index = None, header=True, encoding='utf-8')
    # In case the connection times out:
    engine = create_engine(sql_scheme)
    save_name_sql = compare_year.name + '_superset_match'
    final_df.to_sql(save_name_sql, con=engine, schema=schema, index=False, if_exists='fail')
    print(f'{compare_year.name} completed.')
    print("")
print("All Completed.")    
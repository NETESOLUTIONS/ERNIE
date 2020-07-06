#!/usr/bin/env python3

"""
@author: Shreya Chandrasekharan

This script includes any ad hoc scripts written for theta_plus
"""

# Finding the intersection/union between all 11 years

import pandas as pd
from glob import glob


year_list = []

for file_name in glob('dump.*.mci.I20.csv'):
    if len(file_name) == 37:
        vars()[file_name[5:12]] = pd.read_csv(file_name)
        year_list.append(vars()[file_name[5:12]])
    elif len(file_name) == 42: # ---> imm1985_1995
        vars()[file_name[5:17]] = pd.read_csv(file_name) # ---> Not appending to year_list

for i in range(len(year_list)):
    name = 'imm' + str(85+i)
    year_list[i].name = name

imm1985_1995.name = 'imm85_95'  

# Intersection/Union as absolute values
df = pd.DataFrame(columns = [i.name for i in year_list], index = [i.name for i in year_list])
for i in year_list:
    for j in year_list:
        intersection = len(i.merge(j, left_on = 'scp', right_on = 'scp', how = 'inner'))
        union = len(i.merge(j, left_on = 'scp', right_on = 'scp', how = 'outer'))
        
        df[i.name][j.name] = (intersection,union)
        
# Intersection as a percentage of union
df2 = pd.DataFrame(columns = [i.name for i in year_list], index = [i.name for i in year_list])
for i in year_list:
    for j in year_list:

        df2[i.name][j.name] = df[i.name][j.name][0]/df[i.name][j.name][1]
        
        
# Altering existing table names        
        
import psycopg2
conn=psycopg2.connect(database="ernie",user="shreya",host="localhost",password="Akshay<3")
conn.set_client_encoding('UTF8')
conn.autocommit=True
curs=conn.cursor()
schema = 'theta_plus'
curs.execute("SET SEARCH_PATH TO theta_plus;")

cluster_type = "graclus" # ---> unshuffled/graclus


tmp_dir_list = ['imm1985','imm1986', 'imm1987', 'imm1988', 'imm1989', 'imm1990',
                'imm1991', 'imm1992', 'imm1993', 'imm1994', 'imm1995', 'imm1985_1995']

for dir_name in tmp_dir_list:
    table_name = dir_name + "_edge_list_" + cluster_type
    new_table_name = dir_name + "_cluster_scp_list_" + cluster_type
    query = 'ALTER TABLE IF EXISTS ' + table_name + ' RENAME TO ' + new_table_name + ';'
    curs.execute(query)
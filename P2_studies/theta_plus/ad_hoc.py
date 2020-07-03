#!/usr/bin/env python3

"""
@author: Shreya Chandrasekharan

This script includes any ad hoc computation used for theta_plus
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
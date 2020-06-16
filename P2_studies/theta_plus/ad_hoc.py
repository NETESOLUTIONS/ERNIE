
# Finding the intersection/union between all 11 years

import pandas as pd

imm85 = pd.read_csv("dump.imm1985_citing_cited.mci.I20.csv")
imm86 = pd.read_csv("dump.imm1986_citing_cited.mci.I20.csv")
imm87 = pd.read_csv("dump.imm1987_citing_cited.mci.I20.csv")
imm88 = pd.read_csv("dump.imm1988_citing_cited.mci.I20.csv")
imm89 = pd.read_csv("dump.imm1989_citing_cited.mci.I20.csv")
imm90 = pd.read_csv("dump.imm1990_citing_cited.mci.I20.csv")
imm91 = pd.read_csv("dump.imm1991_citing_cited.mci.I20.csv")
imm92 = pd.read_csv("dump.imm1992_citing_cited.mci.I20.csv")
imm93 = pd.read_csv("dump.imm1993_citing_cited.mci.I20.csv")
imm94 = pd.read_csv("dump.imm1994_citing_cited.mci.I20.csv")
imm95 = pd.read_csv("dump.imm1995_citing_cited.mci.I20.csv")
imm85_95 = pd.read_csv("dump.imm1985_1995_citing_cited.mci.I20.csv")

year_list = [imm85,imm86,imm87,imm88,imm89,imm90,imm91,imm92,imm93,imm94,imm95]
name_list = []
for i in range(len(year_list)):
    name = 'imm' + str(85+i)
    year_list[i].name = name
    name_list.append(name)
imm85_95.name = 'imm85_95'    

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
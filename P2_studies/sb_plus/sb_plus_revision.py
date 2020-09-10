#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import numpy as np


# ### Connect to Postgres

# In[2]:


import psycopg2
conn=psycopg2.connect(database="ernie",user="wenxi",host="localhost",password="temp_ERNIE_1234")
conn.set_client_encoding('UTF8')
conn.autocommit=True
curs=conn.cursor()


# In[3]:


curs.execute("SET SEARCH_PATH TO sb_plus;")


# In[4]:


df = pd.read_sql('SELECT * FROM sb_plus_complete_kinetics', conn)


# In[5]:


# Sort dataframe by cited_1, cited_2, co_cited_year and reset index to make sure the table is correct

df = df.sort_values(['cited_1', 'cited_2', 'co_cited_year'])
df = df.reset_index().drop(columns='index')


# In[271]:


df


# ### Filling in missing years between first_possible_year and last_co_cited_year

# In[7]:


# Distinct pairs
pairs = pd.DataFrame(df.groupby(['cited_1','cited_2']).size()).reset_index().drop(columns=0)
pairs


# In[8]:


# number of pairs that have to fillin first year

len(pairs) - len(df[df['first_possible_year'] == df['co_cited_year']].groupby(['cited_1','cited_2']).size())


# In[9]:


x1 = pd.DataFrame(df.groupby(['cited_1','cited_2', 'first_possible_year'])['co_cited_year'].min()).reset_index()
x1


# In[10]:


# add first row for pairs that first_possible_year is not equal to co_cited_year

l = list([x1['cited_1'], x1['cited_2'], x1['co_cited_year'], x1['first_possible_year']])

l_new = [[],[],[],[]]

for i in range(len(l[0])):
    if l[2][i] > l[3][i]:
        l_new[0].append(l[0][i])
        l_new[1].append(l[1][i])
        l_new[2].append(l[3][i])
        l_new[3].append(l[3][i])


# In[11]:


x2 = pd.DataFrame({'cited_1':l_new[0], 'cited_2':l_new[1], 'co_cited_year':l_new[2], 'first_possible_year':l_new[3]})
x2


# In[12]:


x3 = pd.concat([df, x2], axis=0)
x3


# In[13]:


# Fill in zeros for frequency, next values for all other columns, and sort values by co_cited_year and reset index

x3 = x3.sort_values(['cited_1','cited_2','co_cited_year']).reset_index().drop(columns='index')
x3['frequency'] = x3['frequency'].fillna(0)
x3 = x3.fillna(method='bfill')


# In[14]:


x3


# In[15]:


# Double check the number of pairs is correct

len(x3.groupby(['cited_1','cited_2']).size())


# In[16]:


# Double check all first_possible_year is filled in as the first co_cited_year

len(x3[x3['first_possible_year'] == x3['co_cited_year']])


# In[17]:


l = list([x3['cited_1'], x3['cited_2'], x3['co_cited_year']])


# In[89]:


# Fill in all missing years 
import timeit 

start = timeit.default_timer()

l_new = [[],[],[]]

for i in range(len(l[0])-1):
    if (l[0][i] == l[0][i+1]) & (l[1][i] == l[1][i+1]):
        if l[2][i+1] - l[2][i] > 1:
            l_new[0].append(l[0][i])
            l_new[1].append(l[1][i])
            l_new[2].append(l[2][i])
            for j in range(1, (l[2][i+1] - l[2][i])):
                l_new[0].append(l[0][i])
                l_new[1].append(l[1][i])
                l_new[2].append(l[2][i]+j)

        else:
            l_new[0].append(l[0][i])
            l_new[1].append(l[1][i])
            l_new[2].append(l[2][i])
        
    else:
        l_new[0].append(l[0][i])
        l_new[1].append(l[1][i])
        l_new[2].append(l[2][i])
        
l_new[0].append(l[0][len(l[0])-1])
l_new[1].append(l[1][len(l[0])-1])
l_new[2].append(l[2][len(l[0])-1])

stop = timeit.default_timer()


# In[90]:


# How long it takes to finish filling in missing years

print(stop-start)

# 227s for 51,613 pairs 


# In[91]:


# The number of rows increased because all missing years have been appended
len(l_new[2])


# In[92]:


df_new = pd.DataFrame({'cited_1':l_new[0], 'cited_2':l_new[1], 'co_cited_year':l_new[2]})


# In[93]:


df_new2 = df_new.merge(x3, how='left', on=['cited_1', 'cited_2', 'co_cited_year'])


# In[94]:


# Fill in zeros for frequency

df_new2['frequency'] = df_new2['frequency'].fillna(0)


# In[95]:


# Forward fill in values for all other columns

df_new2 = df_new2.fillna(method='ffill')


# In[96]:


df_new2


# In[97]:


# Recalculate the min_frequency for all pairs since filling missing years will change the min_frequency to be 0

df_new3 = pd.DataFrame(df_new2.groupby(['cited_1', 'cited_2'])['frequency'].min()).reset_index()

x_new = df_new3.merge(df_new2, how='left', on=['cited_1','cited_2']).drop(columns='min_frequency').rename(columns={'frequency_x':'min_frequency','frequency_y':'frequency'})


# In[98]:


x_new


# ### Find Sleeping Beauty Pairs
# 
# (1)  Minimum sleeping duration = 10 starting from the first_possible_year
# 
# (2)  During sleeping duration the average co-citation frequency <= 1 and each year co-citation frequency <= 2
# 
# (3)  Calculate the slope between the first year after sleeping duration and the first peak year 
# 
# (4)  Calculate B_index on pairs 

# In[99]:


# Calculate B_index on 51,613 Pairs

x_new


# In[100]:


# add a column of first_possible_year_frequency

pub_freq = x_new[['cited_1', 'cited_2','frequency']][x_new['co_cited_year'] == x_new['first_possible_year']].rename(columns={'frequency':'pub_year_frequency'})

x_new = x_new.merge(pub_freq, how='left', on=['cited_1', 'cited_2'])


# In[101]:


# add a column of max{1, ct}

x_new['max_1_ct'] = np.where(x_new['frequency'] > 1, x_new['frequency'], 1)


# In[102]:


# Calculate b index based on x_new's equation

x_new['b_index'] = (((x_new['max_frequency'] - x_new['pub_year_frequency'])/(x_new['peak_year'] - x_new['first_possible_year'])) * (x_new['co_cited_year'] - x_new['first_possible_year']) + x_new['pub_year_frequency'] - x_new['frequency'])/(x_new['max_1_ct'])


# In[103]:


# Sum across years until peak_year

sb_index = pd.DataFrame(x_new[x_new['co_cited_year'] <= x_new['peak_year']].groupby(['cited_1','cited_2'])['b_index'].sum())
sb_index = sb_index.sort_values('b_index', ascending=False).reset_index()


# In[104]:


sb_index


# In[105]:


# Statistical summary of b_index for all pairs

sb_index['b_index'].describe()


# In[106]:


# Extract sb pairs by applying van Raan's conditions

import warnings 
warnings.filterwarnings('ignore')

start = timeit.default_timer()

z = pd.DataFrame(columns=x_new.columns)

for i in range(len(pairs)):
    g = x_new[(x_new['cited_1'] == pairs['cited_1'][i]) & (x_new['cited_2'] == pairs['cited_2'][i])]
    g = g.reset_index().drop(columns='index')
    
    g['awake_year_index'] = ''
    
    if g.index[g['frequency'] > 2].min() >= 10:
        g['awake_year_index'][g.index[g['frequency'] > 2].min()] = 1
        if g[0:g.index[g['frequency'] > 2].min()]['frequency'].mean() <= 1:
            z = pd.concat([z,g], ignore_index=True)
            
stop = timeit.default_timer()


# In[107]:


# How long it takes to find sb pairs 

print(stop-start)

# 341s for 51,613 pairs 


# In[108]:


z1 = z.copy()


# In[109]:


z1


# In[110]:


# Number of pairs that satisfy our stringent conditions for being identified as sleeping beauty co-citation pairs

pairs1 = pd.DataFrame(z1.groupby(['cited_1','cited_2']).size()).reset_index().drop(columns=0)
pairs1


# In[111]:


#zz1 = pd.DataFrame(z1.groupby(['cited_1','cited_2'])['frequency'].sum()).reset_index()
#zz1.to_csv('1196_pairs_frequency.csv')


# In[112]:


# Statistical summary of sb pairs extracted

ss = pairs1.merge(sb_index, how='left', on=['cited_1','cited_2']).sort_values('b_index', ascending=False).reset_index().drop(columns='index')
ss['b_index'].describe()


# In[113]:


z2 = pd.DataFrame(columns=z1.columns)

for i in range(len(pairs1)):
    g = z1[(z1['cited_1'] == pairs1['cited_1'][i]) & (z1['cited_2'] == pairs1['cited_2'][i])]
    g = g.reset_index().drop(columns='index')
    
    g['awake_year'] = ''
    g['awake_frequency'] = ''
    
    tmp1 = g.loc[g['awake_year_index'] == 1, 'co_cited_year'].iloc[0]
    tmp2 = g.loc[g['awake_year_index'] == 1, 'frequency'].iloc[0]
    
    g['awake_year'] = tmp1
    g['awake_frequency'] = tmp2
    z2 = pd.concat([z2,g], ignore_index=True)


# In[114]:


z2 = z2.drop(columns='awake_year_index')


# In[115]:


z2['awake_duration'] = z2['peak_year'] - z2['awake_year']
z2['sleep_duration'] = z2['awake_year'] - z2['first_possible_year']


# In[116]:


# Calculate slope for sb pairs

z2['slope'] = ''

for i in range(len(z2)):
    if z2['awake_duration'][i] == 0:
        z2['slope'][i] = np.nan
    else:
        z2['slope'][i] = (z2['max_frequency'][i] - z2['awake_frequency'][i])/z2['awake_duration'][i]


# In[117]:


z2


# In[118]:


# Statistic summary of column slope

zz = pd.DataFrame(z2.groupby(['cited_1','cited_2','slope'])['frequency'].sum()).sort_values('slope', ascending=False).reset_index()
zz


# In[119]:


zz['slope'].describe()


# In[120]:


#zz.to_csv('slope_frequency.csv')


# In[259]:


zz2 = pd.DataFrame(ss.merge(z2, how='outer', on=['cited_1','cited_2']).groupby(['cited_1','cited_2','max_frequency','sleep_duration'])['slope'].max()).reset_index()
zz2


# In[260]:


zz2 = zz2.merge(ss, how='left', on=['cited_1','cited_2'])
zz2.to_csv('1196_pairs_all_values.csv')


# In[137]:


intersect_sb = sb_index.merge(zz2, how='right', on=['cited_1','cited_2'])
intersect_sb


# In[143]:


len(intersect_sb[intersect_sb['b_index'] >= intersect_sb['b_index'].quantile(0.50)])


# In[150]:


#plt.plot(intersect_sb['b_index'])

plt.hist(intersect_sb['b_index'], density=True)
plt.xlabel('beauty coefficient')


# In[146]:


out = pd.DataFrame(z2.groupby(['cited_1','cited_2'])['frequency'].sum()).sort_values('frequency').reset_index()
out


# In[267]:


from sqlalchemy import create_engine

engine = create_engine('postgresql://wenxi:temp_ERNIE_1234@localhost:5432/ernie')


# In[268]:


zz2.head(0).to_sql('sb_1196_pairs_all_values', engine, if_exists='replace',index=False)


# In[270]:


import io

conn = engine.raw_connection()
cur = conn.cursor()
#cur.execute("SET SEARCH_PATH TO sb_plus;")
output = io.StringIO()
zz2.to_csv(output, sep='\t', header=False, index=False)
output.seek(0)
contents = output.getvalue()
cur.copy_from(output, 'sb_1196_pairs_all_values', null="") # null values become ''
conn.commit()


# In[127]:


#zz2 = zz2.merge(ss, how='left', on=['cited_1','cited_2'])
#zz2.to_csv('1196_pairs_all_values.csv')


# In[128]:


# Pairs with slope = NA:

z2[z2['slope'].isna()].groupby(['cited_1', 'cited_2']).size()

# 10 pairs:

# 2580      5944246702     44
# 970456    2364893        33
# 1686592   2364893        31
# 2364893   33744566767    34
# 15231889  17138283       43
# 16262898  18934508       37
# 17769362  18485995       40
# 18039087  18513290       40
# 20909036  84944438568    34
# 41906953  58149417364    39


# In[129]:


# frequency of those pairs with slope = NA
z2[z2['slope'].isna()].groupby(['cited_1', 'cited_2'])['frequency'].sum()


# In[449]:


import matplotlib.pyplot as plt

for i in range(len(pairs1)):
    g = z2[(z2['cited_1'] == pairs1['cited_1'][i]) & (z2['cited_2'] == pairs1['cited_2'][i])]
    g = g.reset_index().drop(columns='index')
    plt.title([(pairs1['cited_1'][i],pairs1['cited_2'][i]), i+1])
    plt.axvline(g['awake_year'][0])
    plt.xlabel('co_cited_year')
    plt.ylabel('frequency')
    plt.xlim(1970, 2019)
    plt.ylim(0, 50)
    plt.plot(g['co_cited_year'], g['frequency'], color='green')
    plt.axhline(y=2,linestyle='-',color='orange')
    plt.legend(['Awake Year', 'Kinetics', 'Frequency = 2'])
    plt.show()


# ### Generat Plot: 3 Sleeping Beauty Pairs Based on Slope

# In[450]:


na = pd.DataFrame(z2[z2['slope'].isna()].groupby(['cited_1', 'cited_2']).size()).drop(columns=0).reset_index()
na


# In[451]:


# Plot for sb pairs with slope = NA
for i in range(len(na)):
    g = z2[(z2['cited_1'] == na['cited_1'][i]) & (z2['cited_2'] == na['cited_2'][i])]
    g = g.reset_index().drop(columns='index')
    plt.title([(na['cited_1'][i],na['cited_2'][i])])
    plt.axvline(g['awake_year'][0])
    plt.xlabel('co_cited_year')
    plt.ylabel('frequency')
    plt.xlim(1984, 2019)
    #plt.ylim(0, 50)
    plt.plot(g['co_cited_year'], g['frequency'], color='green')
    plt.axhline(y=2,linestyle='-',color='orange')
    plt.legend(['Awake Year', 'Kinetics', 'Frequency = 2'])
    plt.show()


# In[452]:


# Plot for sb pairs with min slope

g = z2[z2['slope'] == z2['slope'].min()]
g = g.reset_index().drop(columns='index')
plt.title([(g['cited_1'][0],g['cited_2'][0])])
plt.axvline(g['awake_year'][0])
plt.xlabel('co_cited_year')
plt.ylabel('frequency')
plt.xlim(1984, 2019)
#plt.ylim(0, 50)
plt.plot(g['co_cited_year'], g['frequency'], color='green')
plt.axhline(y=2,linestyle='-',color='orange')
plt.legend(['Awake Year', 'Kinetics', 'Frequency = 2'])
plt.show()


# In[453]:


mean = pd.DataFrame(z2[(z2['slope'] <= 2.38) & (z2['slope'] >= 2.35)].groupby(['cited_1', 'cited_2']).size()).drop(columns=0).reset_index()
mean


# In[454]:


# Plot for sb pairs with mean slope

for i in range(len(mean)):
    g = z2[(z2['cited_1'] == mean['cited_1'][i]) & (z2['cited_2'] == mean['cited_2'][i])]
    g = g.reset_index().drop(columns='index')
    plt.title([(mean['cited_1'][i],mean['cited_2'][i])])
    plt.axvline(g['awake_year'][0])
    plt.xlabel('co_cited_year')
    plt.ylabel('frequency')
    plt.xlim(1984, 2019)
    #plt.ylim(0, 50)
    plt.plot(g['co_cited_year'], g['frequency'], color='green')
    plt.axhline(y=2,linestyle='-',color='orange')
    plt.legend(['Awake Year', 'Kinetics', 'Frequency = 2'])
    plt.show()


# In[258]:


ax_1 = z2[(z2['cited_1'] == 1686592) & (z2['cited_2'] == 2364893)].reset_index().drop(columns='index')
ax_2 = z2[(z2['cited_1'] == 4465903) & (z2['cited_2'] == 6073669)].reset_index().drop(columns='index')
ax_3 = z2[(z2['cited_1'] == 22465686) & (z2['cited_2'] == 22638979)].reset_index().drop(columns='index')

ax_1_awake_x = ax_1['awake_year'][0]
ax_1_awake_y = ax_1['peak_year'][0]
ax_1_peak_x = ax_1['frequency'][ax_1['awake_year'] == ax_1['co_cited_year']].item()
ax_1_peak_y = ax_1['frequency'][ax_1['peak_year'] == ax_1['co_cited_year']].item()

ax_2_awake_x = ax_2['awake_year'][0]
ax_2_awake_y = ax_2['peak_year'][0]
ax_2_peak_x = ax_2['frequency'][ax_2['awake_year'] == ax_2['co_cited_year']].item()
ax_2_peak_y = ax_2['frequency'][ax_2['peak_year'] == ax_2['co_cited_year']].item()

ax_3_awake_x = ax_3['awake_year'][0]
ax_3_awake_y = ax_3['peak_year'][0]
ax_3_peak_x = ax_3['frequency'][ax_3['awake_year'] == ax_3['co_cited_year']].item()
ax_3_peak_y = ax_3['frequency'][ax_3['peak_year'] == ax_3['co_cited_year']].item()


fig, (ax1, ax2, ax3) = plt.subplots(1,3, figsize=(12,7), sharex=True, sharey=True)
#ax1.set_title('Sleeping Beauty Pair with Largest Slope', fontsize=14)
ax1.plot(ax_1['co_cited_year'], ax_1['frequency'], color='black')
ax1.plot(ax_1['awake_year'][0], 0, marker='^', color='red')
ax1.plot([ax_1_awake_x, ax_1_awake_y], [ax_1_peak_x, ax_1_peak_y], 'blue', linestyle=':',marker='*')
ax1.axhline(y=2, linestyle='-',color='grey')
#ax1.set_xlabel('co_cited_year', fontsize=13)
#ax1.set_ylabel('frequency', fontsize=13)

#ax2.set_title('Sleeping Beauty Pair with Mean Slope', fontsize=14)
ax2.plot(ax_2['co_cited_year'], ax_2['frequency'], color='black')
ax2.plot(ax_2['awake_year'][0], 0, marker='^', color='red')
ax2.plot([ax_2_awake_x, ax_2_awake_y], [ax_2_peak_x, ax_2_peak_y], 'blue', linestyle=':',marker='*', linewidth=4.0)
ax2.axhline(y=2, linestyle='-',color='grey')
#ax2.set_xlabel('co_cited_year', fontsize=13)
#ax2.set_ylabel('frequency', fontsize=13)

#ax3.set_title('Sleeping Beauty Pair with Smal Slope', fontsize=14)
ax3.plot(ax_3['co_cited_year'], ax_3['frequency'], color='black')
ax3.plot(ax_3['awake_year'][0], 0, marker='^', color='red')
ax3.plot([ax_3_awake_x, ax_3_awake_y], [ax_3_peak_x, ax_3_peak_y], 'blue', linestyle=':',marker='*', linewidth=4.0)
ax3.axhline(y=2, linestyle='-',color='grey')
#ax3.set_xlabel('co_cited_year', fontsize=13)
#ax3.set_ylabel('frequency', fontsize=13)

fig.text(0.5, 0.06, 'co_cited_year', ha='center', fontsize=15)
fig.text(0.08, 0.5, 'frequency', va='center', rotation='vertical', fontsize=15)

#fig.tight_layout()

fig.savefig('output.png', dpi=300)
fig.savefig('output.pdf', dpi=300)
fig.savefig('output.tiff', dpi=300)


# In[456]:


#output = pd.concat([ax_1,ax_2,ax_3])
#output.to_csv('sb_plot.csv')


# ### Find a Non-Sleeping Beaty Pair

# In[457]:


kk = x_new.merge(pairs1, how='right', on=['cited_1','cited_2'])


# In[458]:


kk1 = pd.concat([kk, x_new]).drop_duplicates(keep=False)


# In[459]:


kk1_pairs = pd.DataFrame(kk1.groupby(['cited_1','cited_2']).size()).drop(columns=0).reset_index()
kk1_pairs


# In[460]:


# Select one with same scale and looks nice

g = kk1[(kk1['cited_1'] == 20896) & (kk1['cited_2'] == 33845282341)]
g = g.reset_index().drop(columns='index')
plt.title([(kk1_pairs['cited_1'][i],kk1_pairs['cited_2'][i])])
plt.xlabel('co_cited_year')
plt.ylabel('frequency')
plt.xlim(1984, 2019)
plt.ylim(0, 25)
plt.plot(g['co_cited_year'], g['frequency'], color='green')
plt.show()


# In[461]:


#g.to_csv('non_sb_plot.csv')


# ### Generat Plot: 3 Sleeping Beauty Pairs and 3 Non-Sleeping Beauty Pairs Based on Frequency

# In[462]:


# Statistical summary of total frequency for sb pairs
z2.groupby(['cited_1','cited_2'])['frequency'].sum().describe()


# In[463]:


tt = pd.DataFrame(z2.groupby(['cited_1','cited_2'])['frequency'].sum())
tt


# In[464]:


# Max total frequency

tt[tt['frequency'] == tt['frequency'].max()]


# In[465]:


max_freq = z2[(z2['cited_1'] == 16823810) & (z2['cited_2'] == 84965520932)].reset_index().drop(columns='index')


# In[466]:


# Mean total frequency
# tt['frequency'].mean() = 285.947

tt[(tt['frequency'] <= 286) & (tt['frequency'] >= 285)]


# In[467]:


mean_freq = z2[(z2['cited_1'] == 14905513) & (z2['cited_2'] == 21344602)].reset_index().drop(columns='index')


# In[468]:


# Min total frequency

tt[tt['frequency'] == tt['frequency'].min()]


# In[469]:


min_freq = z2[(z2['cited_1'] == 23020183) & (z2['cited_2'] == 25752384)].reset_index().drop(columns='index')


# In[470]:


#sb_total_frequency = pd.concat([max_freq, mean_freq, min_freq])
#sb_total_frequency.to_csv('sb_total_frequency.csv')


# In[471]:


# Statistical summary of total frequency for non-sb pairs

kk1.groupby(['cited_1','cited_2'])['frequency'].sum().describe()


# In[472]:


tt1 = pd.DataFrame(kk1.groupby(['cited_1','cited_2'])['frequency'].sum())
tt1


# In[473]:


# Max total frequency

tt1[tt1['frequency'] == tt1['frequency'].max()]


# In[474]:


max_freq1 = kk1[(kk1['cited_1'] == 189651) & (kk1['cited_2'] == 345491105)].reset_index().drop(columns='index')


# In[475]:


# Mean total frequency
# tt1['frequency'].mean() = 265.128

tt1[(tt1['frequency'] <= 265.13) & (tt1['frequency'] >= 265)]


# In[476]:


mean_freq1 = kk1[(kk1['cited_1'] == 194808) & (kk1['cited_2'] == 33744541191)].reset_index().drop(columns='index')


# In[477]:


# Min total frequency

tt1[tt1['frequency'] == tt1['frequency'].min()]


# In[478]:


min_freq1 = kk1[(kk1['cited_1'] == 24444465579) & (kk1['cited_2'] == 33744749965)].reset_index().drop(columns='index')


# In[479]:


#non_sb_total_frequency = pd.concat([max_freq1, mean_freq1, min_freq1])
#non_sb_total_frequency.to_csv('non_sb_total_frequency.csv')


# In[480]:


# g = kk1[(kk1['cited_1'] == 45149145322) & (kk1['cited_2'] == 85011817347)]
# g = g.reset_index().drop(columns='index')
# plt.xlabel('co_cited_year')
# plt.ylabel('frequency')
# plt.xlim(1975, 2019)
# #plt.ylim(0, 25)
# plt.plot(g['co_cited_year'], g['frequency'], color='green')
# plt.show()


# ### Get Individual Publications of Sb Pairs

# In[481]:


z2


# In[482]:


single_pub = pd.DataFrame(set(z2['cited_1'].unique().tolist() + z2['cited_2'].unique().tolist()))
single_pub.columns = ['cited_paper']


# In[483]:


len(single_pub)


# In[484]:


# Calculate kinetics of individual publications by Neo4j: ERNIE-Neo4j-sb-plus-kinetics-single-pub

single_pub.to_csv('single_pub.csv', index=False)


# ### Read in Kinetics of Individual Publications of Sb Pairs that Calculated by Neo4j and Do Pre-processing Step

# In[21]:


sp = pd.read_csv('single_pub_kinetics.csv')
sp


# In[22]:


len(sp.cited_paper.unique()) # double check the number of single publication is correct


# #### Filling in missing years between first year and last year

# In[23]:


# Distinct Pairs

p = pd.DataFrame(sp.groupby(['cited_paper']).size()).reset_index().drop(columns=0)


# In[24]:


p


# In[25]:


# Number of single publications that needs to fill in the first year

len(p) - len(sp[sp['year'] == sp['pub_year']])


# In[26]:


k = pd.DataFrame(sp.groupby(['cited_paper', 'pub_year'])['year'].min()).reset_index()
k


# In[27]:


k1 = list([k['cited_paper'], k['year'], k['pub_year']])


# In[28]:


# add first row for pairs that first_possible_year is not equal to co_cited_year

start = timeit.default_timer()

k_new = [[],[],[]]

for i in range(len(k1[0])):    
    if k1[1][i] > k1[2][i]:
        k_new[0].append(k1[0][i])
        k_new[1].append(k1[2][i])
        k_new[2].append(k1[2][i])

stop = timeit.default_timer()


# In[29]:


# how long it takes to fill in missing years

stop - start

# 0.04s for 1267 publications


# In[30]:


k_new2 = pd.DataFrame({'cited_paper':k_new[0], 'year':k_new[1], 'pub_year':k_new[2]})


# In[31]:


k2 = pd.concat([sp, k_new2], axis=0)
k2


# In[32]:


# Fill in zeros for frequency, and sort values by co_cited_year and reset index

k2 = k2.sort_values(['cited_paper','year']).reset_index().drop(columns='index')
k2['frequency'] = k2['frequency'].fillna(0)


# In[33]:


k2


# In[34]:


k = list([k2['cited_paper'], k2['year']])


# In[35]:


# Fikk in akk missing years 

start = timeit.default_timer()

k_new = [[],[]]

for i in range(len(k[0])-1):    
    if k[1][i+1] - k[1][i] > 1:
        k_new[0].append(k[0][i])
        k_new[1].append(k[1][i])
        for j in range(1, (k[1][i+1] - k[1][i])):
            k_new[0].append(k[0][i])
            k_new[1].append(k[1][i]+j)

    else:
        k_new[0].append(k[0][i])
        k_new[1].append(k[1][i])
        

k_new[0].append(k[0][len(k[0])-1])
k_new[1].append(k[1][len(k[0])-1])

        
stop = timeit.default_timer()


# In[36]:


# how long it takes to finish 1267 single publications

print(stop-start)

# 1.6s


# In[37]:


kk = pd.DataFrame({'cited_paper':k_new[0], 'year':k_new[1]})


# In[38]:


y = kk.merge(k2, how='left', on=['cited_paper', 'year'])


# In[39]:


# Fill in zeros for frequency

y['frequency'] = y['frequency'].fillna(0)

# Forward fill in values for all other columns

y = y.fillna(method='ffill')


# In[40]:


y


# ### Van Raan (2019) on Individual Publications:
# 
# (1) length of the sleep in years after publication (sleeping period s) >= 10
# 
# (2) depth of sleep in terms of the citation rate during the sleeping period (cs) <= 1
# 
# (3) awakening period in years after the sleeping period (a) = 5
# 
# (4) awakening citation-intensity in terms of the citation rate during the awakening period (ca) >= 5

# In[41]:


start = timeit.default_timer()

y2 = pd.DataFrame(columns=y.columns)

for i in range(len(p)):
    g = y[(y['cited_paper'] == p['cited_paper'][i])]
    g = g.reset_index().drop(columns='index')
    
    g['awake_year_index'] = ''
    
    j_max = 0
    for j in range(10, len(g)):
        if (g['frequency'][0:j].mean() <= 1) & (g['frequency'][j+1:j+5].mean() >= 5):
            j_max = j
    g['awake_year_index'][j_max] = 1
    
    if j_max != 0:
        y2 = pd.concat([y2,g], ignore_index=True)
        
stop = timeit.default_timer()


# In[42]:


# how long it takes for 1267 single publications

print(stop-start)

# 12.6s


# In[43]:


len(y2.cited_paper.unique().tolist())  # number of sb individual publications by van Raan

# len(y2.cited_paper.unique())


# In[532]:


for i in range(len(y2.cited_paper.unique().tolist())):
    g = y2[(y2['cited_paper'] == y2.cited_paper.unique().tolist()[i])]
    plt.title([p['cited_paper'][i], i+1])
    plt.axvline(g['year'][g['awake_year_index'] == 1].item())
    plt.xlabel('year')
    plt.ylabel('frequency')
    plt.xlim(1970, 2020)
    #plt.ylim(0,1000)
    plt.plot(g['year'], g['frequency'], color='green')
    plt.show()


# ### Ke et al (2015): on Individual Publications
# 
# How to calcualte B index: ![image.png](attachment:image.png)

# In[44]:


ke = y.copy()


# In[45]:


# add a column of max_frequency 

max_frequency = pd.DataFrame(y.groupby(['cited_paper'])['frequency'].max().reset_index().rename(columns={'frequency':'max_frequency'}))
ke = ke.merge(max_frequency, how='left', on='cited_paper')


# In[46]:


# add a column of peak_year

peak_year = ke[['cited_paper','year']][ke['max_frequency'] == ke['frequency']].drop_duplicates(subset=['cited_paper'], keep = 'first').rename(columns={'year':'peak_year'})
ke = ke.merge(peak_year, how='left', on='cited_paper')


# In[47]:


# add a column of pub_year_frequency

pub_freq = ke[['cited_paper','frequency']][ke['year'] == ke['pub_year']].rename(columns={'frequency':'pub_year_frequency'})
ke = ke.merge(pub_freq, how='left', on='cited_paper')


# In[48]:


# add a column of max{1, ct}

ke['max_1_ct'] = np.where(ke['frequency'] > 1, ke['frequency'], 1)


# In[49]:


# Calculate b index based on Ke's equation

ke['b_index'] = (((ke['max_frequency'] - ke['pub_year_frequency'])/(ke['peak_year'] - ke['pub_year'])) * (ke['year'] - ke['pub_year']) + ke['pub_year_frequency'] - ke['frequency'])/(ke['max_1_ct'])


# In[50]:


ke


# In[51]:


# Sum across years until peak_year

sb_index1 = pd.DataFrame(ke[ke['year'] <= ke['peak_year']].groupby(['cited_paper'])['b_index'].sum())
sb_index1 = sb_index1.sort_values('b_index', ascending=False).reset_index()


# In[52]:


# Statistic summary

sb_index1['b_index'].describe()


# In[53]:


sb_index2 = sb_index1.merge(pd.DataFrame(ke.groupby(['cited_paper'])['frequency'].sum()).reset_index(), how = 'left', on='cited_paper')


# In[54]:


sb_index2


# In[55]:


sb_index2['frequency'].describe()


# In[56]:


#sb_index2.to_csv('single_sb_freq_bindex.csv')


# In[71]:


y.groupby(['cited_paper']).size()


# In[77]:


import matplotlib.pyplot as plt


for i in range(len(sb_index2)):
    g = y[(y['cited_paper'] == sb_index2['cited_paper'][i])]
    plt.title([sb_index2['cited_paper'][i], sb_index2['b_index'][i]])
    #plt.axvline(g['year'][g['awake_year_index'] == 1].item())
    plt.xlabel('year')
    plt.ylabel('frequency')
    plt.xlim(1970, 2020)
    #plt.ylim(0,1000)
    plt.plot(g['year'], g['frequency'], color='green')
    plt.show()


# ### Exploration of b_index between individual publications and pairs

# In[79]:


# Range of B_index of 100 sb individual publications by van Raan is very large 

sb_range = []

for i in range(len(sb_index1)):
    if sb_index1['cited_paper'][i] in y2.cited_paper.unique().tolist():
        sb_range.append(sb_index1['b_index'][i])
    


# In[80]:


import statistics

statistics.median(sb_range)

np.quantile(sb_range, 0.75)


# In[84]:


len(sb_range)


# In[ ]:





# -*- coding: utf-8 -*-
"""
Created on Tue Feb 19 08:16:45 2019

@author: jrbrad
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.metrics import confusion_matrix
import seaborn as sns
from matplotlib.backends.backend_pdf import PdfPages

""" Functions to be used with pandas DataFrame and Series objects to create categorical columns """
def classMe(x):
    if x < 0:
        return 'negative'
    else:
        return 'positive'

def classMeSwitch(x):
    if x['zClassImm'] == x['zClassWos']:
        return 'same'
    else:
        return 'switch'

def codeMe(row,z1,z2):
    if (row[z1] <= 0 and row[z2] <= 0) or (row[z1] >= 0 and row[z2] >= 0):
        return 'p' 
    else:
        return 'n' 

""" Functions to create RGB/color codes coding for red and black points """
def colorMe(row,z1,z2):
    if (row[z1] <= 0 and row[z2] <= 0) or (row[z1] >= 0 and row[z2] >= 0):
        return [0,0,0] # black
    else:
        return [1,0,0] # red

def colorMe1(row,z1,z2):
    #if (row['z_scores_imm95'] <= 0 and row['z_scores_d1000_95'] <= 0) or (row['z_scores_imm95'] >= 0 and row['z_scores_d1000_95'] >= 0):
    if (row[z1] <= 0 and row[z2] <= 0) or (row[z1] >= 0 and row[z2] >= 0):
        return 'black' 
    else:
        return 'red' 

server = False  # paramater for local debugging or production runs on a server
file = 1        # parameter for choosing which file to plot from local files

""" Format for data file: representing journal pairs in the first column and 
    z-scores for two data sets in the second and third columns
    
journal_pairs,z_scores_imm95,z_scores_d1000_95
"0,1",2.89243909160506,-16.2398938593776
"0,2",-0.190110233423169,-40.0147955211887
"1,2",-1.17644747816556,-19.7631661968318
"1,3",-1.04672881674971,-23.3909309788171
"""
if server:
    df = pd.read_csv('path_to_csv_file_with_z-score_data')
else:
    if file == 1 :
        df = pd.read_csv('path_to_csv_file_with_z-score_data') # file 1
        """ Change the graph parameters below as is appropriate """
        zField1 = 'z_scores_imm95'
        zField2 = 'z_scores_d1000_95'
        xLabel = 'Immunology 1995\nJournal Pair z-scores'
        yLabel = 'WoS 1995 Journal\nPair z-scores'
        xLabel = 'Imm95 Journal Pair z-scores'
        yLabel = 'WoS95 Journal Pair z-scores'
    if file == 2:
        df = pd.read_csv('path_to_csv_file_with_z-score_data') # file 2
        """ Change the graph parameters below as is appropriate """
        zField1 = 'z_scores_imm85'
        zField2 = 'z_scores_d1000_85'
        xLabel = 'Immunology 1985 Journal Pair z-scores'
        yLabel = 'WoS 1985 Journal Pair z-scores'
    if file == 3 :
        df = pd.read_csv('path_to_csv_file_with_z-score_data') # file 1
        """ Change the graph parameters below as is appropriate """
        zField1 = 'z_scores_metab95'
        zField2 = 'z_scores_d1000_95'
        xLabel = 'Metabolism 1995 Journal Pair z-scores'
        yLabel = 'WoS 1995 Journal Pair z-scores'
    if file == 4:
        df = pd.read_csv('path_to_csv_file_with_z-score_data') # file 2
        """ Change the graph parameters below as is appropriate """
        zField1 = 'z_scores_metab85'
        zField2 = 'z_scores_d1000_85'
        xLabel = 'Metabolism 1985 Journal Pair z-scores for '
        yLabel = 'WoS 1985 Journal Pair z-scores'
print('Original row count:',df.shape[0])
df.dropna(how='any',inplace=True)
print('After dropna row count:',df.shape[0])

dpiSet = [300,1000]  # dpi settings for creating graph files
dpiInd = 1           # selector for which dpi to use from list above

df['zDiff'] = df[zField1] - df[zField2]
df['zDiff'] = df['zDiff'].replace([np.inf, -np.inf], np.nan)
df['zClassImm'] = df[zField1].apply(classMe)
df['zClassWos'] = df[zField2].apply(classMe)
df['zSwitch'] = df[['zClassImm','zClassWos']].apply(classMeSwitch, axis='columns')
print('z-score Sign Analysis:\n',df['zSwitch'].value_counts())
df.dropna(how="any",subset=['zDiff'],inplace=True)

fig,ax = plt.subplots()
ax.hist(df['zDiff'],bins=30,range=(-200,50))
ax.set_xlabel('z-score Difference, '+zField1+' - WoS')
ax.set_ylabel('Frequency')
fig.set_size_inches(8,6)
fig.savefig('zDiffHist.jpg',dpi=600)
plt.show()

cm = confusion_matrix(df['zClassImm'],df['zClassWos'])
df_cm = pd.DataFrame(cm, index = ['negative','positive'],
                  columns = ['negative','positive'])
sns.heatmap(df_cm, annot=True)
print(df_cm)
print('Accuracy:',(cm[0,0]+cm[1,1])/cm.sum())

df['color'] = df.apply(colorMe,axis=1,z1=zField1,z2=zField2)
df['class'] = df.apply(codeMe,axis=1,z1=zField1,z2=zField2)

g = sns.jointplot(data=df, x=zField1, y=zField2, \
                  marginal_kws={'bins':200, 'hist_kws': {'edgecolor': 'black', 'color':'black'}})
g.ax_joint.cla()
g.ax_joint.scatter(data=df, x=zField1, y=zField2, color=df['color'].tolist(),alpha=0.1)
g.ax_joint.set_xlabel(xLabel, fontsize = 20)
g.ax_joint.set_ylabel(yLabel, fontsize = 20)
h = g.ax_joint
h.axvline(0,linestyle = '--',linewidth=1,color='k')
h.axhline(0,linestyle = '--',linewidth=1,color='k')
with PdfPages('insert_filename_for_saved_overview_graph_file_here.pdf') as pdf:
    pdf.savefig(g.fig,dpi=dpiSet[dpiInd])
plt.show()

""" Zoom in on a majority of data points
    Change these axis limit parameters for zooming in as is appropriate """
myXlim = (-70,100)
myYlim = (-250,250)
g = sns.jointplot(data=df, x=zField1, y=zField2,kind='scatter', alpha=0.1, \
                  marginal_kws={'bins':200, 'hist_kws': {'edgecolor': 'black', 'color':'black'}},xlim=(myXlim[0],myXlim[1]),ylim=(myYlim[0],myYlim[1]) \
                 )  
g.ax_joint.cla()
g.ax_joint.scatter(data=df, x=zField1, y=zField2, color=df['color'].tolist(),alpha=0.1)
g.ax_joint.set_xlim(myXlim)
g.ax_joint.set_ylim(myYlim)
g.ax_joint.set
g.ax_joint.set_xlabel(xLabel, fontsize = 20)
g.ax_joint.set_ylabel(yLabel, fontsize = 20)
h = g.ax_joint
h.axvline(0,linestyle = '--',linewidth=1,color='k')
h.axhline(0,linestyle = '--',linewidth=1,color='k')
plt.tick_params(axis="both", labelsize=14)

with PdfPages('insert_filename_for_saved_zoomed-in_graph_file_here.pdf') as pdf:
    pdf.savefig(g.fig,dpi=dpiSet[dpiInd])
plt.show()
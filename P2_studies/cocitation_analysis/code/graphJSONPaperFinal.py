# -*- coding: utf-8 -*-
"""
Created on Thu Jan 17 09:07:39 2019

@author: jrbrad
"""

import numpy as np
import matplotlib.pyplot as plt
# This mplot3d import registers the 3D projection, but is otherwise unused.
# A warning indicates that this imported package is not used... but it actually is
from mpl_toolkits.mplot3d import Axes3D  
import json
from matplotlib import colors as mcolors
import re
import os
from matplotlib.backends.backend_pdf import PdfPages

# create color palette
colors = dict(mcolors.BASE_COLORS, **mcolors.CSS4_COLORS)

# dictionary for possible use of substitute axes tickmark labels
labSub = {'HN':'High', 'LN':'Low', 'HC':'High', 'LC':'Low'}

# Graph font size parameters
fontsizeTML = 14
fontsizeAxLab = 16
fontsizeAxTitle = 18

# Graph data is imported in the JSON format shown below for 'graph1'
"""
graphJSON = '''{
              "graph1":
                  {
                    "name":"HNLN",
                    "x" : [0,1,2,3,4],
                    "y" : [5,6,7,8,9]
                  }
                }'''
"""
#graphJSON = '''{"H10N10": {"name": "Hits Percentile: 10%; Novelty Tail: 10%", "xLabels": ["LN", "HN"], "yLabels": ["LC", "HC"], "xInd": [0, 0, 1, 1], "yInd": [0, 1, 0, 1], "z": [0.0, 0.20588235294117646, 0.0, 0.0]}, "H10N01": {"name": "Hits Percentile: 10%; Novelty Tail: 01%", "xLabels": ["LN", "HN"], "yLabels": ["LC", "HC"], "xInd": [0, 0, 1, 1], "yInd": [0, 1, 0, 1], "z": [0.20588235294117646, 0.0, 0.0, 0.0]}, "H05N10": {"name": "Hits Percentile: 05%; Novelty Tail: 10%", "xLabels": ["LN", "HN"], "yLabels": ["LC", "HC"], "xInd": [0, 0, 1, 1], "yInd": [0, 1, 0, 1], "z": [0.0, 0.10294117647058823, 0.0, 0.0]}, "H05N01": {"name": "Hits Percentile: 05%; Novelty Tail: 01%", "xLabels": ["LN", "HN"], "yLabels": ["LC", "HC"], "xInd": [0, 0, 1, 1], "yInd": [0, 1, 0, 1], "z": [0.10294117647058823, 0.0, 0.0, 0.0]}, "H01N10": {"name": "Hits Percentile: 01%; Novelty Tail: 10%", "xLabels": ["LN", "HN"], "yLabels": ["LC", "HC"], "xInd": [0, 0, 1, 1], "yInd": [0, 1, 0, 1], "z": [0.0, 0.022058823529411766, 0.0, 0.0]}, "H01N01": {"name": "Hits Percentile: 01%; Novelty Tail: 01%", "xLabels": ["LN", "HN"], "yLabels": ["LC", "HC"], "xInd": [0, 0, 1, 1], "yInd": [0, 1, 0, 1], "z": [0.022058823529411766, 0.0, 0.0, 0.0]}}'''

""" Data Input Parameters """
""" 
    graph: a dictionary that wil contain graph data.  Each root key represents a different graph.
           Each graph has 2 subplots.
    myFiles: a list containing all the folders to be searched for JSON graph data.  All filenames 
             in each of these folders starting with 'graphJSON' and ending with '.csv' will be 
             opened.  In our context, folders are constructed with only one such file in a folder.  
             More than one such file will likely cause an execution error.
    myGraphs: a list indicating the keys corresponding with teh graph data to be extracted from
              the input JSON files.  There is a one-to-one correspondence with the elements of
              myFiles and myGraphs.  For examples, the graph key represented in myGraphs[0] will
              be extracted from the file represented in myFiles[0].
"""

""" Create empty graph dictionary which will contains graph data from the input files """
graphs = {}

""" Define first graph parameters and enter them into the graph dictionary """
""" myFiles is a list of files to open.
    The elements of myGraphs corresponds one-to-one wit those file paths and gives the
    JSON key for the graphs to plot """
myFiles = []
myFiles.append('../data/graphJSONimm95_pubwise_zsc_med.csv')
myFiles.append('../data/graphJSONd1000_95_pubwise_zsc_med.csv')
myGraphs = []
myGraphs.append('data_1995/imm95_pubwise_zsc_med.csv-H10N10')
myGraphs.append('data_1995/d1000_95_pubwise_zsc_med.csv-H10N10')
titles = ['Immunology 1995', 'WoS 1995'] # subplot axes titles
figId = re.search('H\d{2}N\d{2}',myGraphs[0])
figId = figId.group(0)
zticks = [0.00,0.04,0.08,0.12,0.16]
zticklabels = ['  0','  4','  8',' 12',' 16']
""" Insert data into dictionary """
graphs[0] = {'myFiles':myFiles, 'myGraphs': myGraphs, 'figId':figId, 'zticks':zticks, 'zticklabels':zticklabels}

""" Define second graph parameters and enter them into the graph dictionary """
myFiles = []
myFiles.append('D:/Research/Pharma/CureNetwork/code/zDist/correlations/paper/imm95/graphJSONimm95_pubwise_zsc_med.csv')
myFiles.append('D:/Research/Pharma/CureNetwork/code/zDist/correlations/paper/wos95/graphJSONd1000_95_pubwise_zsc_med.csv')
myGraphs = []
myGraphs.append('data_1995/imm95_pubwise_zsc_med.csv-H01N10')
myGraphs.append('data_1995/d1000_95_pubwise_zsc_med.csv-H01N10')
titles = ['Immunology 1995', 'WoS 1995']
figId = re.search('H\d{2}N\d{2}',myGraphs[0])
figId = figId.group(0)
zticks = [0.0,0.005,0.01,0.015,0.02]
zticklabels = ['  0.0','  0.5','  1.0','  1.5','  2.0']
""" Insert data into dictionary """
graphs[1] = {'myFiles':myFiles, 'myGraphs': myGraphs, 'figId':figId, 'zticks':zticks, 'zticklabels':zticklabels}

""" Extract data from JSON files for the target graphs """
for k,graph in graphs.items():
    dicGraph = {}
    for i in range(len(graph['myFiles'])):
        print(graph['myFiles'][i])
        with open(graph['myFiles'][i],'r') as f:
            graphJSON = f.read()
        graphJSON = json.loads(graphJSON)
        #for k in graphJSON.keys():
        #    graphJSON[k]['title'] = titles[i]
        dicGraph[graph['myGraphs'][i]] = graphJSON[graph['myGraphs'][i]]
        dicGraph[graph['myGraphs'][i]]['title'] = titles[i]
            
    # Compute maximum hit rate
    maxHitRate = max([max(dicGraph[k]['z']) for k in dicGraph])
    maxHitRate = int(maxHitRate*100+.5)/100
    
    """ parse JSON data into a dictionary named data """
    data = json.loads(json.dumps(dicGraph))
    
    """ setup the figure and axes """    
    numGraphs = 2   # number of subplots in each graph
    fig,ax = plt.subplots(numGraphs,1,subplot_kw = {'projection':'3d'},)
    fig.set_size_inches(6.5,9)
    axes = ax.ravel()   # linearizing the subplot array makes accessing axes easier
    """ Use for loop to populate graph with data and settings"""
    for q in range(numGraphs):
        axes[q].set_title(data[graph['myGraphs'][q]]['title'], fontsize = fontsizeAxTitle, fontname='Times New Roman')
        
        x,y = data[graph['myGraphs'][q]]['xInd'],data[graph['myGraphs'][q]]['yInd']
        z = data[graph['myGraphs'][q]]['z']
        
        xlabelsNew = [labSub[x] for x in data[graph['myGraphs'][q]]["xLabels"]]
        ylabelsNew = [labSub[x] for x in data[graph['myGraphs'][q]]["yLabels"]]
        axes[q].tick_params(axis='both',labelsize = fontsizeTML)
        axes[q].set_xticks([0.5,1.5])
        axes[q].set_xticklabels(xlabelsNew,fontsize=fontsizeTML, fontname='Times New Roman')
        axes[q].set_xlabel('Novelty',fontsize=fontsizeAxLab, fontname='Times New Roman', labelpad = 14)
        axes[q].set_yticks([0.5,1.5])
        axes[q].set_yticklabels(ylabelsNew, fontname='serif')
        axes[q].set_ylabel('Conventionality',fontsize=fontsizeAxLab, fontname='Times New Roman', labelpad = 14)
        axes[q].set_zlabel('Category\nHit Rate (%)',fontsize=fontsizeAxLab, fontname='Times New Roman', labelpad = 18)
        axes[q].set_zticks(graph['zticks'])
        axes[q].set_zticklabels(graph['zticklabels'],fontsize=fontsizeTML)
        
        bottom = np.zeros_like(z)
        width = depth = 0.7
        
        axes[q].bar3d(x, y, bottom, width, depth, z, color = ['r','g',colors['orange'],'b'], shade=True)
        axes[q].dist = 11.7
        
        axes[q].set_zlim((0,maxHitRate))
    
    """ Old graph title code--IGNORE
    graphTitle = data[dataKeys[k*numGraphs+q]]['name'].split('/')
    if graphTitle[-1] == '':
        graphTitle = graphTitle[:-1]
    graphTitle = graphTitle[-1]
    graphTitle = re.sub('\.[:%;\w\d\s]*','',graphTitle)
    """
    
    """ Create pdf version of graph """
    with PdfPages('Fig2'+ graph['figId'] + '.pdf') as pdf:
        pdf.savefig(fig,dpi=900)
    """ Code to save figure as JPG file 
    fig.savefig('Fig2-'+ graphTitle +str(s)+'.jpg',dpi=200)
    """
    plt.show()
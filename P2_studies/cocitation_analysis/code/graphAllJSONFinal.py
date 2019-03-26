# -*- coding: utf-8 -*-
"""
Created on Thu Jan 17 09:07:39 2019

@author: jrbrad
"""

import numpy as np
import matplotlib.pyplot as plt
# This import registers the 3D projection, but is otherwise unused.
# A warning indicates that this imported package is not used... but it actually is
from mpl_toolkits.mplot3d import Axes3D
import json
from matplotlib import colors as mcolors
import re
import os
from matplotlib.backends.backend_pdf import PdfPages

# create color palette
colors = dict(mcolors.BASE_COLORS, **mcolors.CSS4_COLORS)

# substitute axes tickmark labels
labSub = {'HN':'High', 'LN':'Low', 'HC':'High', 'LC':'Low'}

# Graph data is imported in the JSON format shown below
#graphJSON = '''{"H10N10": {"name": "Hits Percentile: 10%; Novelty Tail: 10%", "xLabels": ["LN", "HN"], "yLabels": ["LC", "HC"], "xInd": [0, 0, 1, 1], "yInd": [0, 1, 0, 1], "z": [0.0, 0.20588235294117646, 0.0, 0.0]}, "H10N01": {"name": "Hits Percentile: 10%; Novelty Tail: 01%", "xLabels": ["LN", "HN"], "yLabels": ["LC", "HC"], "xInd": [0, 0, 1, 1], "yInd": [0, 1, 0, 1], "z": [0.20588235294117646, 0.0, 0.0, 0.0]}, "H05N10": {"name": "Hits Percentile: 05%; Novelty Tail: 10%", "xLabels": ["LN", "HN"], "yLabels": ["LC", "HC"], "xInd": [0, 0, 1, 1], "yInd": [0, 1, 0, 1], "z": [0.0, 0.10294117647058823, 0.0, 0.0]}, "H05N01": {"name": "Hits Percentile: 05%; Novelty Tail: 01%", "xLabels": ["LN", "HN"], "yLabels": ["LC", "HC"], "xInd": [0, 0, 1, 1], "yInd": [0, 1, 0, 1], "z": [0.10294117647058823, 0.0, 0.0, 0.0]}, "H01N10": {"name": "Hits Percentile: 01%; Novelty Tail: 10%", "xLabels": ["LN", "HN"], "yLabels": ["LC", "HC"], "xInd": [0, 0, 1, 1], "yInd": [0, 1, 0, 1], "z": [0.0, 0.022058823529411766, 0.0, 0.0]}, "H01N01": {"name": "Hits Percentile: 01%; Novelty Tail: 01%", "xLabels": ["LN", "HN"], "yLabels": ["LC", "HC"], "xInd": [0, 0, 1, 1], "yInd": [0, 1, 0, 1], "z": [0.022058823529411766, 0.0, 0.0, 0.0]}}'''

# myDirs is a list that contains all the folders to be searched for JSON graph data
# Data is plotted for filenames in each of these folders starting with 'graphJSON' 
# and ending with '.csv'
myDirs = []
myDirs.append('../data/')

for myDir in myDirs:
    """ Find files with filenames starting with 'graphJSON' and ending with .csv """
    files = os.listdir(myDir)
    files = [file for file in files if re.match('^graphJSON.*\.csv$',file)]
    for file in files:
        print(file)
        with open(myDir+file,'r') as f:
            graphJSON = f.read()
        data = json.loads(graphJSON)
        
        # setup the figure and axes
        numGraphs = 8
        biteSize = int(numGraphs/2)
        
        i = -1
        s = -1
        dataKeys = list(data.keys())
        dataKeys.sort()
        
        keys = np.reshape(dataKeys,(biteSize,2))
        zMax = [max(max(data[x[0]]['z']),max(data[x[1]]['z'])) for x in keys]
        zMax = [x for x in zMax for i in range(2)]
        
        rowHead = ['Hit Articles:\nTop {}%\nCitations'.format(r) for r in [1,2,5,10]]
        colHead = ['Novelty Defined by {} Percentile z-scores'.format(c) for c in ['1st','10th']]
        
        if len(dataKeys)%biteSize == 0:
            for k in range(int(len(dataKeys)/numGraphs)):
                fig,ax = plt.subplots(biteSize,2,subplot_kw = {'projection':'3d'},)
                #plt.subplots_adjust(left=0.2, bottom=None, right=0.99, top=None, wspace=0.4, hspace=0.4)
                fig.set_size_inches(15,26)
                
                
                axes = ax.ravel()
                
                for ax, col in zip([axes[0],axes[1]], colHead):
                    ax.set_title(col, fontsize=18, fontname='Times New Roman')

                
                for i in range(biteSize):
                    axes[2*i].text(-0.6,-0.5,zMax[2*i]*0.5,rowHead[i],fontsize=18,fontname='Times New Roman', horizontalalignment='center',bbox=dict(facecolor='white',edgecolor='white',linewidth=0.0))
                
                
                    
                    
                for q in range(numGraphs):
                    i += 1
                    x,y = data[dataKeys[k*numGraphs+q]]['xInd'],data[dataKeys[k*numGraphs+q]]['yInd']
                    z = data[dataKeys[k*numGraphs+q]]['z']
                    
                    xlabelsNew = [labSub[x] for x in data[dataKeys[k*numGraphs+q]]["xLabels"]]
                    ylabelsNew = [labSub[x] for x in data[dataKeys[k*numGraphs+q]]["yLabels"]]
                    axes[q].tick_params(axis='both',labelsize = 12)
                    axes[q].set_xticks([0.5,1.5])
                    axes[q].set_xticklabels(xlabelsNew,fontsize=14,fontname='Times New Roman')
                    axes[q].set_xlabel('Novelty',fontsize=16,fontname='Times New Roman', labelpad = 14)
                    axes[q].set_yticks([0.5,1.5])
                    axes[q].set_yticklabels(ylabelsNew,fontsize=14,fontname='Times New Roman')
                    axes[q].set_ylabel('Conventionality',fontsize=16,fontname='Times New Roman', labelpad = 14)
                    axes[q].set_zlabel('Category Hit Rate (%)',fontsize=16,fontname='Times New Roman', labelpad = 14)
                    
                    axes[q].set_zlim((0,zMax[q]))
                    
                    bottom = np.zeros_like(z)
                    width = depth = 0.7
                    
                    axes[q].bar3d(x, y, bottom, width, depth, z, color = ['r','g',colors['orange'],'b'], shade=True)
                    axes[q].dist = 11
                    
                    axes[q].margins(x = 0.15,y = 0.15)
                    
                s += 1
                graphTitle = myDir.split('/')
                if graphTitle[-1] == '':
                    graphTitle = graphTitle[:-1]
                graphTitle = graphTitle[-1]
                
                fig.canvas.draw()
                for q in range(numGraphs):
                    zLabsTest = []
                    zLabs = []
                    for t in axes[q].get_zticklabels():
                        try:
                            zLabsTest.append(int(float(t.get_text())*100))
                        except:
                            zLabsTest.append(t.get_text())
                    for t in axes[q].get_zticklabels():
                        try:
                            zLabs.append(float(t.get_text())*100)
                        except:
                            zLabs.append(t.get_text())
                    eq = True
                    for i in range(len(zLabs)):
                        try:
                            if (abs(zLabs[i] - zLabsTest[i])/float(zLabs[i])) > 0.00001:
                                eq = False
                        except:
                            pass
                    if eq:
                            axes[q].set_zticklabels([str(z) for z in zLabsTest],fontsize=14,fontname='Times New Roman')
                    else:
                        zLabs1 = []
                        for z in zLabs:
                            try:
                                zLabs1.append('{:.1f}'.format(z))
                            except:
                                zLabs1.append(z)
                        axes[q].set_zticklabels(zLabs1,fontsize=14,fontname='Times New Roman')
                
                with PdfPages('Fig2-'+ graphTitle +str(s)+'.pdf') as pdf:
                    pdf.savefig(fig,dpi=900)
                fig.savefig('Fig2-'+ graphTitle +str(s)+'.jpg',dpi=1000)
                print(graphTitle)
                plt.show()
        else:
            print('len(dataKeys)%biteSize must be zero')
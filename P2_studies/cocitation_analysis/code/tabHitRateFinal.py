# -*- coding: utf-8 -*-
"""
Created on Mon Mar 11 14:21:30 2019

@author: jrbrad
"""

import json
import re
import os

""" myDirs is a list of file folders that contains JSON data for hit rates.  All
    JSON files with the extension .json in these folders will be explored.  Such files
    that do not contain hit rate data will throw errors.                      """
myDirs = []
myDirs.append('../data/')

latex10 = ''  # string to accumulate Latex table text for novelty defined at 10th percentile
latex1 = ''   # string to accumulate Latex table text for novelty defined at 1st percentile
""" dictionary to translate file names into data set specification adn year """
trans = {'imm85':'Immunology & 1985', \
         'imm95':'Immunology & 1995', \
         'imm05':'Immunology & 2005', \
         'metab85':'Metabolism & 1985', \
         'metab95':'Metabolism & 1995', \
         'metab05':'Metabolism & 2005', \
         'ap85':'Applied Physics & 1985', \
         'ap95':'Applied Physics & 1995', \
         'ap05':'Applied Physics & 2005', \
         'wos85':'Web of Science & 1985', \
         'wos95':'Web of Science & 1995', \
         'wos05':'Web of Science & 2005'}
catKeys = ['LNLC','LNHC','HNLC','HNHC']  # categories
numPlaces = 1  # number of decimal places to display
accHR = ['1', '2', '5', '10']   # list of minimum percentile for designation of hits
accNov = ['10','1']             # novelty percentile parameter settings

for myDir in myDirs:
    """ get data """
    files = os.listdir(myDir)
    files = [file for file in files if re.match('^\w*\.json$',file)]
    """ Iterate through all the JSON files found """
    for file in files:
        print(file)
        with open(myDir+file,'r') as f:
            hr = f.read()
            hr = json.loads(hr)
        keys = list(hr.keys())
        keys.sort()
        for key in keys:
            hitRate = re.search('H\d\d',key).group(0)
            hitRate = str(int(hitRate[1:]))
            novDef = re.search('N\d\d',key).group(0)
            novDef = str(int(novDef[1:]))
            dataSet = myDir.split('/')[-1]
            if dataSet == '':
                dataSet = myDir.split('/')[-2]
            if hitRate in accHR:
                if novDef == accNov[0]:
                    latex10 += trans[dataSet] + '&' + hitRate + '\%' # + '&' #+ novDef + '\%' 
                    for key1 in catKeys:
                        #latex10 += '& (' + '{:,}'.format(hr[key][key1]['total']) + ',' + '{:.3f}'.format(float(int(pow(10,numPlaces)*hr[key][key1]['hitPerc'] + 0.5))/pow(10,numPlaces)) + ')'
                        latex10 += '& '  + str('{:.'+str(numPlaces)+'f}').format(float(int(pow(10,numPlaces)*hr[key][key1]['hitPerc']*100.0 + 0.5))/pow(10,numPlaces)) 
                    latex10 += ' \\\\ \n'
                if novDef == accNov[1]:
                    latex1 += trans[dataSet] + '&' + hitRate + '\%' #+ '&' + novDef + '\%' 
                    for key1 in catKeys:
                        #latex10 += '& (' + '{:,}'.format(hr[key][key1]['total']) + ',' + '{:.3f}'.format(float(int(pow(10,numPlaces)*hr[key][key1]['hitPerc'] + 0.5))/pow(10,numPlaces)) + ')'
                        latex1 += '& '  + str('{:.'+str(numPlaces)+'f}').format(float(int(pow(10,numPlaces)*hr[key][key1]['hitPerc']*100.0 + 0.5))/pow(10,numPlaces)) 
                    latex1 += ' \\\\ \n'
            
""" Write text files with Latex table text """
with open('D:/Research/Pharma/CureNetwork/code/zDist/correlations/paper1/HRPaperLatex10.txt','w') as f:
    f.write(latex10)
with open('D:/Research/Pharma/CureNetwork/code/zDist/correlations/paper1/HRPaperLatex1.txt','w') as f:
    f.write(latex1)
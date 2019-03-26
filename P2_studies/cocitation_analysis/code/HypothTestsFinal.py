# -*- coding: utf-8 -*-
"""
Created on Wed Jan 16 11:27:05 2019

@author: James R. Bradley
"""

""" Quick Start 

In order to use this program, you will need to do these things:
    * Specify a value for the variable 'server' to indicate whether local files
      will be input for, perhaps, debugging mode or file paths on a remote
      server will be used.
    * Specify appropriate values for the variables 'path1' and 'files1' 
      for input file paths.
    * Determine whether the variable 'files1Short' is desired.  This was based
      on the authors file-naming conventions and will not be appropriate in 
      all circumstances.  Other parts of the program will need to be revised
      if this variable is not used for a shorter graph title.
     * Ensure that inout data is in teh format indicated in comments below.
"""

"""
This Python 3 code performs the following tasks:
    * Performs statistical tests on hit rate data:
        - Tests whether the distribution of hits across the four categories is
          different from a random allocation of hits across categories in proportion
          to the number of articles in each category in a statistically significant way.
        - Tests whether categorizing articles along the dimensions of novelty and
          conventionality, individually, has explanatory power
        - Test whether the number of hits in each category differs in a statistically
          significant way from a ransom distribution of hit articles among the 
          categories by binning the remaining three categories together.  This mitigates
          issues that arise in some circumstances when an insuffiicent expeted number
          of hits prevents a valid analysis in the case of the test outlined in the
          first bullet point above.
    * Performs the Spearman Rank Correlation Test between citation_count and all
      other data columns
    * Outputs JSON files to be used by a subsequent program to graph the data
    * Outputs data in a format amenable to inclusion in LaTex file tables
"""


""" This program requires all of the Python packages below, which
    are all included with the Anaconda distribution of Python     """
import pandas as pd
import numpy as np
from scipy.stats import spearmanr
from scipy.stats import chisquare
from scipy.stats import binom
import json
import re

server = True

""" This function formats data for output in LaTex format to a specified 
    number of decimal places """
def formFloat (num,places):
    fStr = '{:.'+str(places)+'f}'
    num = float(int(float(fStr.format(num))*10**places+0.5))/10**places
    if num <= 0.025:# or num >= 0.975:
        return '\\textbf{'+fStr.format(num)+'}'
    elif num <= 0.05:# or num >= .95:
        return '\\textit{'+fStr.format(num)+'}'
    else:
        return fStr.format(num)

""" This function formats data for output in LaTex format 

    It also includes code for a dagger symbol where the number of expected
    hits was less than the minimum required for a valid statistical test """
def formFloatDagger (num,places):
    fStr = '{:.'+str(places)+'f}'
    num[0] = float(int(float(fStr.format(num[0]))*10**places+0.5))/10**places
    if num[0] <= 0.025: # or num[0] >= 0.975:
        if num[1] >= 5.0:
            return '\\textbf{'+fStr.format(num[0])+'}'
        else:
            return '$\dagger$ \\textbf{'+fStr.format(num[0])+'} '
    elif num[0] <= 0.05: # or num[0] >= .95:
        if num[1] >= 5.0:
            return '\\textit{'+fStr.format(num[0])+'}'
        else:
            return '$\dagger$ \\textit{'+fStr.format(num[0])+'} '
    else:
        return fStr.format(num[0])

""" This function formats data for output in LaTex format 

    It also permits output of the string 'NA' when a numberical value
    is not passed to the function. """
def formFloatDaggerNA (num,places):
    try:
        fStr = '{:.'+str(places)+'f}'
        num = float(int(float(fStr.format(num))*10**places+0.5))/10**places
        if num <= 0.025: # or num >= 0.975:
            return '\\textbf{'+fStr.format(num)+'}'
        elif num <= 0.05: # or num >= .95:
            return '\\textit{'+fStr.format(num)+'}'
        else:
            return fStr.format(num)
    except:
        return str(num)
        
""" Calculates hit rate except returns 0.0 when the total number of articles 
    in a category is zero to avoid dividing by zero """
def percent(row):
    if row['total']> 0:
        return row['hit'] / row['total']
    else:
        return 0.0

""" This if-else block permits an alternate, local file to be input during debugging 
    server is a Boolean variable that, if True, indicates that the path and files in
    if block are input and, otherwise, the path and files in the else block are input. """
    
""" Input file format """
""" Input requires the first line to have field names and subsequent comma-delimited text files 

    Data dictionary:
        * source_id: a unique identifier for an article.  We used IDs from the Web of 
          Science under license from Clarivate Analytics, which we cannot disclose.
          These can be string values (do not enclose in quotes in data file if this is
          the case).
        * med: the median z-score of all the citations in the source article
        * ten: the 10th percentile z-score (left tail) of the citation z-scores
        * one: the 1st percentile z-score (left tail) of the citation z-scores
        * citation_count: the number of tiems the source articles was cited

    Example:
    
    source_id,med,ten,one,citation_count
    0,4.37535958641463,-0.368176148773802,-1.84767079802106,1
    1,8.94701613716861,0.695385836097657,-1.0789085501296,6
    2,17.9740470024929,-8.85622661474813,-10.3102229485467,14
"""

""" The Boolean variable 'server' controls which paths and files are input """
if server:     # settings for production runs on server
    path1 = '/path_to_remote_data_folder/'
    files1 = ['data_1995/d1000_95_pubwise_zsc_med.csv','data_1995/imm95_pubwise_zsc_med.csv','data_1995/metab95_pubwise_zsc_med.csv', 'data_1995/ap95_pubwise_zsc_med.csv', \
              'data_1985/d1000_85_pubwise_zsc_med.csv','data_1985/imm85_pubwise_zsc_med.csv','data_1985/metab85_pubwise_zsc_med.csv', 'data_1985/ap85_pubwise_zsc_med.csv', \
              'data_2005/d1000_2005_pubwise_zsc_med.csv', 'data_2005/imm2005_pubwise_zsc_med.csv','data_2005/metab2005_pubwise_zsc_med.csv', 'data_2005/ap2005_pubwise_zsc_med.csv']
else:         # settings for local debugging
    path1 = '/path_to_local_data_folder/'
    files1 = ['data_1995/d1000_95_pubwise_zsc_med.csv']

""" This statement extracts the filename from the path for succinct identification of the filename """
""" This statement may not be appropriate for alternate file naming conventions """
files1Short = [x.split('/')[-1] for x in files1]
""" Extract year and data set topic from filename """ 
years = [re.search('data_\d{4}',x).group(0).replace('data_','') for x in files1]
datasets = [re.sub('\d+','',re.search('/\w+_',x).group(0).split('_')[0].replace('/','')) for x in files1]
transDataset = {'imm':'Immunology', 'd':'Web of Science', 'metab':'Metabolism', 'ap':'Applied Physics'}


""" These lists are are used for coding results in Latex files, output in JSON files,
    and create pandas DataFrames within the program """
cols = ['med','ten','one']
catConven = ['LC','HC']
catNovel = ['HN','LN']
catHit = ['hit','non-hit']
countRows = ['LNHC','HNLC','LNLC','HNHC']
countCols = catHit
countRowsBin = ['LN','HN','LC','HC']

""" Iterate through the inputted fiels """
for i in range(len(files1)):
    """ These statements create empty dictionaries for storing results"""
    binomRes = {}   # dictionary for results of 2-category tests
    Fig2Res = {}    # dictionary for results of 4-category tests for data in the form of Uzzi's Fig. 2
    Fig2IndRes = {} # dictionary for results of testing each of the 4 categories in Uzzi's Fig. 2 individually
    graphDic = {}   # Dictionary to store visualization data
    df = pd.read_csv(path1+files1[i])  # read file
    jsonCounts = json.loads('{}')  # JSON string to store the results
    #dicNewRow = {'file':files1[i]}
    
    """ Compute Spearman Rank Correlation Tests on citation_count column with other columns """
    dfRes = pd.DataFrame(columns=['file']+cols) # DataFrame for correlation results
    newRow = [files1[i]]
    for col in cols:
        print('Spearman Rank Correlation for '+files1[i]+': Columns '+col+' and '+'citation_count')
        result = spearmanr(df['citation_count'], df[col])
        print(result,'\n\n')
        newRow.append('Col. '+col+':  corr = '+str(result[0]) + ', p = ' + str(result[1]))
        #dicNewRow[col] =  str(result[0]) + ',' + str(result[1])
    dfRes.loc[files1[i]] = newRow #['1',1,2,3] 
    #pd.DataFrame.from_dict(dicNewRow, orient='index')
    #dfRes = pd.concat([dfRes,pd.DataFrame.from_dict(dicNewRow, orient='index')])
    
    """ Set Hits and Novelty thresholds and create new columns in the df DataFrame to store 
        the categorical labels """
    citPerc10 = df['citation_count'].quantile(0.9)
    citPerc5 = df['citation_count'].quantile(0.95)
    citPerc2 = df['citation_count'].quantile(0.98)
    citPerc1 = df['citation_count'].quantile(0.99)
    median = df['med'].median()
    
    """ Create DataFrame columns for categorical variables """
    df['conven'] = np.where(df['med']<=median,catConven[0],catConven[1])
    df['hit10'] = np.where(df['citation_count']>=citPerc10,catHit[0],catHit[1])
    df['hit05'] = np.where(df['citation_count']>=citPerc5,catHit[0],catHit[1])
    df['hit02'] = np.where(df['citation_count']>=citPerc2,catHit[0],catHit[1])
    df['hit01'] = np.where(df['citation_count']>=citPerc1,catHit[0],catHit[1])
    df['novel10'] = np.where(df['ten']<0,catNovel[0],catNovel[1])
    df['novel01'] = np.where(df['one']<0,catNovel[0],catNovel[1])
    
    """ Create lists to iterate through for Hits threshold levels and Novelty thresholds """
    hits = ['01','02','05','10']
    novelLevs = ['10','01']
    
    """ 
    Statistical analysis
      - Compute number of non-hits and hits in each of four categories
      - Compute total observations in each category and percentages
      - Based on category percentages and hit rate, compute expected 
        number of hits in each category
      - Compute chi square goodness of fit tests
      - Output results for plotting 3D column charts
      - Output results formatted for Latex tables
    """
    for hit in hits:  # Compute statistics for each hit rate
        for novLev in novelLevs:  # Compute stats for each definition of  novel z-score tail
            
            """ Create title and initialize dictionary to save data for later graphing """
            justFile = files1[i].split('/')[-1]
            title = justFile+': Hits Percentile: '+hit+'%; Novelty Tail: '+novLev+'%'
            newGraphDic = {'name':title}
            
            """ Create DataFrame to record hits (Counts) in each of the four categories """
            dfCounts = pd.DataFrame(index=countRows, columns=countCols)
            counts = df.groupby(['conven','novel'+novLev,'hit'+hit])['source_id'].count()
            """ Use try-except in case there are any categories with zero articles """
            for k in range(len(countRows)):
                for m in range(len(catHit)):
                    try:
                        dfCounts.loc[countRows[k]][catHit[m]] = counts.loc[(countRows[k][2:],countRows[k][:2],catHit[m])]
                    except:
                        dfCounts.loc[countRows[k]][catHit[m]] = 0
            dfCounts['total'] = dfCounts[catHit[0]] + dfCounts[catHit[1]]
            dfCounts['hitPerc'] = dfCounts.apply(percent,axis='columns') 
            totCount = dfCounts['total'].sum()
            totHitPerc = dfCounts['hit'].sum() / totCount
            dfCounts['totPerc'] = dfCounts['total'] / totCount
            dfCounts['Ehits'] = dfCounts['totPerc'] * totHitPerc * totCount
            print('\n',title)
            print(dfCounts)
            
            """ Update JSON string with Counts data """
            jsonCounts.update({"H"+str(hit)+"N"+str(novLev):json.loads(dfCounts.to_json(orient='index'))})
            
            """ Do Chi Square Goodness of Fit """
            try:
                results = chisquare(dfCounts['hit'],f_exp=dfCounts['Ehits'])
                print('\nChi Square Test Results: ',results,'\n\n')
                Fig2Res[(justFile,int(hit),int(novLev))] = [results[1],min(dfCounts['Ehits'])]
            except:
                print('Cannot perform Chi Square Test')
                
            """ Save data for graphing with other program """
            newGraphDic['xLabels'] = catNovel
            newGraphDic['yLabels'] = catConven
            xInd = []
            yInd = []
            z = []
            for k in range(len(catNovel)):
                for m in range(len(catConven)):
                    xInd.append(k)
                    yInd.append(m)
                    z.append(dfCounts.loc[catNovel[k]+catConven[m]]['hitPerc'])
            newGraphDic['xInd'] = xInd
            newGraphDic['yInd'] = yInd
            newGraphDic['z'] = z
            graphDic[files1[i]+'-H'+hit+'N'+novLev] = newGraphDic
                   
            """ Binomial Tests for significance into high and low classifications for tail
                novelty and median conventionality, separately """
                
            """ Create 2 DataFrames, dfCountsBinNov and dfCountsBinConven, one for testing Low versus High Novelty 
                and one for testing Low versus High Conventionality """
            dfCountsBinConven = pd.DataFrame(index=countRowsBin[2:], columns=catHit)
            dfCountsBinConven.name = 'Conventionality'
            dfCountsBinNov = pd.DataFrame(index=countRowsBin[:2], columns=catHit)
            dfCountsBinNov.name = 'Novelty'
            counts1 = df.groupby(['conven','hit'+hit])['source_id'].count()
            counts2 = df.groupby(['novel'+novLev,'hit'+hit])['source_id'].count()
            for k in [2,3]:
                for m in range(len(catHit)):
                    try:
                        dfCountsBinConven.loc[countRowsBin[k]][catHit[m]] = counts1.loc[(countRowsBin[k],catHit[m])]
                    except:
                        dfCountsBinConven.loc[countRowsBin[k]][catHit[m]] = 0
            dfCountsBinConven['total'] = dfCountsBinConven[catHit[0]] + dfCountsBinConven[catHit[1]]
            dfCountsBinConven.loc['total'] = [dfCountsBinConven['hit'].sum(),dfCountsBinConven['non-hit'].sum(),dfCountsBinConven['total'].sum()]
            for k in [0,1]:
                for m in range(len(catHit)):
                    try:
                        dfCountsBinNov.loc[countRowsBin[k]][catHit[m]] = counts2.loc[(countRowsBin[k],catHit[m])]
                    except:
                        dfCountsBinNov.loc[countRowsBin[k]][catHit[m]] = 0
            dfCountsBinNov['total'] = dfCountsBinNov[catHit[0]] + dfCountsBinNov[catHit[1]]
            dfCountsBinNov.loc['total'] = [dfCountsBinNov['hit'].sum(),dfCountsBinNov['non-hit'].sum(),dfCountsBinNov['total'].sum()]
            
            """ Check against appropriate binomial sampling distribution """
            newRow = []
            for dfX in [dfCountsBinConven,dfCountsBinNov]:
                for bb in [0,1]:
                    n = dfX.iloc[bb]['total']
                    p = dfX.loc['total']['hit']/dfX.loc['total']['total']
                    dist = binom.pmf(range(0,n+1),n,p)
                    pval = sum(dist[dfX.iloc[bb]['hit']:])
                    newRow.append(pval)
            binomRes[(justFile,int(hit),int(novLev),dfX.name,dfX.index[bb])] = newRow
            
            """ Do Binomial Tests on each of the four categories individually using the DataFrame 
                named dfCounts """
            newRow = []
            for index, row in dfCounts.iterrows():
                if row['total'] > 0 and (row['hit'] >= 1 or row['Ehits'] >= 1):
                    dist = binom.pmf(range(0,row['non-hit']+1),row['non-hit'],row['Ehits']/row['total'])
                    newRow.append(sum(dist[row['hit']:]))
                else:
                    newRow.append('NA')
                Fig2IndRes[(justFile,int(hit),int(novLev))] = newRow
            

    """ Output JSON files for graphing and documentation of hit rates"""
    with open(files1Short[i].replace('csv','')+'json', 'w') as outfile:
        json.dump(jsonCounts,outfile, indent=2)            

    dfRes.to_csv('corrOut'+files1Short[i])
    with open('graphJSON'+files1Short[i],'w') as f:
        json.dump(graphDic,f)
        
    """ The next 3 segments of code write LaTex table text to file """  
    """ Hypothesis Test of Random distribution of Hits Across Four Categories """
    with open('FourCatResults'+files1Short[i].replace('.csv','')+'.txt','w') as f:
        places = 3
        print('\n\nFour-Category Tests\nFile-Parameters-Dimension       p value')
        keys = list(set([(k[0],k[1]) for k in Fig2Res.keys()]))
        keys.sort()
        for k in keys:
            #f.write(transDataset[datasets[i]] + ' & ' + years[i] + ' & ' + str(k[1]) + '\% & '+ str(k[2]) + '\% & ' + \
            #      formFloatDagger(v,places) + ' \\\\ \n')
            f.write(transDataset[datasets[i]] + ' & ' + years[i] + ' & ' + str(k[1]) + '\% & ' + \
                  formFloatDagger(Fig2Res[(k[0],k[1],1)],places) + ' & ' + formFloatDagger(Fig2Res[(k[0],k[1],10)],places) + ' \\\\ \n')
        
    """ 4-Category Hypothesis Test, Each category Tested Individually """
    for novLev in novelLevs:
        with open('FourCatResultsInd'+'_'+novLev+'_'+files1Short[i].replace('.csv','')+'.txt','w') as f:
            places = 3
            print('\n\nFour Categories Tested Individually\nFile-Parameters-Dimension       p values')
            r = [(k,v) for k,v in Fig2IndRes.items()]
            r.sort()
            for k,v in r:
                if k[2] == int(novLev):
                    print(k,v)
                    #f.write(transDataset[datasets[i]] + ' & ' + years[i] + ' & ' + str(k[1]) + '\% & '+ str(k[2]) + '\% & ' + \
                    #      formFloatDaggerNA(v[0],places) + ' & ' +  formFloatDaggerNA(v[1],places) + ' & ' +  \
                    #      formFloatDaggerNA(v[2],places) + ' & ' +  formFloatDaggerNA(v[3],places) + ' \\\\ \n')
                    f.write(transDataset[datasets[i]] + ' & ' + years[i] + ' & ' + str(k[1]) + '\% & ' + \
                          formFloatDaggerNA(v[0],places) + ' & ' +  formFloatDaggerNA(v[1],places) + ' & ' +  \
                          formFloatDaggerNA(v[2],places) + ' & ' +  formFloatDaggerNA(v[3],places) + ' \\\\ \n')
    
    """ Hypothesis Test: Novelty and Conventionality Individually """
    for novLev in novelLevs:
        f = open('binomResults'+'_'+novLev+'_'+files1Short[i].replace('.csv','')+'.txt','w')
        places = 3
        print('\n\nTwo-Category Tests\nFile-Parameters-Dimension       p value')
        r = [(k,v) for k,v in binomRes.items()]
        r.sort()
        for k,v in r:
            if k[2] == int(novLev):
                print(k,v)
                #f.write(transDataset[datasets[i]] + ' & ' + years[i] + ' & ' + str(k[1]) + '\% & '+ str(k[2]) + '\% & ' + \
                #      formFloat(v[0],places) + ' & ' +  formFloat(v[1],places) + ' & ' +  \
                #      formFloat(v[2],places) + ' & ' +  formFloat(v[3],places) + ' \\\\ \n')
                f.write(transDataset[datasets[i]] + ' & ' + years[i] + ' & ' + str(k[1]) + '\% & ' + \
                      formFloat(v[0],places) + ' & ' +  formFloat(v[1],places) + ' & ' +  \
                      formFloat(v[2],places) + ' & ' +  formFloat(v[3],places) + ' \\\\ \n')
        f.close()
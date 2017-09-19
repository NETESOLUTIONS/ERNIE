from bs4 import BeautifulSoup as bs
import re
import lxml
import urllib.request
from datetime import datetime as dt 
import pandas as pd
"""Initialize Variables and read data"""
start = dt.now()
read = pd.read_csv('ngc_complete.csv')
ourl = read['url']
uid = read['uid']
totalcount = []
pm = []
completeft = []
"""Clean the data"""
newurl = [x.strip() for x in ourl]
df = [list(y) for y in zip(newurl, uid)]
df = pd.DataFrame(df)
df.to_csv('ngcclean.csv')
"""Read AHRQ and turn to soup"""
for num in uid:
    num = str(num)
    url = 'http://www.guideline.gov/content.aspx?id=' + num
    info = urllib.request.urlopen(url).read()
    soup = bs(info, 'lxml')
    """Search soup for tag a"""
    taga = soup.find_all('a')
    tempft = []
    length = len(taga)
    """find full text articles and store them in list with uid
    ahrq url and the url of full text after cleaning full text url"""
    for z in range(length):
        linkft = str(taga[z])
        if '(full text)' in linkft:
            finalft = re.findall(r'href=(.*)"', str(linkft))
            if len(finalft) > 0:
                totalcount.append(len(finalft))
                for eachL in finalft:
                    eachL = str(eachL)
                    tempft.append(eachL)
                if len(tempft) > 0:
                    a = tempft[0]
                    a = a.rpartition(' id="ct')[0]
                    a = a.replace('"', '')
                    a = a.replace("'", '')
    completeft.append((url,a,len(tempft), num))
    """Find pubmed in ahrq and store pmid and uid in list"""
    for y in range(length):
        linkpm = str(taga[y])
        if 'PubMed' in linkpm:
            final = re.findall(r'href=(.*)"', str(linkpm))
            final = str(final)
            if 'list_uids' in final:
                index = final.index('list_uids') + 10
                index2 = final.index(' ')
                final = final[index:index2-1]
                pm.append((final,num))
                break
"""df = pd.DataFrame(completeft)"""
df.to_csv('completefttrial.csv')
df = pd.DataFrame(pm)
df.to_csv('pmidtrial.csv')
print(dt.now() - start)







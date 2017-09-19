from bs4 import BeautifulSoup as bs
import re
import lxml
import urllib.request
import os
import pandas as pd
from datetime import datetime

startTime = datetime.now()
wosurl = "http://apps.webofknowledge.com/full_record.do?product=UA&search_mode=AdvancedSearch&qid=956&SID=2DbS2EOudHc6iHueIOs&page=1&doc=1"
numdocs = 189
wosurlstr = wosurl[:-7]
final = []
temp = []
final2 = []
c = 1
v = [51,101,151,201,251,301,351,401,451,501,551,601,651,701,751,801]
for x in range(1,190):
    if x in v:
        c = c+1
    print('Record Number', x, 'out of', 189)
    y = str(c)
    z = str(x)
    url = wosurlstr + y + '&doc='+z
    resp = urllib.request.urlopen(url)
    info = resp.read()
    soup = bs(info, 'lxml')
    wosid = re.findall(r'UT=WOS:(.*?)&amp', str(info))
    pmid = re.findall(r'hitHilite(.*?)span', str(info))
    if len(wosid) > 0 and len(pmid) > 0:
        temp.append((wosid[0], pmid[0]))
    if len(wosid) > 0:
        final.append(wosid[0])
    if len(pmid) > 0:
        final2.append(pmid[0])
    
print(datetime.now() - startTime)
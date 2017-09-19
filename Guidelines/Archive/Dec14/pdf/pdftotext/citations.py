from bs4 import BeautifulSoup as bs
import re
import lxml
import urllib.request
import pandas as pd
from datetime import datetime
from urllib.parse import urlparse, parse_qs, urlencode
"""PMID from single line reference string"""
startTime = datetime.now()
url = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term='
data = pd.read_csv('citation.csv', 'utf8')
ref = data['Citation']
data1 = pd.read_csv('citation2.csv', 'utf8')
cit = data1['Short']
final = []
tempref = []
tempcit = []

for x in range(len(ref)):
    newurl = url + str(ref[x])
    newurl = newurl.replace(' ', '%20')
    parsed_url = urlparse(newurl)
    parameters = parse_qs(parsed_url.query)
    newurl = parsed_url._replace(query=urlencode(parameters, doseq=True)).geturl()
    resp = urllib.request.urlopen(newurl)
    dat = resp.read()
    soup = bs(dat, 'lxml')
    uid = soup.find_all('id')
    if len(uid) == 1:
        for item in uid:
            item = str(item)
            item = item.replace('id>','')
            item = item.replace('<','')
            item = item.replace('/','')
            item = int(item)
            final.append((item,str(ref[x]),newurl)) 
            tempref.append((item,str(ref[x]),newurl))
for y in range(len(cit)):
    newurl = url+str(cit[y])
    newurl = newurl.replace(' ', '%20')    
    parsed_url = urlparse(newurl)
    parameters = parse_qs(parsed_url.query)
    newurl = parsed_url._replace(query=urlencode(parameters,doseq=True)).geturl()
    dat1 = urllib.request.urlopen(newurl).read()
    soup1 = bs(dat1, 'lxml')
    uid = soup1.find_all('id')
    if len(uid) == 1:
        for item in uid:
            item = str(item)
            item = item.replace('id>','')
            item = item.replace('<','')
            item = item.replace('/','')
            item = int(item)
            final.append((item,str(cit[y]), newurl))
            tempcit.append((item,str(cit[y]), newurl))
                           
print(datetime.now() - startTime)


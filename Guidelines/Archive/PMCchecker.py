from bs4 import BeautifulSoup as bs
import re
import lxml
import urllib.request
import pandas as pd
from datetime import datetime

#Timer
startTime = datetime.now()
#Establish Variables and read CSV
url = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?linkname=pubmed\
_pubmed_refs&from_uid='
cpmid = pd.read_csv('pid.csv')
pmid = cpmid['PMID']
final = []
one = []
df = []
s = 0
"""Run loop through all PMIDs in CSV and for each PMID
open the appropriate link to eutils and split the data received
according to the 'id' tag. Then create a list of tuples with all
the pmid of references as a list and the PMID of the Clinical Guideline"""

for x in range(len(pmid)):
    refs = []
    pid = str(pmid[x])
    newurl = url + pid
    resp = urllib.request.urlopen(newurl)
    data = resp.read()
    soup = bs(data, 'lxml')
    uid = soup.find_all('id')
    for y in range(len(uid)):
        refs.append(uid[y])
        """ Only want to keep reference id if quantity greater than 1 
        because the first id is always the original searched id."""
    if len(refs) > 1:
        s = len(refs) + s
        final.append(refs)
        one.append(pmid[x])
        df.append((refs, pmid[x]))
print(s/len(final))        
print(datetime.now() - startTime)

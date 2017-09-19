from bs4 import BeautifulSoup as bs
import re
import lxml
import urllib.request
import os
import pandas as pd
from datetime import datetime

startTime = datetime.now()
temp = []
temp1 = []
uid = []
wd = os.listdir('/Users/Avi/Documents/use')
for i in wd:
    if '.txt' in i:
        j = i[:-4]
        j = str(j)
        uid.append(j)
for x in range(len(uid)):
    url = 'http://www.guideline.gov/content.aspx?id=' + uid[x]
    resp = urllib.request.urlopen(url)
    data = resp.read()
    soup = bs(data, 'lxml')
    other = soup.find_all('span')
    final = []
    final1 = []
    for y in range(len(other)):
        you = str(other[y])
        if 'references]' in you:
            final = re.findall(' \[(.*?)\]', str(you))
            break
        else:
            final = []
        
    for z in range(len(other)):
        you1 = str(other[z])
        if 'PubMed' in you1:
            final1 = re.findall(r'href=(.*)"', str(you1))
            temp1.append((final1,uid[x]))
            break
           
    try:
        final
    except NameError:
        print('hi')
    else:
        for each in final:
            each = each[:-11]
            try:
                num = int(each)
            except ValueError:
                continue
            
        temp.append((num, uid[x]))
        path1 = '/Users/Avi/Documents/use/' + uid[x] + '.txt'
        path2 = '/Users/Avi/Documents/use/codes/' + uid[x] + '.txt'
        path11 = '/Users/Avi/Documents/use/' + uid[x] + '.pdf'
        path22 = '/Users/Avi/Documents/use/codes/' + uid[x] + '.pdf'
        os.rename(path1, path2)
        os.rename(path11, path22)

print(datetime.now() - startTime)
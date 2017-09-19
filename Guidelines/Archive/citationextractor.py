from bs4 import BeautifulSoup
import re
import pandas as pd
from datetime import datetime
import os
startTime = datetime.now()
file = pd.read_csv('ngc6.1')
uid = file['uid']
num = file['num']
length = len(num)
for x in range(len(num)):
    val = str(uid[x])
    number = int(num[x])
    filename = val+'.txt'
    with open(filename, encoding='latin-1') as f:
        c = f.readlines()
        leng = len(c)
        leng = round(leng*.5)
        c = c[leng:]
        """print(len(c))
        c = [x for x in c if x != '\n']
        c = [y for y in c if len(y) > 50]"""
        for element in c:
            if 'references' in element.lower():
                a = c.index(element)
                c = c[a:]
                break
        c = [x for x in c if len(x) > 50]
        c = c[:number]
        new = [(item, val) for item in c]
        if len(new) < 10:
            print(len(new), number, val)
        df = pd.DataFrame(new)
        vals = str(val)
        newfile = vals + '.csv'
        df.to_csv(newfile)
        path1 = '/Users/Avi/Documents/' + newfile
        path2 = '/Users/Avi/Documents/' + newfile
        os.rename(path1, path2)
            
        

print(datetime.now() - startTime)


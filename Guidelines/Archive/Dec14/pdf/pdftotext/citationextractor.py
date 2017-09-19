from bs4 import BeautifulSoup
import re
import pandas as pd
from datetime import datetime
import os
"""Extract single line references from text documents. More efficient if method 
to determine position of final reference is known"""
startTime = datetime.now()
d = os.listdir('/Users/avi/Documents/Dec14/pdf/pdftotext')
uid = file['uid']
for x in d:
    x = str(x)
    if x[-4:] == '.txt':
        uid = x[:-4]
        with open(x, encoding='latin-1') as f:
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
            #new = [(item, val) for item in c]
            #if len(c) < 10:
            #    print(len(c), number, val)
            df = pd.DataFrame(c)
            #vals = str(val)
            newfile = uid + '.csv'
            df.to_csv(newfile)
            path1 = '/Users/Avi/Documents/use/codes/' + newfile
            path2 = '/Users/Avi/Documents/use/codes/refs/' + newfile
            os.rename(path1, path2)    
        

print(datetime.now() - startTime)


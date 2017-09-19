import pandas as pd

data = pd.read_csv('wos1.csv')
data = data['WOS']
with open('allwos.txt', 'w') as f:
    for i in data:
        i = 'WOS:000'+i
        f.write(i)
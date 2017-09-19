# coding=utf-8

'''
This module finds PMIDs that map Clinical Guideline UIDs.

Author: Avi, Lingtian "Lindsay" Wan, Samet Keserci
Create Date: 02/10/2016
Modified: 05/20/2016, Lindsay Wan, added documentation
Revised:8/1/2016, Samet Keserci, revised whole code for the change in AHRQ website.
'''

from bs4 import BeautifulSoup as bs
import re
import lxml
import urllib2 # -- for Python 2.7 use only. For 3.4 use urllib.request
import csv
import pandas as pd
from datetime import datetime
import time
import random

startTime = datetime.now()
count = 0
data = pd.read_csv('ngc_uid_link.csv', header=None)
uid_link = data[0]
hyper_link = []
ttnum = len(uid_link)
csv_open = open('uid_to_pmid.csv', 'w')
csv_write = csv.writer(csv_open)
exception_count = 0
for urls in uid_link:
    count += 1

    try:
        req = urllib2.Request(url=urls, headers={'User-Agent':'NIH_pmidextractor'})
        resp = urllib2.urlopen(req)
    except:
        exception_count +=1
        print("!!! Exception thrown at following url : ")
        print(urls)
        # wait a couple of seconds and retry
        time.sleep(random.randint(5,10))
        req = urllib2.Request(url=urls, headers={'User-Agent':'NIH_pmidextractor'})
        resp = urllib2.urlopen(req)


    info = resp.read()
    soup = bs(info, 'lxml')
    uid = int(urls[44:])
    print ("Processing " + str(count) + "/" + str(ttnum) + ": UID: " + \
           str(uid))

    div_list = soup.find_all('div', attrs={'class':'accordion-panel is-active'})
    if div_list is not None:
        for div in div_list:
            h3 = div.find('h3');
            if h3.text == 'Bibliographic Source(s)':
                td = div.find('td')
                if td is not None:
                    link = td.find('a')
                    if link is not None:
                        if 'PubMed' in link:
                            hyper_link = re.findall(r'href=(.*)"', str(link))
                            hyper_link = str(hyper_link)
                            if 'list_uids' in hyper_link:
                                index = hyper_link.index('list_uids') + 10
                                index2 = hyper_link.index(' ')
                                pmid = hyper_link[index:index2-1]
                                csv_write.writerow((uid, pmid))
                                print ("Mapped: UID: " + str(uid) + " to PMID: " \
                                       + str(pmid))
                                break


csv_open.close()
print("Total time: " + str(datetime.now() - startTime))
print("Total number of exception:")
print(exception_count)
print("exited from pmidextractor_py. Next updating the tables")

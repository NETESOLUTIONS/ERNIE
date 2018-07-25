# scopus_query.py
# This script uses strings from stdin and queries SCOPUS author search for the top 10 author results
# input must come in the form "name,award_number,first_year" where 'name' is in the form "first_name last_name"

# Author : VJ Davey
import sys ; from time import sleep
from lxml import etree
import urllib2 as ul
import re

apikey=#INSERT APIKEY HERE
print "surname,given_name,author_id,award_number,first_year,manual_selection,query"
for line in sys.stdin:
    line = line.strip('\n')
    name = line.split(',')[1]; award_number=line.split(',')[0]; first_year=line.split(',')[2]
    first_name = ' '.join(name.split(' ')[0:-1]); last_name = name.split(' ')[-1]; og_first_name=first_name; og_last_name=last_name
    last_name=re.sub(r'[\.\-\s]','%20',last_name); first_name=re.sub(r'[\.\-\s]','%20',first_name)
    query="https://api.elsevier.com/content/search/author/?start=0&query=AUTHLASTNAME(%s)AUTHFIRST(%s)&httpAccept=application/xml&apiKey=%s"%(last_name,first_name,apikey)
    #print query
    search_results=etree.fromstring(ul.urlopen(query).read())
    entries=search_results.xpath("//*[local-name()='entry']")

    for entry in entries[:10]:
        author_id=next(iter(etree.ElementTree(entry).xpath("//*[local-name()='identifier']/text()")),"").strip()
        if author_id != "":
            print ("\"%s\",\"%s\",%s,%s,%s,0,\"%s\""%(og_last_name, og_first_name, author_id.split(":")[1],award_number,first_year, query)).encode('utf8')
        else:
            print ("\"%s\",\"%s\",%s,%s,%s,0,\"%s\""%(og_last_name, og_first_name, "NO AUTHOR ID",award_number,first_year, query)).encode('utf8')

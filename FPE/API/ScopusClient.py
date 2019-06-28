import base64
import json
import urllib.error
import urllib.parse
import urllib.request

class ScopusClient:

    api_key = None
    inst_token = None

    def __init__(s,api_key,inst_token=None):
        s.api_key = api_key
        s.inst_token = inst_token
        s.url = "https://api.elsevier.com/content"
        s.headers = {
            'accept': 'application/json',
            'X-ELS-Apikey': api_key,
            'X-ELS-ResourceVersion': 'new'
        }
        if inst_token: s.headers['X-ELS-Insttoken'] = inst_token

    def submit(s, search):
        data = {}
        buffer = ""
        req = urllib.request.Request(url=search, headers=s.headers)
        try:
            f = urllib.request.urlopen(req)
            buffer = f.read().decode("utf-8")
            data = json.loads(buffer)
        except urllib.error.HTTPError as e:
            print("Problem with Search '{}'".format(search))
            print(format(e) + buffer)
        return data

    def search_pubs(s, query, count=25, view='COMPLETE', sort='-coverDate'):
        query = urllib.parse.quote(query, safe='()/+')
        search = s.url + "/search/scopus?view={}&sort={}&count={}&query=".format(view, sort, count) + query
        return s.submit(search)

    def get_author_pubs(s, scopus_id, count=25, year='1900', doctypes=['ar', 'cp']):
        query = "au-id({})".format(scopus_id)
        if year: query += " and (pubyear > {})".format(year)
        if doctypes:
            if isinstance(doctypes, str): doctypes = [doctypes]
            query += " and ({})".format(" or ".join(["doctype({})".format(t) for t in doctypes]))
        print("Scopus Search: '{}'".format(query))
        data = s.search_pubs(query, count)
        pubs = []
        if 'search-results' in data:
            entries = data['search-results']['entry']
            for entry in entries:
                eid = entry.get('eid', None)
                if eid:
                    title = entry['dc:title']
                    subtype = entry['subtypeDescription']
                    abstract = entry.get('dc:description', '').strip()
                    if abstract:
                        pubs.append({
                            'EID': eid,
                            'Title': title,
                            'Keywords': [k.strip() for k in entry.get('authkeywords', "").split('|')],
                            'SubType': subtype,
                            'Date': entry['prism:coverDate'],
                            'Abstract': abstract
                        })
                    else: print("No Abstract for {}: '{}'".format(subtype, title))
        return pubs

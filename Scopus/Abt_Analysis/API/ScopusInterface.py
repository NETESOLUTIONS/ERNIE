'''
ScopusInterface.py

    This helper module interfaces with various Scopus APIs including the author, abstract, and affiliation retrieval APIs
     as well as the SCOPUS search API. A subset of the XML fields are returned in python dictionary format.
    Due to API throttling, it is important to ensure the sleep_time variable is set to a value which would not cause
     the API to choke on response

 Author: VJ Davey
'''

from lxml import etree
import sys
from time import sleep
import pandas as pd
from copy import deepcopy
try:
    from urllib import urlencode
    from urllib2 import urlopen
except ImportError:
    from urllib.parse import urlencode
    from urllib.request import urlopen

sleep_time=0.1; inc_step=20
abstract_retrieval_header="https://api.elsevier.com/content/abstract/"
scopus_search_header="https://api.elsevier.com/content/search/scopus"
author_search_header="https://api.elsevier.com/content/search/author/"
affiliation_retrieval_header="https://api.elsevier.com/content/affiliation/affiliation_id/"
author_retrieval_header="https://api.elsevier.com/content/author/author_id/"
query_params_base={'httpAccept':'application/xml', 'apiKey':''}

# Collect document information given a SCOPUS ID
def abstract_retrieval(document_id, api_key, id_type='scopus_id',view='FULL', query_params=deepcopy(query_params_base),query_return=False):
    query_params.update({'apiKey':api_key, 'view':view})
    document_html=abstract_retrieval_header+"{}/{}?".format(id_type,document_id)+urlencode(query_params)
    print("Query string: \"{}\"".format(document_html))
    try:
        xml_document=etree.fromstring(urlopen(document_html).read())
    except Exception as e:
        print(e)
        print("QUERY_ERROR: could not process query string: {}".format(document_html))
        return None
    data_dict={}
    # Parse XML returned from Abstract Retrieval API's FULL view
    data_dict['scopus_id']=next(iter(xml_document.xpath("//*[local-name()='coredata']/*[local-name()='identifier']/text()")),"").strip().replace("\"","\'").replace("SCOPUS_ID:","")
    data_dict['title']="\""+next(iter(xml_document.xpath("//*[local-name()='coredata']/*[local-name()='title']/text()")),"").strip().replace("\"","\'")+"\""
    data_dict['document_type']="\""+next(iter(xml_document.xpath("//*[local-name()='coredata']/*[local-name()='aggregationType']/text()")),"").strip().replace("\"","\'")+"\""
    data_dict['scopus_cited_by_count']=next(iter(xml_document.xpath("//*[local-name()='coredata']/*[local-name()='citedby-count']/text()")),"").strip()
    data_dict['process_cited_by_count']=""
    data_dict['publication_name']="\""+next(iter(xml_document.xpath("//*[local-name()='coredata']/*[local-name()='publicationName']/text()")),"").strip().replace("\"","\'")+"\""
    data_dict['publisher']="\""+next(iter(xml_document.xpath("//*[local-name()='coredata']/*[local-name()='publisher']/text()")),"").strip().replace("\"","\'")+"\""
    data_dict['issn']=next(iter(xml_document.xpath("//*[local-name()='coredata']/*[local-name()='issn']/text()")),"").strip()
    data_dict['volume']=next(iter(xml_document.xpath("//*[local-name()='coredata']/*[local-name()='volume']/text()")),"").strip()
    data_dict['page_range']="\""+next(iter(xml_document.xpath("//*[local-name()='coredata']/*[local-name()='pageRange']/text()")),"").strip().replace("\"","\'")+"\""
    data_dict['cover_date']=next(iter(xml_document.xpath("//*[local-name()='coredata']/*[local-name()='coverDate']/text()")),"").strip()
    if data_dict['cover_date'] != '':
        data_dict['publication_year']=data_dict['cover_date'].split('-')[0]
        data_dict['publication_month']=data_dict['cover_date'].split('-')[1]
        data_dict['publication_day']=data_dict['cover_date'].split('-')[2]
    data_dict['pubmed_id']=next(iter(xml_document.xpath("//*[local-name()='coredata']/*[local-name()='pubmed-id']/text()")),"").strip()
    data_dict['doi']=next(iter(xml_document.xpath("//*[local-name()='coredata']/*[local-name()='doi']/text()")),"").strip()
    data_dict['description']="\""+' '.join(xml_document.xpath("//*[local-name()='coredata']/*[local-name()='description']/abstract/*/text()")).strip().replace("\"","\'")+"\""
    data_dict['scopus_first_author_id']=next(iter(xml_document.xpath("//*[local-name()='coredata']/*[local-name()='creator']/*[local-name()='author']/@auid")),"").strip()
    data_dict['authors']=set(xml_document.xpath("//*[local-name()='authors']/*[local-name()='author']/@auid"))
    data_dict['affiliations']=set(xml_document.xpath("//*[local-name()='affiliation']/@id"))
    data_dict['subject_areas']="\""+','.join(xml_document.xpath("//*[local-name()='subject-areas']/*[local-name()='subject-area']/text()")).strip().replace("\"","\'")+"\""
    data_dict['keywords']="\""+','.join(xml_document.xpath("//*[local-name()='idxterms']/*[local-name()='mainterm']/text()")).strip().replace("\"","\'")+"\""
    data_dict['cited_scopus_ids']=set(xml_document.xpath("//*[local-name()='bibliography']/reference/ref-info/refd-itemidlist/itemid[@idtype='SGR']/text()"))
    if query_return==True:
        return data_dict,document_html
    return data_dict

# Collect citing documents given a SCOPUS ID
def citing_scopus_id_search(scopus_id,api_key,low_bound=1990,high_bound=2019,search_result_limit=4999,query_params=deepcopy(query_params_base)):
    data_dict={'citing_scopus_ids':[]}
    query_params.update({'apiKey':api_key, 'field':'identifier', 'query':'refscp({})'.format(scopus_id)})
    for period in ["{}-{}".format(i,i+1) for i in range (low_bound,high_bound)]:
        query_params.update({'date':period})
        citing_documents_html=scopus_search_header+"?"+urlencode(query_params)
        print("Submitting query string: \"{}\"".format(citing_documents_html))
        try:
            xml_citing_documents=etree.fromstring(urlopen(citing_documents_html).read())
            total_citing_documents=next(iter(xml_citing_documents.xpath("//*[local-name()='totalResults']/text()")),"")
            if total_citing_documents != "":
                data_dict['citing_scopus_ids']+=xml_citing_documents.xpath("//*[local-name()='entry']/*[local-name()='identifier']/text()")
                for i in range (0, min(int(total_citing_documents)+1,search_result_limit), inc_step):
                    sleep(sleep_time)
                    query_params.update({'start':i})
                    citing_documents_chunk_html=scopus_search_header+"?"+urlencode(query_params)
                    print("Submitting query string: \"{}\"".format(citing_documents_chunk_html))
                    try:
                        xml_citing_documents_chunk=etree.fromstring(urlopen(citing_documents_chunk_html).read())
                        data_dict['citing_scopus_ids']+=xml_citing_documents_chunk.xpath("//*[local-name()='entry']/*[local-name()='identifier']/text()")
                    except Exception as e:
                        print(e)
                        print("QUERY_ERROR: could not process query string: \"%s\""%(citing_documents_chunk_html))
        except Exception as e:
            print(e)
            print("QUERY_ERROR: could not process query string: \"%s\""%(citing_documents_html))
    data_dict['citing_scopus_ids']=list(set(data_dict['citing_scopus_ids'])); data_dict['citing_scopus_ids']=[i.replace("SCOPUS_ID:","") for i in data_dict['citing_scopus_ids']]
    data_dict['process_cited_by_count']=len(data_dict['citing_scopus_ids'])
    return data_dict

# Collect affiliation information given an affiliation ID
def affiliation_retrieval(affiliation_id,api_key,view="STANDARD",query_params=deepcopy(query_params_base),query_return=False):
    query_params.update({'apiKey':api_key, 'view':view})
    affiliation_html=affiliation_retrieval_header+"{}?".format(affiliation_id)+urlencode(query_params)
    print("Submitting query string: \"{}\"".format(affiliation_html))
    try:
        xml_affiliations=etree.fromstring(urlopen(affiliation_html).read())
    except Exception as e:
        print(e)
        print("QUERY_ERROR: could not process query string: {}".format(affiliation_html))
        return None
    data_dict={}
    data_dict['affiliation_id']=affiliation_id
    data_dict['parent_affiliation_id']=next(iter(xml_affiliations.xpath("//institution-profile/@parent")),"").strip()
    data_dict['scopus_author_count']=next(iter(xml_affiliations.xpath("//coredata/author-count/text()")),"").strip()
    data_dict['scopus_document_count']=next(iter(xml_affiliations.xpath("//coredata/document-count/text()")),"").strip()
    data_dict['affiliation_name']="\""+next(iter(xml_affiliations.xpath("//affiliation-name/text()")),"").strip().replace("\"","\'")+"\""
    data_dict['address']="\""+next(iter(xml_affiliations.xpath("//address/address-part/text()")),"").strip().replace("\"","\'")+"\""
    data_dict['city']="\""+next(iter(xml_affiliations.xpath("//address/city/text()")),"").strip().replace("\"","\'")+"\""
    data_dict['state']="\""+next(iter(xml_affiliations.xpath("//address/state/text()")),"").strip().replace("\"","\'")+"\""
    data_dict['country']="\""+next(iter(xml_affiliations.xpath("//address/country/text()")),"").strip().replace("\"","\'")+"\""
    data_dict['postal_code']="\""+next(iter(xml_affiliations.xpath("//address/postal-code/text()")),"").strip().replace("\"","\'")+"\""
    data_dict['organization_type']="\""+next(iter(xml_affiliations.xpath("//org-type/text()")),"").strip().replace("\"","\'")+"\""
    if query_return==True:
        return data_dict,affiliation_html
    return data_dict

# Collect author information given an author_id
def author_retrieval(author_id, api_key, view="ENHANCED",query_params=deepcopy(query_params_base),query_return=False):
    query_params.update({'apiKey':api_key, 'view':view})
    auth_html=author_retrieval_header+"{}?".format(author_id)+urlencode(query_params)
    print("Submitting query string: \"{}\"".format(auth_html))
    try:
        xml_auth=etree.fromstring(urlopen(auth_html).read())
    except Exception as e:
        print(e)
        print("QUERY_ERROR: could not process query string: {}".format(auth_html))
        return None
    data_dict={}
    data_dict['author_id']=author_id
    data_dict['indexed_name']=next(iter(xml_auth.xpath("//author-profile/preferred-name/indexed-name/text()")),"").strip()
    data_dict['surname']=next(iter(xml_auth.xpath("//author-profile/preferred-name/surname/text()")),"").strip()
    data_dict['given_name']=next(iter(xml_auth.xpath("//author-profile/preferred-name/given-name/text()")),"").strip()
    data_dict['initials']=next(iter(xml_auth.xpath("//author-profile/preferred-name/initials/text()")),"").strip()
    data_dict['scopus_co_author_count']=next(iter(xml_auth.xpath("//coauthor-count/text()")),"").strip()
    data_dict['scopus_document_count']=next(iter(xml_auth.xpath("//coredata/document-count/text()")),"").strip()
    data_dict['scopus_citation_count']=next(iter(xml_auth.xpath("//coredata/citation-count/text()")),"").strip()
    data_dict['scopus_cited_by_count']=next(iter(xml_auth.xpath("//coredata/cited-by-count/text()")),"").strip()
    data_dict['alias_author_id']=next(iter(xml_auth.xpath("//*[local-name()='alias']/*/text()")),"").strip()
    data_dict['affiliations']=set(xml_auth.xpath("//*[local-name()='affiliation-history']/*[local-name()='affiliation']/@affiliation-id")+xml_auth.xpath("//*[local-name()='affiliation-history']/*[local-name()='affiliation']/@parent"))
    data_dict['process_co_author_count']=''; data_dict['process_document_count']=''
    if query_return==True:
        return data_dict,auth_html
    return data_dict

def iter_search_results(result_xml,fields):
    for entry in result_xml.xpath("//*[local-name()='entry']"):
        row={ field:next(iter(etree.ElementTree(entry).xpath("//*[local-name()='{}']/text()".format(field))),"").strip() for field in fields}
        yield pd.DataFrame([row])

# Collect a list of documents by an author given search terms
def document_search(query,api_key,search_result_limit=4999,view="STANDARD",field="title,identifier",query_params=deepcopy(query_params_base),query_return=False, result_count_only=False):
    query_params.update({'apiKey':api_key, 'field':field, 'query':query,'view':view})
    document_search_html=scopus_search_header+"?"+urlencode(query_params)
    print("Submitting query string: \"{}\"".format(document_search_html))
    try:
        xml_auth_documents=etree.fromstring(urlopen(document_search_html).read())
    except Exception as e:
        print(e)
        print("QUERY_ERROR: could not process query string: {}".format(document_search_html))
        return None
    data_dict={'documents':pd.DataFrame(columns=field.split(','))}
    total = next(iter(xml_auth_documents.xpath("//*[local-name()='totalResults']/text()")),"")
    if not result_count_only:
        if total != "":
            for i in range (0, min(int(total)+1,search_result_limit), inc_step):
                sleep(sleep_time)
                query_params.update({'start':i})
                documents_chunk_html=scopus_search_header+"?"+urlencode(query_params)
                print('Query string: \"%s\"'%(documents_chunk_html))
                try:
                    xml_documents_chunk=etree.fromstring(urlopen(documents_chunk_html).read())
                    for row in iter_search_results(xml_documents_chunk,field.split(',')):
                        data_dict['documents']=data_dict['documents'].append(row,ignore_index=True)
                except Exception as e:
                    print(e)
                    print("QUERY_ERROR: could not process query string: \"%s\""%(documents_chunk_html))
    data_dict['documents']=data_dict['documents'].drop_duplicates().reset_index(drop=True)
    data_dict['process_document_count']=len(data_dict['documents'])
    data_dict['totalResults']=total
    if query_return==True:
        return data_dict,document_search_html
    return data_dict

# Collect a list of potential author IDs for an author given search terms
def author_search(auth_first,auth_last,api_key,search_result_limit=10,query_params=deepcopy(query_params_base),query_return=False):
    query_params.update({'apiKey':api_key,'query':'AUTHFIRST({})AUTHLASTNAME({})'.format(auth_first,auth_last)})
    author_search_html=author_search_header+"?"+urlencode(query_params)
    print("Submitting query string: \"{}\"".format(author_search_html))
    try:
        xml_author_search=etree.fromstring(urlopen(author_search_html).read())
    except Exception as e:
        print(e)
        print("QUERY_ERROR: could not process query string: {}".format(author_search_html))
        return None
    data_dict={'authors':[]}
    total = next(iter(xml_author_search.xpath("//*[local-name()='totalResults']/text()")),"")
    data_dict['authors']+=xml_author_search.xpath("//*[local-name()='entry']/*[local-name()='identifier']/text()")
    if total != "":
        for i in range (0, min(int(total)+1,search_result_limit), inc_step):
            sleep(sleep_time)
            query_params.update({'start':i})
            authors_chunk_html=author_search_header+"?"+urlencode(query_params)
            print('Query string: \"%s\"'%(authors_chunk_html))
            try:
                xml_authors_chunk=etree.fromstring(urlopen(authors_chunk_html).read())
                data_dict['authors']+=xml_authors_chunk.xpath("//*[local-name()='entry']/*[local-name()='identifier']/text()")
            except Exception as e:
                print(e)
                print("QUERY_ERROR: could not process query string: \"%s\""%(authors_chunk_html))
    data_dict['authors']=set(data_dict['authors']);data_dict['authors']=[i.replace("AUTHOR_ID:", "") for i in data_dict['authors']]; data_dict['process_auth_count']=len(data_dict['authors'])
    if query_return==True:
        return data_dict,author_search_html
    return data_dict

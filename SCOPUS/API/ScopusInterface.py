'''
ScopusInterface.py

    This script interfaces with various Scopus APIs including the author, abstract, and affiliation retrieval APIs
     as well as the SCOPUS search API. A subset of the XML fields are returned in python dictionary format.
    Due to API throttling, it is important to ensure the sleep_time variable is set to a value which would not cause
     the API to choke on response

 Author: VJ Davey
'''

from lxml import etree
import sys
import urllib2 as ul
import urllib
from time import sleep
from copy import deepcopy

sleep_time=0.1; inc_step=20
abstract_retrieval_header="https://api.elsevier.com/content/abstract/"
scopus_search_header="https://api.elsevier.com/content/search/scopus"
affiliation_retrieval_header="https://api.elsevier.com/content/affiliation/affiliation_id/"
author_retrieval_header="https://api.elsevier.com/content/author/author_id/"
query_params_base={'httpAccept':'application/xml', 'apiKey':''}

# Collect document information given a SCOPUS ID
def abstract_retrieval(document_id, api_key, id_type='scopus_id',view='FULL', query_params=deepcopy(query_params_base)):
    query_params.update({'apiKey':api_key, 'view':view})
    document_html=abstract_retrieval_header+"{}/{}?".format(id_type,document_id)+urllib.urlencode(query_params)
    print "Query string: \"{}\"".format(document_html)
    try:
        xml_document=etree.fromstring(ul.urlopen(document_html).read())
    except Exception as e:
        print e
        print "QUERY_ERROR: could not process query string: {}".format(document_html)
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
    return data_dict

# Collect citing documents given a SCOPUS ID
def citing_scopus_id_search(scopus_id,api_key,low_bound=1990,high_bound=2019,query_params=deepcopy(query_params_base)):
    data_dict={'citing_scopus_ids':[]}
    query_params.update({'apiKey':api_key, 'field':'identifier', 'query':'refscp({})'.format(scopus_id)})
    for period in ["{}-{}".format(i,i+1) for i in range (low_bound,high_bound)]:
        query_params.update({'date':period})
        citing_documents_html=scopus_search_header+"?"+urllib.urlencode(query_params)
        print "Submitting query string: \"{}\"".format(citing_documents_html)
        try:
            xml_citing_documents=etree.fromstring(ul.urlopen(citing_documents_html).read())
            total_citing_documents=next(iter(xml_citing_documents.xpath("//*[local-name()='totalResults']/text()")),"")
            if total_citing_documents != "":
                data_dict['citing_scopus_ids']+=xml_citing_documents.xpath("//*[local-name()='entry']/*[local-name()='identifier']/text()")
                for i in range (0, int(total_citing_documents)+1, inc_step):
                    sleep(sleep_time)
                    query_params.update({'start':i})
                    citing_documents_chunk_html=scopus_search_header+"?"+urllib.urlencode(query_params)
                    print "Submitting query string: \"{}\"".format(citing_documents_chunk_html)
                    try:
                        xml_citing_documents_chunk=etree.fromstring(ul.urlopen(citing_documents_chunk_html).read())
                        data_dict['citing_scopus_ids']+=xml_citing_documents_chunk.xpath("//*[local-name()='entry']/*[local-name()='identifier']/text()")
                    except Exception as e:
                        print e
                        print "QUERY_ERROR: could not process query string: \"%s\""%(citing_documents_chunk_html)
        except Exception as e:
            print e
            print "QUERY_ERROR: could not process query string: \"%s\""%(citing_documents_html)
    data_dict['citing_scopus_ids']=list(set(data_dict['citing_scopus_ids'])); data_dict['citing_scopus_ids']=[i.replace("SCOPUS_ID:","") for i in data_dict['citing_scopus_ids']]
    data_dict['process_cited_by_count']=len(data_dict['citing_scopus_ids'])
    return data_dict

# Collect affiliation information given an affiliation ID
def affiliation_retrieval(affiliation_id,api_key,view="STANDARD",query_params=deepcopy(query_params_base)):
    query_params.update({'apiKey':api_key, 'view':view})
    affiliation_html=affiliation_retrieval_header+"{}?".format(affiliation_id)+urllib.urlencode(query_params)
    print "Submitting query string: \"{}\"".format(affiliation_html)
    try:
        xml_affiliations=etree.fromstring(ul.urlopen(affiliation_html).read())
    except Exception as e:
        print e
        print "QUERY_ERROR: could not process query string: {}".format(affiliation_html)
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
    return data_dict

# Collect author information given an author_id
def author_retrieval(author_id, api_key, view="ENHANCED",query_params=deepcopy(query_params_base)):
    query_params.update({'apiKey':api_key, 'view':view})
    auth_html=author_retrieval_header+"{}?".format(author_id)+urllib.urlencode(query_params)
    print "Submitting query string: \"{}\"".format(auth_html)
    try:
        xml_auth=etree.fromstring(ul.urlopen(auth_html).read())
    except Exception as e:
        print e
        print "QUERY_ERROR: could not process query string: {}".format(auth_html)
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
    return data_dict

# Collect a list of documents by an author given search terms
def document_search(query,api_key, field="title,identifier",query_params=deepcopy(query_params_base)):
    query_params.update({'apiKey':api_key, 'field':field, 'query':query})
    document_search_html=scopus_search_header+"?"+urllib.urlencode(query_params)
    print "Submitting query string: \"{}\"".format(document_search_html)
    try:
        xml_auth_documents=etree.fromstring(ul.urlopen(document_search_html).read())
    except Exception as e:
        print e
        print "QUERY_ERROR: could not process query string: {}".format(document_search_html)
        return None
    data_dict={'documents':[]}
    total = next(iter(xml_auth_documents.xpath("//*[local-name()='totalResults']/text()")),"")
    data_dict['documents']+=xml_auth_documents.xpath("//*[local-name()='entry']/*[local-name()='identifier']/text()")
    if total != "":
        for i in range (0, int(total)+1, inc_step):
            sleep(sleep_time)
            query_params.update({'start':i})
            documents_chunk_html=scopus_search_header+"?"+urllib.urlencode(query_params)
            print 'Query string: \"%s\"'%(documents_chunk_html)
            try:
                xml_documents_chunk=etree.fromstring(ul.urlopen(documents_chunk_html).read())
                data_dict['documents']+=xml_documents_chunk.xpath("//*[local-name()='entry']/*[local-name()='identifier']/text()")
            except Exception as e:
                print e
                print "QUERY_ERROR: could not process query string: \"%s\""%(documents_chunk_html)
    data_dict['documents']=set(data_dict['documents']);data_dict['documents']=[i.replace("SCOPUS_ID:", "") for i in data_dict['documents']]; data_dict['process_document_count']=len(data_dict['documents'])
    return data_dict

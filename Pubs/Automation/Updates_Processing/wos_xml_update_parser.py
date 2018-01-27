# coding=utf-8

'''
Function:   	This is a parser to extract the WOS XML publications data and generate 7 CSV files:
                    1.	wos_xml_file_name_publication.csv
                    2.	wos_xml_file_name_reference.csv
                    3.	wos_xml_file_name_grant.csv
                    4.	wos_xml_file_name_address.csv
                    5.	wos_xml_file_name_author.csv
                    6.	wos_xml_file_name_dois.csv
                    7.	wos_xml_file_name_abstract.csv
                    8.	wos_xml_file_name_keyword.csv
                    9.	wos_xml_file_name_title.csv

USAGE:  	python wos_xml_parser.py -filename file_name -csv_dir csv_file_directory
Author: 	Shixin Jiang
Date:		11/24/2015
Changes:	To load raw data in parallel, a constant sequence number is assigned to each table's seq. 3/9/2016, Shixin
'''


import re
import csv
import exceptions
import time
import os.path
import datetime
import string
import psycopg2
import sys

from lxml import etree

# Check if the file name is provided, otherwise the program will stop.
in_arr = sys.argv
if '-filename' not in in_arr:
    print "No filename"
    raise NameError('error: file name is not provided')
else:
    input_filename = in_arr[in_arr.index('-filename') + 1]

# Check if the CSV file directory is provided, otherwise the program will stop.
if '-csv_dir' not in in_arr:
    print "No CSV file directory"
    raise NameError('error: CSV file directory is not provided')
else:
    input_csv_dir= in_arr[in_arr.index('-csv_dir') + 1]

xml_csv_dir = input_csv_dir+input_filename[:-4]+'/'
try:
    os.stat(xml_csv_dir)
except:
    os.mkdir(xml_csv_dir)

r_publication_seq = 0
r_reference_seq = 0
r_grant_seq = 0
r_doi_seq = 0
r_addr_seq = 0
r_author_seq = 0
r_abstract_seq = 0
r_keyword_seq = 0
r_title_seq = 0

root = etree.parse(input_csv_dir+input_filename).getroot()
url='{http://scientific.thomsonreuters.com/schema/wok5.4/public/FullRecord}'

# Create CSV files
csvfile_publication = open(xml_csv_dir+input_filename[:-4]+'_publication.csv', 'w')
csvfile_reference = open(xml_csv_dir+input_filename[:-4]+'_reference.csv', 'w')
csvfile_abstract = open(xml_csv_dir+input_filename[:-4]+'_abstract.csv', 'w')
csvfile_address = open(xml_csv_dir+input_filename[:-4]+'_address.csv', 'w')
csvfile_author = open(xml_csv_dir+input_filename[:-4]+'_author.csv', 'w')
csvfile_dois = open(xml_csv_dir+input_filename[:-4]+'_dois.csv', 'w')
csvfile_grant = open(xml_csv_dir+input_filename[:-4]+'_grant.csv', 'w')
csvfile_keyword = open(xml_csv_dir+input_filename[:-4]+'_keyword.csv', 'w')
csvfile_title = open(xml_csv_dir+input_filename[:-4]+'_title.csv', 'w')

# Create a file to load CSV data to PostgreSQL
csvfile_load = open(xml_csv_dir+input_filename[:-4]+'_load.pg', 'w')

writer_pub = csv.writer(csvfile_publication)
writer_ref = csv.writer(csvfile_reference)
writer_grant = csv.writer(csvfile_grant)
writer_dois = csv.writer(csvfile_dois)
writer_abstract = csv.writer(csvfile_abstract)
writer_address = csv.writer(csvfile_address)
writer_author = csv.writer(csvfile_author)
writer_keyword = csv.writer(csvfile_keyword)
writer_title = csv.writer(csvfile_title)


#start to parse XML file by REC (a full record schema in WOS XML file)
for REC in root:
    # parse publications and create csv file
    r_publication = dict()
    r_publication_seq += 1
    r_publication['id'] = r_publication_seq
    r_publication['source_id'] = REC.find(url+'UID').text

    pub_info =  REC.find('.//'+url+'pub_info')
    r_publication['source_type'] = pub_info.get('pubtype')

    r_publication['source_title'] = ''
    source_title =  REC.find('.//'+url+"title[@type='source']")
    if source_title is not None:
        if source_title.text is not None:
            r_publication['source_title'] =  source_title.text.encode('utf-8')

    r_publication['has_abstract'] = pub_info.get('has_abstract')
    r_publication['publication_year'] = pub_info.get('pubyear')
    r_publication['issue'] = pub_info.get('issue')
    r_publication['volume'] = pub_info.get('vol')
    r_publication['pubmonth'] = pub_info.get('pubmonth')
    r_publication['publication_date'] = pub_info.get('sortdate')
    r_publication['coverdate'] = pub_info.get('coverdate')
    page_info = pub_info.find(url+'page')
    r_publication['begin_page'] = ''
    r_publication['end_page'] = ''
    if page_info is not None:
        r_publication['begin_page'] = page_info.get('begin')
        r_publication['end_page'] = page_info.get('end')

    r_publication['document_title'] = ''
    document_title =  REC.find('.//'+url+"title[@type='item']")
    if document_title is not None:
        if document_title.text is not None:
            r_publication['document_title'] = document_title.text.\
                                              encode('utf-8')

    r_publication['document_type'] = ''
    document_type =  REC.find('.//'+url+'doctype')
    if document_type is not None:
        if document_type.text is not None:
            r_publication['document_type'] = document_type.text

    r_publication['publisher_name']  = ''
    publisher_name = REC.find('.//'+url+"name[@role='publisher']")
    if publisher_name is not None:
        pub_name = publisher_name.find('.//'+url+'full_name')
        if pub_name is not None:
            if pub_name.text is not None:
                r_publication['publisher_name']  =  pub_name.text.\
                                                    encode('utf-8')
    r_publication['publisher_address'] = ''
    pub_address_no =  REC.find('.//'+url+"address_spec[@addr_no='1']")
    if pub_address_no is not None:
        publisher_address =  pub_address_no.find('.//'+url+'full_address')
        if publisher_address is not None:
            if publisher_address.text is not None:
                r_publication['publisher_address'] =  publisher_address.text.\
                                                      encode('utf-8')

    r_publication['language'] = ''
    languages = REC.find('.//'+url+'languages')
    if languages is not None:
        language = languages.find('.//'+url+'language')
        if language is not None:
            if language.text is not None:
                r_publication['language'] = language.text.encode('utf-8')

    r_publication['edition'] = REC.find('.//'+url+'edition').get('value')
    r_publication['source_filename'] = input_filename
    r_publication['created_date'] = datetime.date.today()
    r_publication['last_modified_date'] = datetime.date.today()

    # write each record to a CSV file for wos_publications table
    writer_pub.writerow((r_publication['id'], r_publication['source_id'], \
        r_publication['source_type'], r_publication['source_title'], \
        r_publication['language'], r_publication['document_title'], \
        r_publication['document_type'], r_publication['has_abstract'], \
        r_publication['issue'], r_publication['volume'], \
        r_publication['begin_page'], r_publication['end_page'], \
        r_publication['publisher_name'], r_publication['publisher_address'], \
        r_publication['publication_year'], r_publication['publication_date'], \
        r_publication['created_date'], r_publication['last_modified_date'], \
        r_publication['edition'], r_publication['source_filename']))

    # parse grants in funding acknowledgements for each publication
    r_grant = dict()
    r_grant['source_id'] = r_publication['source_id']

    r_grant['funding_ack'] = ''
    FUNDING_ACK = REC.find('.//'+url+'fund_text')
    if FUNDING_ACK is not None:  # if funding acknowledgement exists, then extract the grant(s) data
        funding_ack_p = FUNDING_ACK.find('.//'+url+'p')
        if funding_ack_p is not None:
            if funding_ack_p.text is not None:
                r_grant['funding_ack'] = funding_ack_p.text.encode('utf-8')

    for grant in REC.findall('.//'+url+'grant'):
        r_grant['grant_agency'] = ''
        grant_agency = grant.find('.//'+url+'grant_agency')
        if grant_agency is not None:
            if grant_agency.text is not None:
                r_grant['grant_agency'] = grant_agency.text.encode('utf-8')

        grant_ids = grant.find('.//'+url+'grant_ids')
        if grant_ids is not None:
            for grant_id in grant_ids.findall('.//'+url+'grant_id'):
                r_grant_seq = r_grant_seq + 1
                r_grant['id'] = r_grant_seq
                r_grant['grant_number'] = ''
                if grant_id is not None:
                    if grant_id.text is not None:
                        r_grant['grant_number'] = grant_id.text.encode('utf-8')
                if r_grant['funding_ack'] is not None:
                    writer_grant.writerow((r_grant['id'],r_grant['source_id'],\
                        r_grant['grant_number'],r_grant['grant_agency'],\
                        r_grant['funding_ack'],\
                        r_publication['source_filename']))

    # parse document object identifiers for each publication
    r_dois = dict()
    r_dois['source_id'] = r_publication['source_id']

    IDS = REC.find('.//'+url+'identifiers')
    if IDS is not None:
        for identifier in IDS.findall('.//'+url+'identifier'):
            r_dois['doi'] = None
            id_value = identifier.get('value')
            if id_value is not None:
                r_dois['doi'] = id_value.encode('utf-8')
            r_dois['doi_type'] = ''
            id_type = identifier.get('type')
            if id_type is not None:
                r_dois['doi_type'] = id_type.encode('utf-8')
            # write each doi to CSV file for wos_document_identifiers table
            if r_dois['doi'] is not None:
                r_doi_seq = r_doi_seq + 1
                r_dois['id'] = r_doi_seq
                writer_dois.writerow((r_dois['id'],r_dois['source_id'],\
                    r_dois['doi'],r_dois['doi_type'],\
                    r_publication['source_filename']))

    # parse keyword for each publication
    keywords = REC.find('.//'+url+'keywords_plus')
    if keywords is not None:
        r_keyword = dict()
        r_keyword['source_id'] = r_publication['source_id']
        for keyword in keywords.findall('.//'+url+'keyword'):
            if keyword is not None:
                if keyword.text is not None:
                    r_keyword['keyword'] = keyword.text.encode('utf-8')
                    r_keyword_seq = r_keyword_seq + 1
                    r_keyword['id'] = r_keyword_seq
                    writer_keyword.writerow((r_keyword['id'],\
                        r_keyword['source_id'],r_keyword['keyword'],\
                        r_publication['source_filename']))

    # parse abstract for each publication
    if r_publication['has_abstract'] == 'Y':
        abstracts = REC.find('.//'+url+'abstracts')
        if abstracts is not None:
            r_abst = dict()
            r_abst['source_id'] = r_publication['source_id']
            r_abst['abstract_text'] = ''
            for abstract_text in abstracts.findall('.//'+url+'p'):
                if abstract_text is not None:
                    if abstract_text.text is not None:
                        r_abst['abstract_text'] += abstract_text.text.encode('utf-8')
                        # r_abst['abstract_text'] = abstract_text.text.\
                        #                           encode('utf-8')
                        # r_abstract_seq +=1
                        # r_abst['id'] = r_abstract_seq
                        # writer_abstract.writerow((r_abst['id'],\
                        #     r_abst['source_id'],r_abst['abstract_text'],\
                        #     r_publication['source_filename']))
            writer_abstract.writerow(r_abst['source_id'],r_abst['abstract_text'])

    # parse addresses for each publication

    r_addr = dict()
    r_addr['id'] = {}
    r_addr['source_id'] = {}
    r_addr['addr_name'] = {}
    r_addr['organization'] = {}
    r_addr['suborganization'] = {}
    r_addr['city'] = {}
    r_addr['country'] = {}
    r_addr['zip'] = {}
    addr_no_list = []
    addresses = REC.find('.//'+url+'addresses')
    for addr in addresses.findall('.//'+url+'address_spec'):

        addr_ind = addr.get('addr_no')
        if addr_ind is None:
            addr_ind = 0
        else:
            addr_ind = int(addr_ind)
            # Kepp all addr_no for the following reference by authors
            addr_no_list.append(int(addr_ind))

        r_addr['source_id'][addr_ind] = r_publication['source_id']
        r_addr['addr_name'][addr_ind] = ''
        addr_name = addr.find('.//'+url+'full_address')
        if addr_name is not None:
            if addr_name.text is not None:
                r_addr['addr_name'][addr_ind] = addr_name.text.encode('utf-8')
        r_addr['organization'][addr_ind] = ''
        organization = addr.find('.//'+url+"organization[@pref='Y']")
        if organization is not None:
            if organization.text is not None:
                r_addr['organization'][addr_ind] = organization.text.\
                                                   encode('utf-8')
        r_addr['suborganization'][addr_ind] = ''
        suborganization = addr.find('.//'+url+'suborganization')
        if suborganization is not None:
            if suborganization.text is not None:
                r_addr['suborganization'][addr_ind] = suborganization.text.\
                                                      encode('utf-8')
        r_addr['city'][addr_ind] = ''
        city = addr.find('.//'+url+'city')
        if city is not None:
            if city.text is not None:
                r_addr['city'][addr_ind] = city.text.encode('utf-8')
        r_addr['country'][addr_ind] = ''
        country = addr.find('.//'+url+'country')
        if country is not None:
            if country.text is not None:
                r_addr['country'][addr_ind] = country.text.encode('utf-8')
        r_addr['zip'][addr_ind] = ''
        addr_zip = addr.find('.//'+url+'zip')
        if addr_zip is not None:
            if addr_zip.text is not None:
                r_addr['zip'][addr_ind] = addr_zip.text.encode('utf-8')
        if r_addr['addr_name'][addr_ind] is not None:
            r_addr_seq +=1
            r_addr['id'][addr_ind] = r_addr_seq
            writer_address.writerow((r_addr['id'][addr_ind],\
                r_addr['source_id'][addr_ind],r_addr['addr_name'][addr_ind],\
                r_addr['organization'][addr_ind],\
                r_addr['suborganization'][addr_ind],r_addr['city'][addr_ind],\
                r_addr['country'][addr_ind],r_addr['zip'][addr_ind],\
                r_publication['source_filename']))

    # parse titles for each publication
    r_title = dict()
    r_title['source_id']= r_publication['source_id']
    r_title['id'] = r_title_seq

    summary = REC.find('.//'+url+'summary')
    if summary is not None:
        titles = summary.find('.//'+url+'titles')
        if titles is not None:
            for title in titles.findall('.//'+url+'title'):
                if title is not None:
                    if title.text is not None:
                        r_title['title'] = title.text.encode('utf-8')
                        r_title['type'] = title.get('type')
                        r_title['id'] += 1
                        writer_title.writerow((r_title['id'],\
                            r_title['source_id'],r_title['title'],\
                            r_title['type'],r_publication['source_filename']))

    # parse authors for each publication
    r_author = dict()
    r_author['source_id']= r_publication['source_id']

    summary = REC.find('.//'+url+'summary')
    names = summary.find(url+'names')
    for name in names.findall(url+"name[@role='author']"):
    #for name in REC.findall('.//'+url+"name[@role='author']"):
        r_author['full_name'] = ''
        full_name = name.find(url+'full_name')
        if full_name is not None:
            if full_name.text is not None:
                r_author['full_name'] = full_name.text.encode('utf-8')
        r_author['wos_standard'] = ''
        wos_standard = name.find(url+'wos_standard')
        if wos_standard is not None:
            if wos_standard.text is not None:
                r_author['wos_standard'] = wos_standard.text.encode('utf-8')
        r_author['first_name'] = ''
        first_name = name.find(url+'first_name')
        if first_name is not None:
            if first_name.text is not None:
                r_author['first_name'] = first_name.text.encode('utf-8')
        r_author['last_name'] = ''
        last_name = name.find(url+'last_name')
        if last_name is not None:
            if last_name.text is not None:
                r_author['last_name'] = last_name.text.encode('utf-8')
        r_author['email_addr'] = ''
        email_addr = name.find(url+'email_addr')
        if email_addr is not None:
            if email_addr.text is not None:
                r_author['email_addr'] = email_addr.text

        r_author['seq_no'] = name.get('seq_no')
        r_author['dais_id'] = name.get('dais_id')
        r_author['r_id'] = name.get('r_id')
        addr_seqs = name.get('addr_no')
        r_author['address'] = ''
        r_author['address_id'] = ''
        r_author['addr_seq'] = ''
        if addr_seqs is not None:
            addr_no_str = addr_seqs.split(' ')
            for addr_seq in addr_no_str:
                if addr_seq is not None:
                    addr_index = int(addr_seq)
                    if addr_index in addr_no_list:
                        r_author['address'] = r_addr['addr_name'][addr_index]
                        r_author['address_id'] = r_addr['id'][addr_index]
                        r_author['addr_seq'] = addr_seq
                        r_author_seq +=1
                        r_author['id'] = r_author_seq
                        writer_author.writerow((r_author['id'],\
                            r_author['source_id'],r_author['full_name'],\
                            r_author['last_name'],r_author['first_name'],\
                            r_author['seq_no'],r_author['addr_seq'],\
                            r_author['address'],r_author['email_addr'],\
                            r_author['address_id'],r_author['dais_id'],\
                            r_author['r_id'],r_publication['source_filename']))
        else:
            r_author_seq +=1
            r_author['id'] = r_author_seq
            writer_author.writerow((r_author['id'],r_author['source_id'],\
                r_author['full_name'],r_author['last_name'],\
                r_author['first_name'],r_author['seq_no'],\
                r_author['addr_seq'],r_author['address'],\
                r_author['email_addr'],r_author['address_id'],\
                r_author['dais_id'],r_author['r_id'],\
                r_publication['source_filename']))

    # parse reference data for each publication
    REFERENCES = REC.find('.//'+url+'references')
    for ref in REFERENCES.findall('.//'+url+'reference'):
        r_reference = dict()
        r_reference['source_id'] = r_publication['source_id']
        r_reference['cited_source_id'] = None
        cited_source_id = ref.find('.//'+url+'uid')
        if cited_source_id is not None:
            if cited_source_id.text is not None:
                r_reference['cited_source_id'] = cited_source_id.text.\
                                                 encode('utf-8')
        r_reference['cited_title'] = ''
        cited_title = ref.find('.//'+url+'citedTitle')
        if cited_title is not None:
            if cited_title.text is not None:
                r_reference['cited_title'] = cited_title.text.encode('utf-8')
        r_reference['cited_work'] = ''
        cited_work =  ref.find('.//'+url+'citedWork')
        if cited_work is not None:
            if cited_work.text is not None:
                r_reference['cited_work'] = cited_work.text.encode('utf-8')
        r_reference['cited_author'] = ''
        cited_author = ref.find('.//'+url+'citedAuthor')
        if cited_author is not None:
            if cited_author.text is not None:
                r_reference['cited_author'] = cited_author.text.encode('utf-8')
        r_reference['cited_year'] = ''
        cited_year = ref.find('.//'+url+'year')
        if cited_year is not None:
            if cited_year.text is not None:
                r_reference['cited_year'] = cited_year.text.encode('utf-8')
        r_reference['cited_page'] = ''
        cited_page = ref.find('.//'+url+'page')
        if cited_page is not None:
            if cited_page.text is not None:
                r_reference['cited_page'] = cited_page.text.encode('utf-8')

        r_reference['created_date'] = r_publication['created_date']
        r_reference['last_modified_date'] = r_publication['last_modified_date']
        if r_reference['cited_source_id'] is not None:
            r_reference_seq = r_reference_seq + 1
            r_reference['id'] = r_reference_seq
            writer_ref.writerow((r_reference['id'], r_reference['source_id'], \
                r_reference['cited_source_id'], r_reference['cited_title'], \
                r_reference['cited_work'] , r_reference['cited_author'], \
                r_reference['cited_year'], r_reference['cited_page'],\
                r_reference['created_date'],r_reference['last_modified_date'],\
                r_publication['source_filename']))

# Create a script to load CSV files to PostgreSQL database
copy_command = "\\copy new_wos_publications from '"+xml_csv_dir+input_filename[:-4]+"_publication.csv'"+" delimiter ',' CSV;\n"
csvfile_load.write((copy_command))
copy_command = "\\copy new_wos_references from '"+xml_csv_dir+input_filename[:-4]+"_reference.csv'"+" delimiter ',' CSV; \n"
csvfile_load.write((copy_command))
copy_command = "\\copy new_wos_grants from '"+xml_csv_dir+input_filename[:-4]+"_grant.csv'"+" delimiter ',' CSV;\n"
csvfile_load.write((copy_command))
copy_command = "\\copy new_wos_addresses from '"+xml_csv_dir+input_filename[:-4]+"_address.csv'"+" delimiter ',' CSV;\n"
csvfile_load.write((copy_command))
copy_command = "\\copy new_wos_authors from '"+xml_csv_dir+input_filename[:-4]+"_author.csv'"+" delimiter ',' CSV; \n"
csvfile_load.write((copy_command))
copy_command = "\\copy new_wos_document_identifiers from '"+xml_csv_dir+input_filename[:-4]+"_dois.csv'"+" delimiter ',' CSV; \n"
csvfile_load.write((copy_command))
copy_command = "\\copy new_wos_abstracts from '"+xml_csv_dir+input_filename[:-4]+"_abstract.csv'"+" delimiter ',' CSV; \n"
csvfile_load.write((copy_command))
copy_command = "\\copy new_wos_keywords from '"+xml_csv_dir+input_filename[:-4]+"_keyword.csv'"+" delimiter ',' CSV; \n"
csvfile_load.write((copy_command))
copy_command = "\\copy new_wos_titles from '"+xml_csv_dir+input_filename[:-4]+"_title.csv'"+" delimiter ',' CSV; \n"
csvfile_load.write((copy_command))

# Close all opened files
csvfile_publication.close()
csvfile_reference.close()
csvfile_abstract.close()
csvfile_address.close()
csvfile_author.close()
csvfile_dois.close()
csvfile_grant.close()
csvfile_keyword.close()
csvfile_title.close()
csvfile_load.close()

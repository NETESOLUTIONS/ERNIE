'''
Function:   	This is a parser to extract the essential elements of a Record in WOS XML publications data


USAGE:  	python Parser.py -filename file_name -csv_dir csv_file_directory
Author: 	Akshat Maltare
Date:		03/24/2018
Changes:
'''
import xml.etree.cElementTree as ET
import publication as pub
import datetime
import address as add
import author as auth
import dois
import grant
import keyword as key_word
import publication
import reference
import title as ti
import abstract as abst
import psycopg2


class Parser:

    def parse(self, xml_string, counters, input_file_name, curs):
        url = '{http://clarivate.com/schema/wok5.27/public/FullRecord}'

        try:
            root = ET.fromstring(xml_string)
            for REC in root:
                # parse publications and create a publication object containing all the attributes of publication 
                new_pub = pub.publication()
                # old method commented
                # r_publication = dict()
                # Couter class to generate surrogate ids temporary for now later they will be replaced by auto incremental collumns in data base

                counters.r_publication_seq += 1
                new_pub.id = counters.r_publication_seq
                # Finding UID in the xml by finding the UID tag inside a record
                new_pub.source_id = REC.find(url + 'UID').text

                pub_info = REC.find('.//' + url + 'pub_info')
                new_pub.source_type = pub_info.get('pubtype')

                source_title = REC.find('.//' + url + "title[@type='source']")

                if source_title is not None:
                    if source_title.text is not None:
                        new_pub.source_title = source_title.text.encode('utf-8')
                # extracting values from properties of pub_info tag in XMl
                new_pub.has_abstract = pub_info.get('has_abstract')
                new_pub.publication_year = pub_info.get('pubyear')
                new_pub.issue = pub_info.get('issue')
                new_pub.volume = pub_info.get('vol')
                new_pub.pubmonth = pub_info.get('pubmonth')
                new_pub.publication_date = pub_info.get('sortdate')
                new_pub.coverdate = pub_info.get('coverdate')

                page_info = pub_info.find(url + 'page')
                if page_info is not None:
                    new_pub.begin_page = page_info.get('begin')
                    new_pub.end_page = page_info.get('end')

                document_title = REC.find('.//' + url + "title[@type='item']")
                if document_title is not None:
                    if document_title.text is not None:
                        new_pub.document_title = document_title.text. \
                            encode('utf-8')

                document_type = REC.find('.//' + url + 'doctype')
                if document_type is not None:
                    if document_type.text is not None:
                        new_pub.document_type = document_type.text

                publisher_name = REC.find('.//' + url + "name[@role='publisher']")
                if publisher_name is not None:
                    pub_name = publisher_name.find('.//' + url + 'full_name')
                    if pub_name is not None:
                        if pub_name.text is not None:
                            new_pub.publisher_name = pub_name.text. \
                                encode('utf-8')

                pub_address_no = REC.find('.//' + url + "address_spec[@addr_no='1']")
                if pub_address_no is not None:
                    publisher_address = pub_address_no.find('.//' + url + 'full_address')
                    if publisher_address is not None:
                        if publisher_address.text is not None:
                            new_pub.publisher_address = publisher_address.text. \
                                encode('utf-8')

                # r_publication['language'] = ''
                languages = REC.find('.//' + url + 'languages')
                if languages is not None:
                    language = languages.find('.//' + url + 'language')
                    if language is not None:
                        if language.text is not None:
                            new_pub.language = language.text.encode('utf-8')

                new_pub.edition = REC.find('.//' + url + 'edition').get('value')
                new_pub.source_filename = input_file_name
                new_pub.created_date = datetime.date.today()
                new_pub.last_modified_date = datetime.date.today()
                ## query to insert a publication record into the publications table in the database
                ## The query may be written into a saperate file in future from where it is read in the form of a string ammended values and executed to make code look better
                curs.execute(
                    "INSERT INTO wos_publications(begin_page, created_date, document_title, document_type,edition, end_page,has_abstract,id,issue,language,last_modified_date,publication_date,publication_year,publisher_address,publisher_name,source_filename,source_id,source_title,source_type,volume)VALUES(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) ON CONFLICT (source_id) DO UPDATE SET begin_page = excluded.begin_page, created_date = excluded.created_date,document_title = excluded.document_title, document_type = excluded.document_type, edition = excluded.edition,end_page = excluded.end_page, has_abstract = excluded.has_abstract, id = excluded.id, issue = excluded.issue,language = excluded.language, last_modified_date = excluded.last_modified_date,publication_date = excluded.publication_date, publication_year = excluded.publication_year,publisher_address = excluded.publisher_address, publisher_name = excluded.publisher_name,source_filename = excluded.source_filename, source_id = excluded.source_id, source_title = excluded.source_title,source_type = excluded.source_type, volume = excluded.volume;",
                    (str(new_pub.begin_page), new_pub.created_date, str(new_pub.document_title),
                     str(new_pub.document_type), str(new_pub.edition), str(new_pub.end_page), str(new_pub.has_abstract),
                     str(new_pub.id), str(new_pub.issue), str(new_pub.language), new_pub.last_modified_date,
                     new_pub.publication_date, str(new_pub.publication_year), str(new_pub.publisher_address),
                     str(new_pub.publisher_name), str(new_pub.source_filename), str(new_pub.source_id),
                     str(new_pub.source_title), new_pub.source_type, str(new_pub.volume)))
                ##old code for writing the publications data into a CSV file
                '''writer_pub.writerow((r_publication['id'], r_publication['source_id'], \
                                     r_publication['source_type'], r_publication['source_title'], \
                                     r_publication['language'], r_publication['document_title'], \
                                     r_publication['document_type'], r_publication['has_abstract'], \
                                     r_publication['issue'], r_publication['volume'], \
                                     r_publication['begin_page'], r_publication['end_page'], \
                                     r_publication['publisher_name'], r_publication['publisher_address'], \
                                     r_publication['publication_year'], r_publication['publication_date'], \
                                     r_publication['created_date'], r_publication['last_modified_date'], \
                                     r_publication['edition'], r_publication['source_filename']))'''
                # parse grants in funding acknowledgements for each publication
                # old method of creating a dict type
                # r_grant = dict( )

                # New method of creating an object to store everything in the form of proper objects which could be developed into classes having their own properties in future
                r_grant = grant.grant()
                r_grant.source_id = new_pub.source_id

                # r_grant.funding_ack = ''
                FUNDING_ACK = REC.find('.//' + url + 'fund_text')

                if FUNDING_ACK is not None:  # if funding acknowledgement exists, then extract the r_grant(s) data
                    funding_ack_p = FUNDING_ACK.find('.//' + url + 'p')
                    if funding_ack_p is not None:
                        if funding_ack_p.text is not None:
                            r_grant.funding_ack = funding_ack_p.text.encode('utf-8')
                # looping through all the r_grant tags
                for l_grant in REC.findall('.//' + url + 'grant'):
                    # r_grant.grant_agency = ''
                    grant_agency = l_grant.find('.//' + url + 'grant_agency')
                    if grant_agency is not None:
                        if grant_agency.text is not None:
                            r_grant.grant_agency = grant_agency.text.encode('utf-8')

                    grant_ids = l_grant.find('.//' + url + 'grant_ids')
                    if grant_ids is not None:
                        for grant_id in grant_ids.findall('.//' + url + 'grant_id'):
                            counters.r_grant_seq = counters.r_grant_seq + 1
                            r_grant.id = counters.r_grant_seq
                            # r_grant.grant_number = ''
                            if grant_id is not None:
                                if grant_id.text is not None:
                                    r_grant.grant_number = grant_id.text.encode('utf-8')
                            if r_grant.funding_ack is not None:
                                # insert the grant details in the grants table if there is any funding acknowledgement in the records
                                curs.execute(
                                    "INSERT INTO wos_grants(id,source_id,grant_number,grant_organization,funding_ack,source_filename)VALUES(%s,%s,%s,%s,%s,%s) ON CONFLICT (source_id, grant_number, grant_organization) DO UPDATE SET id = excluded.id, source_id = excluded.source_id, grant_number = excluded.grant_number,grant_organization = excluded.grant_organization, funding_ack = excluded.funding_ack,source_filename = excluded.source_filename;",
                                    (str(r_grant.id), str(r_grant.source_id), str(r_grant.grant_number),
                                     str(r_grant.grant_agency), str(r_grant.funding_ack), str(new_pub.source_filename)))

                                '''writer_grant.writerow((r_grant['id'],r_grant['source_id'],\
                                r_grant['grant_number'],r_grant['grant_agency'],\
                                r_grant['funding_ack'],\
                                r_publication['source_filename']))'''
                # insert code to insert record in r_grant table
                # parse document object identifiers for each publication
                r_dois = dois.dois()
                r_dois.source_id = new_pub.source_id

                IDS = REC.find('.//' + url + 'identifiers')
                if IDS is not None:
                    for identifier in IDS.findall('.//' + url + 'identifier'):
                        # r_dois['doi'] = None
                        id_value = identifier.get('value')
                        if id_value is not None:
                            r_dois.doi = id_value.encode('utf-8')
                        # r_dois['doi_type'] = ''
                        id_type = identifier.get('type')
                        if id_type is not None:
                            r_dois.doi_type = id_type.encode('utf-8')
                        # write each doi to CSV file for wos_document_identifiers table
                        if r_dois.doi is not None:
                            counters.r_doi_seq = counters.r_doi_seq + 1
                            r_dois.id = counters.r_doi_seq
                            # insering records into wos_document_identifier table
                            curs.execute(
                                "INSERT INTO wos_document_identifiers(id,source_id,document_id,document_id_type,source_filename)VALUES(%s,%s,%s,%s,%s) ON CONFLICT (source_id, document_id_type, document_id) DO UPDATE SET id = excluded.id, source_id = excluded.source_id, document_id = excluded.document_id,document_id_type = excluded.document_id_type, source_filename = excluded.source_filename;",
                                (str(r_dois.id), str(r_dois.source_id), str(r_dois.doi), str(r_dois.doi_type),
                                 str(new_pub.source_filename)))
                            '''writer_dois.writerow((r_dois['id'], r_dois['source_id'], \
                                                  r_dois['doi'], r_dois['doi_type'], \
                                                  r_publication['source_filename']))'''

                # parse keyword for each publication
                keywords = REC.find('.//' + url + 'keywords_plus')
                if keywords is not None:
                    r_keyword = key_word.keyword()
                    r_keyword.source_id = new_pub.source_id
                    for keyword in keywords.findall('.//' + url + 'keyword'):
                        if keyword is not None:
                            if keyword.text is not None:
                                r_keyword.keyword = keyword.text.encode('utf-8')
                                counters.r_keyword_seq = counters.r_keyword_seq + 1
                                r_keyword.id = counters.r_keyword_seq
                                # inserting records in wos_keywords
                                curs.execute(
                                    "INSERT INTO wos_keywords(id,source_id,keyword,source_filename)VALUES(%s,%s,%s,%s)ON CONFLICT (source_id, keyword) DO UPDATE SET id = excluded.id, source_id = excluded.source_id, keyword = excluded.keyword,source_filename = excluded.source_filename;",
                                    (str(r_keyword.id), str(r_keyword.source_id), str(r_keyword.keyword),
                                     str(new_pub.source_filename)))
                                # old code for insering data into a text file
                                ''''writer_keyword.writerow((r_keyword['id'], \
                                                         r_keyword['source_id'], r_keyword['keyword'], \
                                                         r_publication['source_filename']))'''''

                # parse abstract for each publication
                if new_pub.has_abstract == 'Y':
                    abstracts = REC.find('.//' + url + 'abstracts')
                    if abstracts is not None:
                        r_abst = abst.abstract()
                        r_abst.source_id = new_pub.source_id
                        r_abstract_text = ''
                        for abstract_text in abstracts.findall('.//' + url + 'p'):
                            if abstract_text is not None:
                                if abstract_text.text is not None:
                                    if r_abstract_text:
                                        r_abstract_text = r_abstract_text.join('\n\n')
                                    r_abstract_text = r_abstract_text + abstract_text.text.encode('utf-8')
                        # adding all the abstract paragraphs into one before writing it into the database
                        r_abst.abstract_text = r_abstract_text

                        # old code
                        # r_abst['abstract_text'] = abstract_text.text.\
                        #                           encode('utf-8')
                        # r_abstract_seq +=1
                        # r_abst['id'] = r_abstract_seq
                        # writer_abstract.writerow((r_abst['id'],\
                        #     r_abst['source_id'],r_abst['abstract_text'],\
                        #     r_publication['source_filename']))
                        # writing the abstracts record into the data base
                        curs.execute(
                            "INSERT INTO wos_abstracts(source_id,abstract_text,source_filename)VALUES(%s,%s,%s) ON CONFLICT (source_id) DO UPDATE SET source_id = excluded.source_id, abstract_text = excluded.abstract_text, source_filename = excluded.source_filename;;",(str(r_abst.source_id), str(r_abst.abstract_text), str(new_pub.source_filename)))

                        '''writer_abstract.writerow(
                            (r_abst['source_id'], r_abst['abstract_text'], r_publication['source_filename']))'''

                # parse addresses for each publication

                r_addr = add.address()
                # r_addr.id = {}
                # r_addr.source_id = {}
                # r_addr['addr_name'] = {}
                # r_addr['organization'] = {}
                # r_addr['suborganization'] = {}
                # r_addr['city'] = {}
                # r_addr['country'] = {}
                # r_addr['zip'] = {}
                addr_no_list = []
                addresses = REC.find('.//' + url + 'addresses')
                for addr in addresses.findall('.//' + url + 'address_spec'):

                    addr_ind = addr.get('addr_no')
                    if addr_ind is None:
                        addr_ind = 0
                    else:
                        addr_ind = int(addr_ind)
                        # Kepp all addr_no for the following reference by authors
                        addr_no_list.append(int(addr_ind))

                    r_addr.source_id[addr_ind] = new_pub.source_id
                    r_addr.addr_name[addr_ind] = ''
                    addr_name = addr.find('.//' + url + 'full_address')
                    if addr_name is not None:
                        if addr_name.text is not None:
                            r_addr.addr_name[addr_ind] = addr_name.text.encode('utf-8')
                    r_addr.organization[addr_ind] = ''
                    organization = addr.find('.//' + url + "organization[@pref='Y']")
                    if organization is not None:
                        if organization.text is not None:
                            r_addr.organization[addr_ind] = organization.text. \
                                encode('utf-8')
                    r_addr.sub_organization[addr_ind] = ''
                    suborganization = addr.find('.//' + url + 'suborganization')
                    if suborganization is not None:
                        if suborganization.text is not None:
                            r_addr.sub_organization[addr_ind] = suborganization.text. \
                                encode('utf-8')
                    r_addr.city[addr_ind] = ''
                    city = addr.find('.//' + url + 'city')
                    if city is not None:
                        if city.text is not None:
                            r_addr.city[addr_ind] = city.text.encode('utf-8')
                    r_addr.country[addr_ind] = ''
                    country = addr.find('.//' + url + 'country')
                    if country is not None:
                        if country.text is not None:
                            r_addr.country[addr_ind] = country.text.encode('utf-8')
                    r_addr.zip_code[addr_ind] = ''
                    addr_zip = addr.find('.//' + url + 'zip')
                    if addr_zip is not None:
                        if addr_zip.text is not None:
                            r_addr.zip_code[addr_ind] = addr_zip.text.encode('utf-8')
                    if r_addr.addr_name[addr_ind] is not None:
                        counters.r_addr_seq += 1
                        r_addr.id[addr_ind] = counters.r_addr_seq
                        # Insering address records into database
                        curs.execute(
                            "INSERT INTO wos_addresses(id,source_id,address_name,organization,sub_organization,city,country,zip_code,source_filename)VALUES(%s,%s,%s,%s,%s,%s,%s,%s,%s)ON CONFLICT (source_id, address_name) DO UPDATE SET id = excluded.id, source_id = excluded.source_id, address_name = excluded.address_name,organization = excluded.organization, sub_organization = excluded.sub_organization, city = excluded.city,country = excluded.country, zip_code = excluded.zip_code, source_filename = excluded.source_filename;",
                            (str(r_addr.id[addr_ind]), str(r_addr.source_id[addr_ind]), str(r_addr.addr_name[addr_ind]),
                             str(r_addr.organization[addr_ind]), str(r_addr.sub_organization[addr_ind]),
                             str(r_addr.city[addr_ind]), str(r_addr.country[addr_ind]), str(r_addr.zip_code[addr_ind]),
                             str(new_pub.source_filename)))

                        '''writer_address.writerow((r_addr['id'][addr_ind], \
                                                 r_addr['source_id'][addr_ind], r_addr['addr_name'][addr_ind], \
                                                 r_addr['organization'][addr_ind], \
                                                 r_addr['suborganization'][addr_ind], r_addr['city'][addr_ind], \
                                                 r_addr['country'][addr_ind], r_addr['zip'][addr_ind], \
                                                 r_publication['source_filename']))'''

                # parse titles for each publication
                r_title = ti.title()
                r_title.source_id = new_pub.source_id
                r_title.id = counters.r_title_seq

                summary = REC.find('.//' + url + 'summary')
                if summary is not None:
                    titles = summary.find('.//' + url + 'titles')
                    if titles is not None:
                        for title in titles.findall('.//' + url + 'title'):
                            if title is not None:
                                if title.text is not None:
                                    r_title.title = title.text.encode('utf-8')
                                    r_title.type = title.get('type')
                                    r_title.id += 1
                                    # inserting titles into the database
                                    curs.execute(
                                        "INSERT INTO wos_titles(id,source_id,title,type,source_filename)VALUES(%s,%s,%s,%s,%s)ON CONFLICT (source_id, type) DO UPDATE SET id = excluded.id, source_id = excluded.source_id, title = excluded.title, type = excluded.type,source_filename = excluded.source_filename;",
                                        (str(r_title.id), str(r_title.source_id), str(r_title.title), str(r_title.type),
                                         str(new_pub.source_filename)))
                                    '''writer_title.writerow((r_title['id'], \
                                                           r_title['source_id'], r_title['title'], \
                                                           r_title['type'], r_publication['source_filename']))'''

                # parse authors for each publication
                r_author = auth.author()
                r_author.source_id = new_pub.source_id

                summary = REC.find('.//' + url + 'summary')
                names = summary.find(url + 'names')
                for name in names.findall(url + "name[@role='author']"):
                    # for name in REC.findall('.//'+url+"name[@role='author']"):
                    # r_author.full_name = ''
                    full_name = name.find(url + 'full_name')
                    if full_name is not None:
                        if full_name.text is not None:
                            r_author.full_name = full_name.text.encode('utf-8')
                    # r_author['wos_standard'] = ''
                    wos_standard = name.find(url + 'wos_standard')
                    if wos_standard is not None:
                        if wos_standard.text is not None:
                            r_author.wos_standard = wos_standard.text.encode('utf-8')
                    r_author.first_name = ''
                    first_name = name.find(url + 'first_name')
                    if first_name is not None:
                        if first_name.text is not None:
                            r_author.first_name = first_name.text.encode('utf-8')
                    # r_author.last_name = ''
                    last_name = name.find(url + 'last_name')
                    if last_name is not None:
                        if last_name.text is not None:
                            r_author.last_name = last_name.text.encode('utf-8')
                    # r_author['email_addr'] = ''
                    email_addr = name.find(url + 'email_addr')
                    if email_addr is not None:
                        if email_addr.text is not None:
                            r_author.email_addr = email_addr.text.encode('utf-8')

                    r_author.seq_no = name.get('seq_no')
                    r_author.dais_id = name.get('dais_id')
                    r_author.r_id = name.get('r_id')
                    addr_seqs = name.get('addr_no')
                    # r_author.address = ''
                    r_author.address_id = ''
                    r_author.addr_seq = ''
                    if addr_seqs is not None:
                        addr_no_str = addr_seqs.split(' ')
                        for addr_seq in addr_no_str:
                            if addr_seq is not None:
                                addr_index = int(addr_seq)
                                if addr_index in addr_no_list:
                                    r_author.address = r_addr.addr_name[addr_index]
                                    r_author.address_id = r_addr.id[addr_index]
                                    r_author.addr_seq = addr_seq
                                    counters.r_author_seq += 1
                                    r_author.id = counters.r_author_seq
                                    # inserting records into author table of data base
                                    curs.execute(
                                        "INSERT INTO wos_authors(id,source_id,full_name,last_name,first_name,seq_no,address_seq,address,email_address,address_id,dais_id,r_id,source_filename)VALUES(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) ON CONFLICT (source_id, seq_no, address_id) DO UPDATE SET id = excluded.id, source_id = excluded.source_id, full_name = excluded.full_name,last_name = excluded.last_name, first_name = excluded.first_name, seq_no = excluded.seq_no,address_seq = excluded.address_seq, address = excluded.address, email_address = excluded.email_address,address_id = excluded.address_id, dais_id = excluded.dais_id, r_id = excluded.r_id,source_filename = excluded.source_filename;",
                                        (str(r_author.id), str(r_author.source_id), str(r_author.full_name),
                                         str(r_author.last_name), str(r_author.first_name), str(r_author.seq_no),
                                         str(r_author.addr_seq), str(r_author.address), str(r_author.email_addr),
                                         str(r_author.address_id), str(r_author.dais_id), str(r_author.r_id),
                                         str(new_pub.source_filename)))
                                    '''writer_author.writerow((r_author['id'], \
                                                            r_author['source_id'], r_author['full_name'], \
                                                            r_author['last_name'], r_author['first_name'], \
                                                            r_author['seq_no'], r_author['addr_seq'], \
                                                            r_author['address'], r_author['email_addr'], \
                                                            r_author['address_id'], r_author['dais_id'], \
                                                            r_author['r_id'], r_publication['source_filename']))'''
                    else:
                        counters.r_author_seq += 1
                        r_author.id = counters.r_author_seq
                        r_author.address_id = 0
                        r_author.addr_seq = 0
                        # inserting records into author tables of database
                        curs.execute(
                            "INSERT INTO wos_authors(id,source_id,full_name,last_name,first_name,seq_no,email_address,dais_id,r_id,source_filename)VALUES(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)ON CONFLICT (source_id, seq_no, address_id) DO UPDATE SET id = excluded.id, source_id = excluded.source_id, full_name = excluded.full_name,last_name = excluded.last_name, first_name = excluded.first_name, seq_no = excluded.seq_no,address_seq = excluded.address_seq, address = excluded.address, email_address = excluded.email_address,address_id = excluded.address_id, dais_id = excluded.dais_id, r_id = excluded.r_id,source_filename = excluded.source_filename;",
                            (
                            str(r_author.id), str(r_author.source_id), str(r_author.full_name), str(r_author.last_name),
                            str(r_author.first_name), str(r_author.seq_no), str(r_author.email_addr),
                            str(r_author.dais_id), str(r_author.r_id), str(new_pub.source_filename)))
                        '''writer_author.writerow((r_author['id'], r_author['source_id'], \
                                                r_author['full_name'], r_author['last_name'], \
                                                r_author['first_name'], r_author['seq_no'], \
                                                r_author['addr_seq'], r_author['address'], \
                                                r_author['email_addr'], r_author['address_id'], \
                                                r_author['dais_id'], r_author['r_id'], \
                                                r_publication['source_filename']))'''

                # parse reference data for each publication
                REFERENCES = REC.find('.//' + url + 'references')
                for ref in REFERENCES.findall('.//' + url + 'reference'):
                    # print "inside reference"
                    r_reference = reference.reference()
                    r_reference.source_id = new_pub.source_id
                    r_reference.cited_source_uid = None
                    cited_source_id = ref.find('.//' + url + 'uid')
                    if cited_source_id is not None:
                        if cited_source_id.text is not None:
                            r_reference.cited_source_uid = cited_source_id.text. \
                                encode('utf-8')
                    # r_reference['cited_title'] = ''
                    cited_title = ref.find('.//' + url + 'citedTitle')
                    if cited_title is not None:
                        if cited_title.text is not None:
                            r_reference.cited_title = cited_title.text.encode('utf-8')
                    r_reference.cited_work = ''
                    cited_work = ref.find('.//' + url + 'citedWork')
                    if cited_work is not None:
                        if cited_work.text is not None:
                            r_reference.cited_work = cited_work.text.encode('utf-8')
                    # r_reference['cited_author'] = ''
                    cited_author = ref.find('.//' + url + 'citedAuthor')
                    if cited_author is not None:
                        if cited_author.text is not None:
                            r_reference.cited_author = cited_author.text.encode('utf-8')[:299]
                    # r_reference['cited_year'] = ''
                    cited_year = ref.find('.//' + url + 'year')
                    if cited_year is not None:
                        if cited_year.text is not None:
                            r_reference.cited_year = cited_year.text.encode('utf-8')
                    # r_reference.cited_page = ''
                    cited_page = ref.find('.//' + url + 'page')
                    if cited_page is not None:
                        if cited_page.text is not None:
                            r_reference.cited_page = cited_page.text.encode('utf-8')

                    r_reference.created_date = new_pub.created_date
                    r_reference.last_modified_date = new_pub.last_modified_date
                    if r_reference.cited_source_uid is not None:
                        counters.r_reference_seq = counters.r_reference_seq + 1
                        r_reference.id = counters.r_reference_seq
                        # inserting references into database
                        curs.execute(
                            "INSERT INTO wos_references(wos_reference_id,source_id,cited_source_uid,cited_title,cited_work,cited_author,cited_year,cited_page,created_date,last_modified_date,source_filename)VALUES(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)ON CONFLICT ON CONSTRAINT wos_references_pk DO UPDATE SET source_id = excluded.source_id, cited_source_uid = excluded.cited_source_uid,cited_title = excluded.cited_title, cited_work = excluded.cited_work, cited_author = excluded.cited_author,cited_year = excluded.cited_year, cited_page = excluded.cited_page, created_date = excluded.created_date,last_modified_date = excluded.last_modified_date, source_filename = excluded.source_filename;",
                            (str(r_reference.id), str(r_reference.source_id), str(r_reference.cited_source_uid),
                             str(r_reference.cited_title), str(r_reference.cited_work), str(r_reference.cited_author),
                             str(r_reference.cited_year), str(r_reference.cited_page), str(r_reference.created_date),
                             str(r_reference.last_modified_date), str(new_pub.source_filename)))

                        '''writer_ref.writerow((r_reference['id'], r_reference['source_id'], \
                                             r_reference['cited_source_id'], r_reference['cited_title'], \
                                             r_reference['cited_work'], r_reference['cited_author'], \
                                             r_reference['cited_year'], r_reference['cited_page'], \
                                             r_reference['created_date'], r_reference['last_modified_date'], \
                                             r_publication['source_filename']))'''

            '''print "Processed", r_publication_seq, "records from", input_csv_dir + input_filename

                                                                                :-4] + "_publication.csv'" + " delimiter ',' CSV;\n"
            csvfile_load.write((copy_command))
            copy_command = "\\copy new_wos_references from '" + xml_csv_dir + input_filename[
                                                                              :-4] + "_reference.csv'" + " delimiter ',' CSV;\n"
            csvfile_load.write((copy_command))
            copy_command = "\\copy new_wos_grants from '" + xml_csv_dir + input_filename[
                                                                          :-4] + "_grant.csv'" + " delimiter ',' CSV;\n"
            csvfile_load.write((copy_command))
            copy_command = "\\copy new_wos_addresses from '" + xml_csv_dir + input_filename[
                                                                             :-4] + "_address.csv'" + " delimiter ',' CSV;\n"
            csvfile_load.write((copy_command))
            copy_command = "\\copy new_wos_authors from '" + xml_csv_dir + input_filename[
                                                                           :-4] + "_author.csv'" + " delimiter ',' CSV;\n"
            csvfile_load.write((copy_command))
            copy_command = "\\copy new_wos_document_identifiers from '" + xml_csv_dir + input_filename[
                                                                                        :-4] + "_dois.csv'" + " delimiter ',' CSV;\n"
            csvfile_load.write((copy_command))
            copy_command = "\\copy new_wos_abstracts from '" + xml_csv_dir + input_filename[
                                                                             :-4] + "_abstract.csv'" + " delimiter ',' CSV;\n"
            csvfile_load.write((copy_command))
            copy_command = "\\copy new_wos_keywords from '" + xml_csv_dir + input_filename[
                                                                            :-4] + "_keyword.csv'" + " delimiter ',' CSV;\n"
            csvfile_load.write((copy_command))
            copy_command = "\\copy new_wos_titles from '" + xml_csv_dir + input_filename[
                                                                          :-4] + "_title.csv'" + " delimiter ',' CSV;\n"
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

                #print(rec.find(self.url + 'UID').text)'''

            # print('Database connection closed.')
        except ET.ParseError as error:
            print error
        return (counters)

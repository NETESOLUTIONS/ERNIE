#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar  5 15:11:58 2019

@author: siyu
"""
import xml.etree.cElementTree as ET
#import datetime as dt
from test_mapping import scopus_documents, scopus_authors,scopus_references,scopus_addresses,Session, engine, Base
import test_pub,test_authors,test_references,test_addresses
from sqlalchemy.dialects.postgresql import insert

class Parser:
    #parser data from text file
    def parse(self, input_filename,pub_authors,pub_references,pub_addresses):

        ce='{http://www.elsevier.com/xml/ani/common}'
        tree=ET.parse(input_filename)
        root=tree.getroot()
        item=root[1]
        
        #publications
        pub=test_pub.publications()
        pub.scopus_id=item.find(".//itemid[@idtype='SCP']").text
        pmid=item.find(".//itemid[@idtype='MEDL']")
        if pmid is not None:
            pub.pmid=pmid.text
        
        doi=item.find(".//"+ce+'doi')
        if doi is not None:
            pub.doi=doi.text

        title=item.find(".//titletext")
        if title is not None:
            pub.title=item.find(".//titletext").text
        
        document_type=item.find(".//source[@type]")
        if document_type is not None:
            pub.document_type=item.find(".//source[@type]").attrib['type']
        
        publication_name=item.find(".//sourcetitle")
        if publication_name is not None:
            pub.publication_name=publication_name.text
        
        issn=item.find(".//source/issn")
        if issn is not None:
            pub.issn=issn.text
        
        volume=item.find(".//voliss[@volume]")
        if volume is not None:
            pub.volume=item.find(".//voliss[@volume]").attrib['volume']
        
        first_page=item.find(".//pagerange[@first]")
        if first_page is not None:
            pub.first_page=item.find(".//pagerange[@first]").attrib['first']
        
        last_page=item.find(".//pagerange[@last]")
        if last_page is not None:
            pub.last_page=item.find(".//pagerange[@last]").attrib['last']

        publication_year=item.find(".//publicationdate/year")
        if publication_year is not None:
            pub.publication_year=publication_year.text
        
        publication_month=item.find(".//publicationdate/month")
        if publication_month is not None:
            pub.publication_month=publication_month.text
            
        publication_day=item.find(".//publicationdate/day")
        if publication_day is not None:
            pub.publication_day=publication_day.text
    
        #authors
        auth=test_authors.authors()
        authors=item.find(".//author-group")
        if authors is not None:
            authors=authors.findall(".//author")
            for author in authors:
                auth.scopus_id=pub.scopus_id
                if 'auid' in author.attrib.keys():
                    auth.author_id=author.attrib['auid']
                else:
                    auth.author_id='0'
                if 'seq' in author.attrib.keys():
                    auth.seq=author.attrib['seq']
                
                initial=author.find(".//"+ce+"initials")
                if initial is not None:
                    auth.author_initial=initial.text
                
                surname=author.find(".//"+ce+"surname")
                if surname is not None:
                    auth.author_surname=surname.text
    
                index_name=author.find(".//"+ce+"indexed-name")
                if index_name is not None:
                    auth.author_indexed_name=index_name.text
                
                pub_authors.append(auth.__dict__)
                auth=test_authors.authors()
                
                
        #references
        references=test_references.references()
        ref_list=item.find(".//tail/bibliography")
        if ref_list is not None:
            refs=ref_list.findall(".//reference")
            for ref in refs:
                references.scopus_id=pub.scopus_id
                references.ref_id=ref.attrib['id']
                    
                title=ref.find(".//ref-sourcetitle")
                if title is not None:
                    references.source_title=title.text
                
                year=ref.find(".//ref-publicationyear[@first]")
                if year is not None:
                    references.publication_year=year.attrib['first']
                
                pub_references.append(references.__dict__)
                references=test_references.references()     

        else:
            references.scopus_id=pub.scopus_id
            references.ref_id='0'
            pub_references.append(references.__dict__)
            references=test_references.references()     
                    
                                   
        #addresses
        addresses=test_addresses.addresses()
        addrs=item.findall(".//author-group/affiliation")
        if addrs is not None:
            for addr in addrs:
                addresses.scopus_id=pub.scopus_id
                if 'afid' in addr.attrib.keys():
                    addresses.afid=addr.attrib['afid']
                else:
                    addresses.afid='0'
                
                organization=addr.find(".//organization")
                if organization is not None:
                    addresses.organization=organization.text
                
                city=addr.find(".//city-group")
                if city is not None:
                    addresses.city=city.text
                
                country=addr.find(".//country")
                if country is not None:
                    addresses.country=country.text
                
                pub_addresses.append(addresses.__dict__)
                addresses=test_addresses.addresses()

        return(pub,pub_authors,pub_references,pub_addresses)


    def upsert(self,pubs,authors,addresses,references):
        #generate database schema
        Base.metadata.create_all(engine)

        #create a new session
        session = Session()
        #session.execute("SET search_path TO public")
        #session.execute("TRUNCATE TABLE scopus_documents")

        #Load data into database and close the session
        try:
            insert_stmt1=insert(scopus_documents).values(pubs)
            do_nothing_stmt1  = insert_stmt1.on_conflict_do_nothing(index_elements=['scopus_id'])
            session.execute(do_nothing_stmt1)
            session.commit()
            
            insert_stmt2=insert(scopus_authors).values(authors)
            do_nothing_stmt2  = insert_stmt2.on_conflict_do_nothing(index_elements=['scopus_id','author_id'])
            session.execute(do_nothing_stmt2)
            session.commit()
            
            insert_stmt3=insert(scopus_addresses).values(addresses)
            do_nothing_stmt3  = insert_stmt3.on_conflict_do_nothing(index_elements=['scopus_id','afid'])
            session.execute(do_nothing_stmt3)
            session.commit()
            
            insert_stmt4=insert(scopus_references).values(references)
            do_nothing_stmt4  = insert_stmt4.on_conflict_do_nothing(index_elements=['scopus_id','ref_id'])
            session.execute(do_nothing_stmt4)
            session.commit()
        
        except Exception as e:
            session.rollback()
            print(str(e))


        

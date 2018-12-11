#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 06 10:32:16 2018

@author: sitaram
"""

import xml.etree.ElementTree as ET
from lxml import etree
import publication as pub
import datetime
import author
import reference
import document as doc
import psycopg2


class Parser:

	def parse(self,xml_string,input_file_name,curs):
		
		
		parser_dtd=etree.XMLParser(encoding='ISO-8859-1',dtd_validation=True,load_dtd=True,remove_comments=True)
		root = etree.fromstring(xml_string.encode('ISO-8859-1'),parser_dtd)
		#print(type(root)) 
		for REC in root:
			
			#Parse publication and create a publication object containing all the attributes of publication
			new_pub=pub.publication()

			author_names=[]
			try:
				new_pub.source_type=REC.tag
				
				new_pub.source_id=REC.attrib.get('key')
				
				if 'mdate' in REC.attrib:
					new_pub.modified_date=REC.attrib.get('mdate')

				if 'publtype' in REC.attrib:
					new_pub.document_type=REC.attrib.get('publtype')

				#Can be more than 1 author
				author_fields=REC.findall('author')
				if author_fields is not None:
					for auth in author_fields:
							if 'orcid' in auth.attrib:
								author_names.append((auth.text,auth.attrib.get('orcid'))
							else:
								author_names.append((auth.text,None))
					
				pages=REC.find('pages')
				if pages is not None:
					if len(pages.text.split('-')) == 2:
						new_pub.begin_page=pages.text.split('-')[0]
						new_pub.end_page=pages.text.split('-')[1]
					else:
						new_pub.begin_page=pages.text.split('-')[0]

				title=REC.find('title')
				new_pub.document_title=title.text

				issue_no=REC.find('number')
				if issue_no is not None:
					new_pub.issue=issue_no.text

				year=REC.find('year')
				if year is not None:
					new_pub.publication_year=year.text

				address=REC.find('address')
				if address is not None:
					new_pub.publisher_address=address.text

				publisher=REC.find('publisher')
				if publisher is not None:
					new_pub.publisher_name=publisher.text

				vol=REC.find('volume')
				if vol is not None:
					new_pub.volume=vol.text

				s_title=REC.find('journal')
				if s_title is not None:
					new_pub.source_title=s_title.text
				else:
					s_title=REC.find('booktitle')
					if s_title is not None:
						new_pub.source_title=s_title.text

				#Query to insert publication record into the publications table in the database
				curs.execute("INSERT INTO dblp_publications (begin_page,modified_date,document_title,document_type,end_page,issue,"\
					"publication_year,publisher_address,publisher_name,source_id,source_title,source_type,volume)VALUES(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"\
					" ON CONFLICT (source_id) DO UPDATE SET begin_page=excluded.begin_page,modified_date=excluded.modified_date,document_title=excluded.document_title,"\
					"document_type=excluded.document_type,end_page=excluded.end_page,issue=excluded.issue,publication_year=excluded.publication_year,"\
					"publisher_address=excluded.publisher_address,publisher_name=excluded.publisher_name,source_id=excluded.source_id,source_title=excluded.source_title,"\
					"source_type=excluded.source_type,volume=excluded.volume,last_updated_time=current_timestamp;",
					(str(new_pub.begin_page),new_pub.modified_date,str(new_pub.document_title),str(new_pub.document_type),str(new_pub.end_page),str(new_pub.issue),
						str(new_pub.publication_year),str(new_pub.publisher_address),str(new_pub.publisher_name),str(new_pub.source_id),str(new_pub.source_title),str(new_pub.source_type),
						str(new_pub.volume)))

			except Exception:
				print("Error occured during publication record ",new_pub.source_id,'\n')

			#parse document identifier fields for each publication
			new_doc=doc.document()

			#A dictionary which stores all the document id's and types
			docs=dict()


			new_doc.source_id=new_pub.source_id
			ee=REC.findall('ee')
			if ee is not None:
				for i in ee:
					docs[i.text]=i.tag
				
			url=REC.findall('url')
			if url is not None:
				for i in url:
					docs[i.text]=i.tag
			
			crossref=REC.findall('crossref')
			if crossref is not None:
				for i in crossref:
					docs[i.text]=i.tag

			isbn=REC.find('isbn')
			if isbn is not None:
				docs[isbn.text]=isbn.tag
				
			series=REC.find('series')
			if series is not None:
				docs[series.text]=series.tag
				
			cdrom=REC.find('cdrom')
			if cdrom is not None:
				docs[cdrom.text]=cdrom.tag

			school=REC.find('school')
			if school is not None:
				docs[school.text]=school.tag

			notes=REC.find('notes')
			if notes is not None:
				docs[notes.text]=notes.tag

			try:

				#Inserting records into dblp_document_identifiers
				for text,tag in docs.items():
					new_doc.document_id=text
					new_doc.document_id_type=tag

					curs.execute("INSERT INTO dblp_document_identifiers(source_id,document_id,document_id_type) VALUES(%s,%s,%s)"\
						"ON CONFLICT (source_id,document_id,document_id_type) DO UPDATE SET source_id=excluded.source_id,"\
						"document_id=excluded.document_id,document_id_type=excluded.document_id_type,last_updated_time=current_timestamp;",
						(str(new_doc.source_id),str(new_doc.document_id),str(new_doc.document_id_type)))
			except Exception:
				print("Error occured during document identifier record ",new_doc.source_id,'\n')

			#parse author fields for dblp_authors
			try:
				new_auth=author.author()

				editor=REC.find('editor')
				if editor is not None:
					new_auth.editor_name=editor.text

				seq_no=0	

				for name in author_names:
					new_auth.first_name=' '.join(name[0].split()[:-1])
					new_auth.last_name=name[0].split()[-1]
					new_auth.full_name=name[0]
					new_auth.source_id=new_pub.source_id
					new_auth.seq_no=seq_no
					if name[1] is not None:
						new_auth.orc_id=name[1]


					curs.execute("INSERT INTO dblp_authors(source_id,full_name,last_name,first_name,seq_no,orc_id,editor_name)"\
						"VALUES(%s,%s,%s,%s,%s,%s,%s) ON CONFLICT (source_id,seq_no) DO UPDATE SET source_id=excluded.source_id,"\
						"full_name=excluded.full_name,last_name=excluded.last_name,first_name=excluded.first_name,seq_no=excluded.seq_no,"\
						"orc_id=excluded.orc_id,editor_name=excluded.editor_name,last_updated_time=current_timestamp;",(str(new_auth.source_id),str(new_auth.full_name),str(new_auth.last_name),
							str(new_auth.first_name),str(new_auth.seq_no),str(new_auth.orc_id),str(new_auth.editor_name)))

					seq_no+=1
			except Exception:
				print("Error occured during authors record ",new_auth.source_id,'\n')

			#parser citataion fields for dblp_references
			try:
				new_ref=reference.reference()
				new_ref.source_id=new_pub.source_id

				citations=REC.findall('cite')
				if citations is not None:
					for cite in citations:
						if cite != '...':
							new_ref.cited_source_id=cite.text

							curs.execute("INSERT INTO dblp_references(source_id,cited_source_id) VALUES(%s,%s) ON CONFLICT ON CONSTRAINT"\
								"dblp_references_pk DO UPDATE SET source_id=excluded.source_id,cited_source_id=excluded.cited_source_id,"\
								"last_updated_time=current_timestamp;",(str(new_ref.source_id),str(new_ref.cited_source_id)))
			except Exception:
				print("Error occured for the following reference record: ",new_ref.source_id,'\n')





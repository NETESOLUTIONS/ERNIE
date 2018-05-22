# coding=utf-8

'''
Function:   this is a class file for publications to save its value in the form of an object


USAGE:  	python publication.py -filename file_name -csv_dir csv_file_directory
Author: 	Akshat Maltare
Date:		03/24/2018
Changes:
'''
import xml.etree.cElementTree as ET
class publication:

    def __init__(self):
        self.r_publication_seq = 0
        self.id= None
        self.source_id=''
        self.source_type=''
        self.source_title=''
        self.has_abstract=''
        self.publication_year=''
        self.issue=''
        self.volume=''
        self.pubmonth=''
        self.publication_date=''
        self.coverdate=''
        self.begin_page=''
        self.end_page=''
        self.document_title=''
        self.document_type=''
        self.publisher_name=''
        self.publisher_address=''
        self.language=''
        self.edition=''
        self.source_filename=''
        self.created_date=''
        self.last_modified_date=''

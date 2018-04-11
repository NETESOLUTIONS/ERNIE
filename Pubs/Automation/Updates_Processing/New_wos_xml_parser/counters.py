
'''
Function:   this is a class file for counter values


USAGE:  	python counters.py -filename file_name -csv_dir csv_file_directory
Author: 	Akshat Maltare
Date:		03/24/2018
Changes:
'''
import xml.etree.cElementTree as ET
class counters:

    def __init__(self):
        self.r_publication_seq = 0
        self.r_reference_seq = 0
        self.r_grant_seq = 0
        self.r_doi_seq = 0
        self.r_addr_seq = 0
        self.r_author_seq = 0
        self.r_abstract_seq = 0
        self.r_keyword_seq = 0
        self.r_title_seq = 0
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 06 10:40:16 2018

@author: sitaram
"""

import xml.etree.ElementTree as ET

class publication:

	def __init__(self):
		self.begin_page=''
		self.modified_date=''
		self.document_title=''
		self.document_type=''
		self.end_page=''
		self.issue=''
		self.publication_year=''
		self.publisher_address=''
		self.publisher_name=''
		self.source_id=''
		self.source_title=''
		self.source_type=''
		self.volume=''
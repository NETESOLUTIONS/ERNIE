#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 06 12:24:42 2018

@author: sitaram
"""

import xml.etree.ElementTree as ET

class document:
	def __init__(self):
		self.source_id=''
		self.document_id=''
		self.document_id_type=''
		self.notes=''
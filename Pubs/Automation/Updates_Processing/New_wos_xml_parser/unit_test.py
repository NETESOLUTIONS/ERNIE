#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Oct 31 13:30:55 2018

@author: siyu
"""

import os
import zipfile
import gzip
import shutil
import random
import xml.etree.cElementTree as ET
import unittest
import psycopg2
from collections import Counter

rootdir = '/erniedev_data8/wos_smokeload_data/source/CORE_1900-2017_Annual'
workdir = '/erniedev_data8/wos_smokeload_data/unittest'
match = '/erniedev_data8/wos_smokeload_data/working'

extension = ['.zip','.xml']

url = '{http://clarivate.com/schema/wok5.27/public/FullRecord}'
wos_id=[]
stored_id=[]
sample_file=[]

def parse_id(xml):
    root=ET.fromstring(xml)
    for REC in root:
        wos_id.append(REC.find(url+'UID').text)
    return wos_id

for subdir, dirs, files in os.walk(rootdir):
    sample=random.sample(files,1)
    for file in sample:      
        if file.endswith(extension[0]):
            #sample_year.append(file.replace('.zip','').split('_')[0])
            os.system("mkdir "+os.path.join(workdir,file.replace('.zip','')))
            new_dir=os.path.join(workdir,file.replace('.zip',''))
	    file_dir=os.path.join(match,file.replace('.zip',''))
            zip_ref = zipfile.ZipFile(os.path.join(rootdir, file)) # create zipfile object
            zip_ref.extractall(os.path.join(workdir,file.replace('.zip',''))) # extract file to dir 
            filename=zip_ref.namelist()            
            for each in filename:
                if each.endswith('.gz'):
                    print("Unzipping "+os.path.join(new_dir, each))
                    with gzip.open(os.path.join(new_dir, each), 'rb') as f_in:
                        with open(os.path.join(new_dir, each.replace('.gz','')), 'wb') as f_out:
                            shutil.copyfileobj(f_in, f_out)
                    os.remove(os.path.join(new_dir, each))                
                if each.replace('.gz','').endswith(extension[1]):
                    #print("Parsing wos_id from "+os.path.join(new_dir, each.replace('.gz','')))
                    with open(os.path.join(new_dir, each.replace('.gz',''))) as f:
                        init_buffer_REC = '<?xml version="1.0" encoding="UTF-8"?>'
                        init_buffer_REC = init_buffer_REC + '<records xmlns="http://clarivate.com/schema/wok5.27/public/FullRecord">'
                        buffer_REC = ''
                        is_rec = False
                    
                        for line in f:
                            if '</REC' in line:
                                buffer_REC = ''.join([buffer_REC, line])
                                buffer_REC = buffer_REC + "</records>"
                                parse_id(buffer_REC)
                                is_rec = False         
                            elif '<REC' in line:
                                buffer_REC = init_buffer_REC
                                is_rec = True
                                
                            if is_rec:
                                buffer_REC = ''.join([buffer_REC, line])
                        sample_file.append(os.path.join(file_dir, each.replace('.gz','')))
			print("Parsed wos_id from "+os.path.join(new_dir, each.replace('.gz','')))

            zip_ref.close()    
        #print("Deleting parsed files in working dir")
        shutil.rmtree(os.path.join(workdir, file.replace('.zip','')))

#establish connection with database
try:
    conn = psycopg2.connect("")
except Exception as e:
    print(e)

with conn.cursor() as curs:
    print('Searching from database')
    curs.execute("set search_path to public;")
    for item in sample_file:
	print(item)
        curs.execute("select source_id from wos_publications where source_filename = %s;",(item,))
        stored_id.extend(curs.fetchall())
conn.close()

test_id=[x[0] for x in stored_id]
class wosTestCase(unittest.TestCase):
    def test_ids(self):
	self.maxDiff=None
        #wos_id should be equal to original source
        #self.assertCountEqual(test_id,wos_id)
        self.assertItemsEqual(test_id,wos_id)
if __name__=="__main__":
    unittest.main()



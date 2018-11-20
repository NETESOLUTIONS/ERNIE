#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Nov  9 11:54:58 2018

@author: sitaram
"""
from __future__ import print_function
import sys
import os
import gzip,shutil

rootdir = '/erniedev_data8/wos_smokeload_data/source/WOS_DELETE_2018_002-267/'
#rootdir = '/erniedev_data8/wos_smokeload_data/source1/'
workdir = '/erniedev_data8/wos_smokeload_data/working'
extension = ['.gz']

for subdir,dirs,files in os.walk(rootdir):
    for file in sorted(files):
        if file.endswith(extension[0]):
            #print(os.path.basename(file))
	    with gzip.open(os.path.join(rootdir, file), 'rb') as f_in:
                with open(os.path.join(workdir, file.replace('.gz','')), 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)
	    os.system("python /erniedev_data8/wos_smokeload_data/smokeload/wos_delete_parser.py -filename "+ os.path.join(workdir, file.replace('.gz','')))

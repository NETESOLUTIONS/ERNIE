#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct  4 15:44:41 2018

@author: siyu
"""

import os
import zipfile
import gzip
import shutil
import tarfile

rootdir = '/erniedev_data8/wos_smokeload_data/source/CORE_WEEKLY_UPDATES_2018_01-39'
workdir = '/erniedev_data8/wos_smokeload_data/working'
extension = ['.tar.gz','.xml']

for subdir, dirs, files in os.walk(rootdir):
    for file in sorted(files):
        #print(sorted(files))
        if file.endswith(extension[0]):
            #os.system("mkdir "+os.path.join(workdir,file.replace('.tar.gz','')))
            new_dir=os.path.join(workdir,file.replace('.tar.gz',''))
            tar_ref = tarfile.open(os.path.join(rootdir, file)) # create zipfile object
            tar_ref.extractall(os.path.join(workdir,file.replace('.tar.gz',''))) # extract file to dir 
            filename=tar_ref.getnames()
            for each in filename:
                if each.endswith('.gz'):
                    print("Unzipping "+os.path.join(new_dir, each))
                    with gzip.open(os.path.join(new_dir, each), 'rb') as f_in:
                        with open(os.path.join(new_dir, each.replace('.gz','')), 'wb') as f_out:
                            shutil.copyfileobj(f_in, f_out)
                    os.remove(os.path.join(new_dir, each))
                
                if each.replace('.gz','').endswith(extension[1]):
                    #print("Parsing"+" "+os.path.join(new_dir, each.replace('.gz','')))
                    os.system("python /erniedev_data8/wos_smokeload_data/smokeload/__main__.py -filename "+ os.path.join(new_dir, each.replace('.gz','')))    
            tar_ref.close()
    #shutil.rmtree(os.path.join(workdir,file.replace('.zip','')))
            


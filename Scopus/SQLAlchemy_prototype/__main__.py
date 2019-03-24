#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar  5 16:44:34 2019

@author: siyu
"""

import sys
import os
import zipfile
import shutil
import test_parser as parser

def main():
    in_arr = sys.argv

    if '-source' not in in_arr:
        print ("No source path provided")
        raise NameError('error: No source path provided')
    else:
        source = in_arr[in_arr.index('-source') + 1]
    
    if '-work' not in in_arr:
        print ("No working path provided")
        raise NameError('error: No working path provided')
    else:
        work = in_arr[in_arr.index('-work') + 1]
    
    rootdir = source
    workdir = work
    
    pub_authors=[]
    pub_references=[]
    pub_addresses=[]
    pubs=[]
    authors=[]
    addresses=[]
    references=[]
    for subdir, dirs, files in os.walk(rootdir):
        for file in files:
            if file.endswith('zip'):
                print('processing '+ file)
                zip_ref = zipfile.ZipFile(os.path.join(rootdir,file), 'r')
                zip_ref.extractall(os.path.join(workdir,file.replace('.zip','')))
                new_dir=os.path.join(workdir,file.replace('.zip',''))
                zip_ref.close()
                for subdir1, dirs1, files1 in os.walk(workdir):
                    for file in files1:              
                        if file.find('2-s2')==0:
                            s_parser=parser.Parser()
                            pub=s_parser.parse(os.path.join(subdir1,file),pub_authors,pub_references,pub_addresses)
                            pubs.append(pub[0].__dict__)
                            authors.extend(pub[1])
                            references.extend(pub[2])
                            addresses.extend(pub[3])
                            pub_authors=[]
                            pub_references=[]
                            pub_addresses=[]
                shutil.rmtree(new_dir)
                s_parser.upsert(pubs,authors,addresses,references)
                pubs=[]
                authors=[]
                addresses=[]
                references=[]      
    
if __name__ == "__main__":
    main()

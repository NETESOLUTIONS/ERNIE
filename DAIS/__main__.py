#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Oct 19 14:23:39 2018

Usage: python -filename
@author: siyu
"""

import sys
import DAIS_parser as parser

def main():
    in_arr = sys.argv

    if '-filename' not in in_arr:
        print ("No filename")
        raise NameError('error: file name is not provided')
    else:
        input_filename = in_arr[in_arr.index('-filename') + 1]
        
    d_parser=parser.Parser()
    d_parser.data_load(input_filename)
    
if __name__ == "__main__":
    main()    
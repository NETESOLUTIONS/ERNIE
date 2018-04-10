# coding=utf-8

'''
Function:   	This is a project to extract the WOS XML publications data and insert data directly into Data Base


USAGE:  	python wos_xml_parser.py -filename file_name -csv_dir csv_file_directory
Author: 	Akshat Maltare
Date:		03/24/2018
Changes:
'''
import re
import exceptions
import time
import datetime
import string
import sys
import os
import Parser
import psycopg2
import counters as ct

hostname = 'localhost'
username = 'akshat'
password = 'akshat'
database = 'pardi'


def main():
    start_time = datetime.datetime.now()

    myConnection = psycopg2.connect(host=hostname, user=username, password=password, dbname=database)

    curs = myConnection.cursor()
    curs.execute("SET search_path TO public")
    counters = ct.counters()
    # Reading the file name from input
    # Check if the file name is provided, otherwise the program will stop.
    in_arr = sys.argv
    if '-filename' not in in_arr:
        print "No filename"
        raise NameError('error: file name is not provided')
    else:
        input_filename = in_arr[in_arr.index('-filename') + 1]
    if '-offset' not in in_arr:
        offset = 0
    else:
        offset = in_arr[in_arr.index('-offset') + 1]

    print "Parsing", input_filename, "..."

    # Reading XML file as a text file line by line
    try:
        with open(input_filename) as f:
            init_buffer_REC = '<?xml version="1.0" encoding="UTF-8"?>'
            init_buffer_REC = init_buffer_REC + '<records xmlns="http://clarivate.com/schema/wok5.27/public/FullRecord">'
            buffer_REC = ''
            is_rec = False
            count = 0
            offset_count=0
            for line in f:
                offset_count=offset_count+1
                # adding all the lines that represent a REC into a buffer which is then sent to the parser for further processing
                if(offset_count==offset or offset==0):
                    if(offset!=0):
                        offset=offset+4
                    else:
                        offset=offset+1
                    if '</REC' in line:
                        count = count + 1
                        buffer_REC = ''.join([buffer_REC, line])
                        # buffer_REC= buffer_REC + line
                        buffer_REC = buffer_REC + "</records>"
                        # print buffer_REC
                        r_parser = Parser.Parser()
                        counters = r_parser.parse(buffer_REC, counters, input_filename, curs)
                        is_rec = False
                        if count % 1000 == 0:
                            myConnection.commit()
                            print str(count) + " number of records have been inserted into the database successfully"
                        # myConnection.commit()
                        # break

                    elif '<REC' in line:
                        buffer_REC = init_buffer_REC
                        # print buffer_REC
                        is_rec = True
                    if is_rec:
                        buffer_REC = ''.join([buffer_REC, line])
    except IOError:
        print "Could not read file:", input_filename

    # print(string)

    # Root = ET.fromstring(buffer_REC)pi

    print "Parsed", input_filename
    if myConnection is not None:
        myConnection.close()
        print "Connection to the database closed"

    process_time = str(divmod((datetime.datetime.now() - start_time).total_seconds(), 60))
    log_file = open("performance_log.txt", 'a')
    log_file.write(process_time)
    log_file.close()
    print process_time


if __name__ == "__main__":
    main()

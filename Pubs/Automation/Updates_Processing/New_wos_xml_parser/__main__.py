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
import pytz

batchsize=1
offset=1
init_offset=1
ncommit=1000
estimate_nrec=None
process_time=0
processing_time_taken=0
def main():
    in_arr = sys.argv
    estimate_nrec = None
    # Reading the file name from input
    # Check if the file name is provided, otherwise the program will stop.


    if '-filename' not in in_arr:
        print "No filename"
        raise NameError('error: file name is not provided')
    else:
        input_filename = in_arr[in_arr.index('-filename') + 1]

    filesize=os.path.getsize(input_filename)

    #print(filesize)
    # Reading the processes from input(batch size value signifies the number of processes running parallely at a time, batchvalues are provided to run multiple batches in parallel)
    # Check if the file name is provided, otherwise the program will stop.

    if '-processes' not in in_arr:
        processes = 1
    else:
        processes = int(in_arr[in_arr.index('-processes') + 1])


    # Reading the offset from input(different offset values are provided to run multiple batches in parallel)
    # Check if the file name is provided, otherwise the program will stop.
    if '-offset' not in in_arr:
        offset = 1
        init_offset=1
    else:
        offset = int(in_arr[in_arr.index('-offset') + 1])
        init_offset=offset




    #Reading the ncommit to be able to reduce or increase the number of insertions after which the commit should be called in the data base to improve, tune the performance of the data base
    if '-ncommit' not in in_arr:
        ncommit = 1000
    else:
        ncommit = int(in_arr[in_arr.index('-ncommit') + 1])


    print "Parsing", input_filename, "..."


    #noting the time of the start of the script to calculate the performance of the sript
    start_time = datetime.datetime.now(pytz.timezone('US/Eastern'))


    # Establishing connection to the database for running upsert commands once the parsing is done
    conn = psycopg2.connect("")
    with conn:
        with conn.cursor() as curs:
            # Reading XML file as a text file line by line

            #curs.execute("SELECT "\
                            #"avg(record_count) AS avg_records_per_file, "\
                            #\"avg(source_file_size) AS avg_file_size, "\
                            #"avg(CAST(source_file_size AS REAL) / record_count) AS avg_record_size, "\
                            #"avg(CAST(record_count AS REAL) / source_file_size) AS avg_factor "\
                            #"FROM ("\
                                    #"SELECT * "\
                                    #"FROM update_log_wos "\
                                    #"ORDER BY id DESC "\
                                    #"LIMIT 10) sq;")
            #rec=curs.fetchone()
            #if(rec[3] is not None):
            #    estimate_nrec= filesize*float(rec[3])
            #else:
            #    estimate_nrec = None


            with open(input_filename) as f:
                init_buffer_REC = '<?xml version="1.0" encoding="UTF-8"?>'
                init_buffer_REC = init_buffer_REC + '<records xmlns="http://clarivate.com/schema/wok5.27/public/FullRecord">'
                buffer_REC = ''
                is_rec = False
                count = 0
                recordNo=0
                offset_count=0
                for line in f:
                    if '</REC' in line:
                        recordNo=recordNo+1
                        offset_count=offset_count+1
                        if(offset_count==offset):
                            count=count+1
                            offset= offset + processes
                            buffer_REC = ''.join([buffer_REC, line])
                            buffer_REC = buffer_REC + "</records>"
                            r_parser = Parser.Parser()
                            r_parser.parse(buffer_REC, input_filename, curs)
                            is_rec = False
                            if count % ncommit == 0:
                                commit(conn, count, recordNo)
                                processing_time_taken=(datetime.datetime.now(pytz.timezone('US/Eastern')) - start_time).total_seconds()
                                if(estimate_nrec is not None):
                                    #print(datetime.timedelta(seconds=int((processing_time_taken/recordNo)*(estimate_nrec - recordNo))))
                                    estimated_time=(datetime.datetime.now(pytz.timezone('US/Eastern'))+datetime.timedelta(seconds=int((processing_time_taken/recordNo)*(estimate_nrec - recordNo))))
                                    ##converting time zone from UTC to ET

                                    estimated_time_ET= estimated_time.strftime("%H:%M:%S")
                                    print "Job ETA:", estimated_time_ET, "ET. Job speed: ", \
                                        count/processing_time_taken*60, "publications/min."

                    elif '<REC' in line:
                        buffer_REC = init_buffer_REC
                        is_rec = True
                    if is_rec:
                        buffer_REC = ''.join([buffer_REC, line])
                print "Parsed", input_filename
                if conn is not None:
                    commit(conn, count, recordNo)
                    if(init_offset==1):
                        #curs.execute("insert into update_log_wos(source_filename,source_file_size,record_count,"\
                                 #"process_start_time) values(%s,%s,%s,%s);",
                                 #(input_filename,str(filesize),str(recordNo),str(start_time)))
                        pass

    # Unlike file objects or other resources, exiting the connection's with block doesn't close
    # the connection but only the transaction associated with it: a connection can be used in more than
    # a with statement and each with block is effectively wrapped in a separate transaction.
    conn.close()

    process_time = str(divmod((datetime.datetime.now(pytz.timezone('US/Eastern')) - start_time).total_seconds(), 60))
    log_file = open("performance_log.txt", 'a')
    log_file.write(process_time)
    log_file.close()
    print process_time


def commit(conn, count, recordNo):
    conn.commit()
    print "At publication #" + str(recordNo) + ".", count, "publications have been upserted by this job."

if __name__ == "__main__":
    main()

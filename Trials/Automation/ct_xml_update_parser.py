# coding=utf-8

'''
This parser extracts Clinical Trial (CT) data from provided XML and directly populates SQL tables

Usage: python ct_xml_update_parser.py {files}

Author: VJ Davey
Create Date: 06/14/2018
Modified:
'''
import psycopg2
import psycopg2.extensions
import datetime
import re
import sys
import parser
import multiprocessing as mp
import threading as thr

# Each thread gets its own postgres connection. The file holding the list of XML files is a shared resource. Pop a number of files off the stack and process until no more remain.
def parse_and_load(xml_file_list,lock,fetch_size=500):
    # Open and configure a PostgreSQL connection for each thread
    conn=psycopg2.connect("")
    conn.set_client_encoding('UTF8')
    conn.autocommit=True
    curs=conn.cursor()

    # Acquire thread lock and pop a number of XML files off the stack
    lock.acquire()
    file_list_chunk=[xml_file_list.readline().rstrip('\n') for line in range(fetch_size)]#pop a number of files off the stack
    file_list_chunk=[i for i in file_list_chunk if i!='']
    lock.release()

    # While there are a number of files left to process, process those files, build PostgreSQL bulk insert queries, and execute those queries
    while len(file_list_chunk)>0:
        job_dict = {'counter':0, 'columns':{}, 'pkeys':{}}
        for xml_file in file_list_chunk:
            #print("attempting to parse file: {}".format(xml_file)) # uncomment for DEBUG purposes only
            parsed_info=parser.parse(xml_file)

            if parsed_info==None:
                print("No nct_id found, file %s skipped"%(xml_file))
                continue

            ct_dict=parsed_info[0];job_dict['columns']={table:sorted(ct_dict[table][0].keys()) for table in ct_dict.keys() if ct_dict[table]!=[]}
            job_dict['pkeys']=parsed_info[1]
            # For each table in the returned dictionary, mogrify necessary tups and append to dictionary key value following check of key existence
            for table in job_dict['columns'].keys():
                tups=[tuple(row[column] for column in job_dict['columns'][table]) for row in ct_dict[table]]
                if table not in job_dict.keys():
                    job_dict[table]=",".join([curs.mogrify("("+("%s,"*(len(tup)-1))+"%s" +")", tup).decode('utf-8') for tup in tups])
                else:
                    job_dict[table]=",".join([",".join([curs.mogrify("("+("%s,"*(len(tup)-1))+"%s" +")", tup).decode('utf-8') for tup in tups])] + [job_dict[table]] )
            #print("parsed file: {}".format(xml_file)) # uncomment for DEBUG purposes only

        for table in job_dict['columns'].keys():
            curs.execute("INSERT INTO {}({}) VALUES {} ON CONFLICT({}) DO UPDATE SET {};".format(
                                                table,
                                                ",".join(job_dict['columns'][table]),
                                                job_dict[table],
                                                ",".join(job_dict['pkeys'][table]),
                                                ",".join(["{} = EXCLUDED.{}".format(column,column) for column in job_dict['columns'][table]])
                                                ).replace("\'NULL\'","NULL"))
        conn.commit()
        lock.acquire()
        file_list_chunk=[xml_file_list.readline().rstrip('\n') for line in range(fetch_size)]#pop a number of files off the stack
        file_list_chunk=[i for i in file_list_chunk if i!='']
        lock.release()

# Set up resources via the multiprocessing Manager dynamically based on the number of machine cores
lock=thr.Lock()
with open(sys.argv[1]) as to_do_list:
    processes=[thr.Thread(target=parse_and_load, args=(to_do_list,lock)) for core in range(4)]
    print("STARTING CLINICAL TRIAL PARSING WITH {} PARALLEL PROCESSES".format(len(processes)))
    for p in processes:
        p.start()
    for p in processes:
        p.join()

# Notify process completion
print("Completed CT parsing at {}...".format(datetime.datetime.now().time()))

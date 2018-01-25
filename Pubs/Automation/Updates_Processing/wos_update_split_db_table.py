"""
This script splits a table table_name in database to small chunks of subtables
and creates 1. csv files for these subtables; 2. a SQL file that can run to
load csv files to these subtables.

This version is customized for WOS update. For the general-purpose version
please see split_db_table.py in main folder: PARDI_WoS.

Usage: python split_db_table.py -tablename table_name -rowcount chunk_length -csv_dir work_dir
       where table_name = table to be splitted,
       chunk_length = a number specifying number of rows in each chunk (default=10000),
       work_dir = working directory.

Note: 1. To load csv data to each subtable, you need to run a seperate command in shell afterwards:
         psql -d ernie -f load_csv_table.sql
      2. Change SQL username to your own name (here it is 'samet') before running.

Author: Shixin Jiang, Lingtian "Lindsay" Wan
Create Date: 06/06/2016
Modified: 06/06/2016, Lindsay Wan, added customized path, dropped old tables before creating new ones
          02/22/2017, Lindsay Wan, change username from lindsay to samet

"""

import csv
import os
import psycopg2
import sys
from psycopg2.extensions import AsIs
csv.field_size_limit(sys.maxsize)

def create_csv(cur, input_tablename, csv_filename):
  # Create CSV file for the table
    cur.execute("""COPY %s TO  %s  DELIMITER ',' CSV HEADER ENCODING 'UTF8';""",(AsIs(input_tablename),csv_filename))

def drop_old_tables(cur, input_tablename):
    cur.execute("""SELECT 'DROP TABLE IF EXISTS '||table_name||';' FROM INFORMATION_SCHEMA.TABLES WHERE table_name LIKE '%s_%%';""",
                (AsIs(input_tablename),))
    drop_list=[]
    for dropcommand in cur:
        drop_list.append(dropcommand[0])
    for listcommand in drop_list:
        cur.execute("""%s""",(AsIs(listcommand),))
    cur.execute("""commit;""")

def create_table(cur, input_tablename, current_tablename):
  # Create split table from master table
  try:
    cur.execute("""CREATE TABLE public.%s TABLESPACE wos AS SELECT * FROM  %s  LIMIT 0;""",
                (AsIs(current_tablename),AsIs(input_tablename)))
    cur.execute("""commit;""")
  except:
    print "It cannot create table!"

def insert_table(cur, split_table,csv_filename):
    cur.execute("""COPY %s FROM  %s  CSV HEADER;""",(AsIs(split_table),csv_filename))
    cur.execute("""commit;""")

def split(cur, filehandler, input_tablename, load_file_writer,
          split_tablename_writer, delimiter=',', row_limit=10000,
          output_name_template='output_%s.csv', output_path='.',
          keep_headers=True):
  """
  Splits a CSV file into multiple pieces.

  Arguments:

    `row_limit`: The number of rows you want in each output file. 10,000 by default.
    `output_name_template`: A %s-style template for the numbered output files.
    `output_path`: Where to stick the output files.
    `keep_headers`: Whether or not to print the headers in each output file.

  """

  reader = csv.reader(filehandler, delimiter=delimiter)
  current_piece = 1
  current_out_path = os.path.join(
     output_path,
     output_name_template  % current_piece
  )
  current_out_writer = csv.writer(open(current_out_path, 'w'),
                                  delimiter=delimiter)
  current_limit = row_limit
  if keep_headers:
    headers = next(reader)
    current_out_writer.writerow(headers)
  current_tablename = input_tablename+'_'+str(current_piece)
  create_table(cur, input_tablename,current_tablename)
  copy_command = "copy "+current_tablename+" from '"+current_out_path+"' delimiter ',' HEADER CSV; \n"
  load_file_writer.write((copy_command))
  split_tablename_writer.write((current_tablename+'\n'))

  for i, row in enumerate(reader):
    if i + 1 > current_limit:
        #insert_table(current_tablename,current_out_path)
        current_piece += 1
        current_limit = row_limit * current_piece
        current_out_path = os.path.join(
           output_path,
           output_name_template  % current_piece
        )
        current_out_writer = csv.writer(open(current_out_path, 'w'),
                                        delimiter=delimiter)
        if keep_headers:
            current_out_writer.writerow(headers)
        current_tablename = input_tablename+'_'+str(current_piece)
        create_table(cur, input_tablename,current_tablename)
        copy_command = "copy "+current_tablename+" from '"+current_out_path+"' delimiter ',' HEADER CSV; \n"
        load_file_writer.write((copy_command))
        split_tablename_writer.write((current_tablename+'\n'))
    current_out_writer.writerow(row)
  #insert_table(current_tablename,current_out_path)

if __name__ == '__main__':
    # Check if the file name is provided, otherwise the program will stop.
    in_arr = sys.argv
    if '-tablename' not in in_arr:
       print "No table name"
       raise NameError('error: table name is not provided')
    else:
       input_tablename = in_arr[in_arr.index('-tablename') + 1]

    # Check if the max number of rows in split table is provided, otherwise the program will stop.
    if '-rowcount' not in in_arr:
       print "No row count"
       raise NameError('error: row count is not provided')
    else:
       input_rowcount= int(in_arr[in_arr.index('-rowcount') + 1])

    if '-csv_dir' not in in_arr:
        print "Now directory provided"
        raise NameError('error: csv directory is not provided')
    else: csv_dir = in_arr[in_arr.index('-csv_dir') + 1]
    #csv_dir = '/erniedata1/split_table_csv/'

    load_csv_filename = os.path.join(csv_dir, 'load_csv_table.sql')
    load_file_writer = open(load_csv_filename, 'w')

    split_tablename = os.path.join(csv_dir, 'split_tablename.txt')
    split_tablename_writer = open(split_tablename, 'w')

    try:
       os.stat(csv_dir)
    except:
       os.mkdir(csv_dir)

    # Open connection to PARDI database
    try:
       conn=psycopg2.connect("dbname='ernie' user='ernie_admin'")
    except:
       print "I am unable to connect to the database ernie."

    cur = conn.cursor()

    csv_filename=csv_dir+input_tablename+'.csv'
    create_csv(cur, input_tablename,csv_filename)
    drop_old_tables(cur, input_tablename)
    split(cur, open(csv_filename, 'r'), input_tablename, load_file_writer,
          split_tablename_writer,
          output_name_template=input_tablename+'_%s.csv',
          row_limit=input_rowcount, output_path=csv_dir)
    cur.close()
    load_file_writer.close()
    split_tablename_writer.close()

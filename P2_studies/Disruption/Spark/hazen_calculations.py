#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Oct 22 13:28:11 2019

@author: sitaram

Generate citation counts for scopus_references
Results to be used for hazen percentile calculations
"""

from os.path import expanduser, join
from pyspark.sql import SparkSession
from pyspark.sql import Row
from pyspark.sql import SQLContext
import pyspark.sql.types as sql_type
import time
import pandas as pd
import datetime as dt
import argparse
import psycopg2


# Functions to handle RW operations from/to PostgreSQL
def read_postgres_table_into_HDFS(table_name,connection_string,properties,hdfs_name,fetchsize=10000):
    spark.read.option("fetchsize",fetchsize).jdbc(url='jdbc:{}'.format(connection_string), table=table_name, properties=properties).write.mode("overwrite").saveAsTable(hdfs_name)
def write_table_to_postgres(spark_table_name,postgres_table_name,connection_string,properties,numPartitions=8):
    df=spark.table(spark_table_name)
    df.write.option("numPartitions", numPartitions).jdbc(url='jdbc:{}'.format(connection_string), table=postgres_table_name, properties=properties, mode="overwrite")

if __name__ == "__main__":
    # Set up and argument read in
    warehouse_location = '/user/spark/data'
    spark = SparkSession \
        .builder \
        .appName("Scopus Citation Data") \
        .config("spark.sql.warehouse.dir", warehouse_location) \
        .enableHiveSupport() \
        .getOrCreate()
    spark.conf.set("spark.sql.autoBroadcastJoinThreshold", -1)

    parser = argparse.ArgumentParser(description='''
     This script interfaces with the PostgreSQL database and then creates summary tables for the Abt project
    ''', formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('-ph','--postgres_host',help='the server hosting the PostgreSQL server',default='localhost',type=str)
    parser.add_argument('-pd','--postgres_dbname',help='the database to query in the PostgreSQL server',type=str,required=True)
    parser.add_argument('-pp','--postgres_port',help='the port hosting the PostgreSQL service on the server', default='5432',type=int)
    parser.add_argument('-U','--postgres_user',help='the PostgreSQL user to log in as',required=True)
    parser.add_argument('-W','--postgres_password',help='the password of the PostgreSQL user',required=True)
    args = parser.parse_args()
    url = 'postgresql://{}:{}/{}'.format(args.postgres_host,args.postgres_port,args.postgres_dbname)
    properties = {'user': args.postgres_user, 'password': args.postgres_password}

    # Read in tables from PostgreSQL
    print("STARTED: READING TABLES FROM POSTGRES INTO HDFS")
    input_tables = {'scopus_references':"(SELECT scp,ref_sgr FROM scopus_references) foo",
                    'scopus_publication_groups':"(SELECT sgr,pub_year FROM scopus_publication_groups) foo"}
    for table in input_tables:
        print('STARTED: IMPORT FOR {}'.format(table))
        print(input_tables[table])
        read_postgres_table_into_HDFS(input_tables[table],url,properties,table)
        print('COMPLETED: IMPORT FOR {}'.format(table))
    print("COMPLETED: READING TABLES FROM POSTGRES INTO HDFS")

    #########################################################

    ## REFERENCES TABLES CREATION ##

    # Subset WoS references to a smaller table which only considers cited references of the target documents
    # Salvage data in the cited_source_uid column where possible by prepending 'WOS:' to those IDs which are simply chains of numbers via a CASE statement

    citation_counts=spark.sql('''
                                SELECT ref_sgr AS scp,count(*) AS citation_count 
                                FROM scopus_references GROUP BY ref_sgr''').registerTempTable("citation_counts")

    citation_counts=spark.sql('''
                                SELECT a.*,b.pub_year
                                FROM citation_counts a
                                INNER JOIN
                                scopus_publication_groups b
                                ON a.scp=b.sgr''')

    citation_counts.write.mode("overwrite").saveAsTable("scopus_citation_counts")


    spark.sql("select count(*) FROM scopus_citation_counts ").show()


    # Export the final tables to PostgreSQL
    print("STARTED: WRITING TABLES FROM HDFS INTO POSTGRES")
    output_tables = ['scopus_citation_counts']
    for table in output_tables:
        print('STARTED: EXPORT FOR {}'.format(table))
        write_table_to_postgres(table,table,url,properties)
        print('COMPLETED: EXPORT FOR {}'.format(table))
    print("COMPLETED: WRITING TABLES FROM HDFS INTO POSTGRES")

    # TODO:Introduce code to export the data into Oracle if possible
    spark.stop()
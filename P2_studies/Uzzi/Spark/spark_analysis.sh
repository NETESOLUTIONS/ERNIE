#!/usr/bin/env bash
#** Usage notes are incorporated into online help (-h). The format mimics a manual page.
if [[ $1 == "-h" ]]; then
  cat <<'HEREDOC'
NAME
  spark_analysis.sh -- import data from PostgreSQL, analyze in PySpark, and export back to PostgreSQL

SYNOPSIS
  spark_analysis.sh
  spark_analysis.sh -h: display this help

DESCRIPTION
  Analysis is performed in the Spark Cluster

NOTE
  Success of this job is dependent upon pre-established Azure privileges and a saved connection via cli

ENVIRONMENT
  Required environment variables:
  * POSTGRES_DATABASE                           the postgres database you wish to connect to
  * POSTGRES_USER                               the postgres user you wish to connect as
  * POSTGRES_PASSWORD                           a PostgreSQL password for the target server
  * POSTGRES_HOSTNAME                           the IP address of the server hosting the data
  * POSTGRES_SCHEMA                             the schema to execute code against
HEREDOC
  exit 1
fi


# First, clean the HDFS if needed
echo "*** CLEANING HIVE DATA WAREHOUSE : $(date)"
hdfs dfs -rm -r /hive/warehouse/*
echo "*** CLEANING ANY MISCELLANEOUS DATA : $(date)"
hdfs dfs -rm -r /user/spark/data/*

# Next, import the target tables from the PostgreSQL database
echo "*** SPARK IMPORT STARTED : $(date) ***"
echo "*** LOADING dataset1995 ***"
sqoop import --verbose --connect jdbc:postgresql://${POSTGRES_HOSTNAME}/${POSTGRES_DATABASE} \
--username ${POSTGRES_USER} --password ${POSTGRES_PASSWORD} -m 1 --table dataset1995 \
--columns source_id,source_year,source_document_id_type,source_issn,cited_source_uid,reference_year,reference_document_id_type,reference_issn \
--map-column-java source_id=String,source_year=String,source_document_id_type=String,\
source_issn=String,cited_source_uid=String,reference_year=Integer,\
reference_document_id_type=String,reference_issn=String \
--warehouse-dir=/hive/warehouse --hive-import --hive-table dataset1995 -- --schema ${POSTGRES_SCHEMA}
echo "*** SPARK IMPORT COMPLETED : $(date) ***"

# After data is imported, submit a job to pyspark that will make use of the imported table(s)
$SPARK_HOME/bin/spark-submit --driver-memory 8g  ./permute_in_spark.py

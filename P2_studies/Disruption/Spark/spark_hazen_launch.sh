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
hdfs dfs -rm -r -f /hive/warehouse/*
echo "*** CLEANING ANY MISCELLANEOUS DATA : $(date)"
hdfs dfs -rm -r -f /user/spark/data/*

# Ensure the necessary libraries are installed/updated
wget https://jdbc.postgresql.org/download/postgresql-42.2.6.jar
sudo cp postgresql-42.2.6.jar /usr/hdp/current/sqoop-client/lib/
sudo /usr/bin/anaconda/envs/py35/bin/conda install --name py35 -y  psycopg2
#sudo /usr/bin/anaconda/bin/conda install -y --debug psycopg2
#sudo /usr/bin/anaconda/bin/conda update -y --debug numpy
#sudo /usr/bin/anaconda/bin/conda update -y --debug pandas

#PYSPARK_PYTHON=/usr/bin/anaconda/envs/py35/bin/python
# Next run PySpark calculations
$SPARK_HOME/bin/spark-submit --driver-memory 15g --executor-memory 25G --num-executors 8 --executor-cores 4 \
  --driver-class-path $(pwd)/postgresql-42.2.6.jar --jars $(pwd)/postgresql-42.2.6.jar \
  ./hazen_calculations.py -ph ${POSTGRES_HOSTNAME} -pd ${POSTGRES_DATABASE} -U ${POSTGRES_USER} -W "${POSTGRES_PASSWORD}"
#!/usr/bin/env bash
#** Usage notes are incorporated into online help (-h). The format mimics a manual page.
if [[ $1 == "-h" ]]; then
  cat <<'HEREDOC'
NAME
  shuffle_performance_analysis.sh

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
  * TARGET_DATASET                              the target dataset to evaluate
  * NUM_PERMUTATIONS                            num of permutations to run
  * NUM_EXECUTORS                               num executors for the spark job
  * EXECUTOR_CORES                              num of cores to allocate per executor for the spark job
  * EXECUTOR_MEMORY                             amount of memory to allocate per executor for the spark job
HEREDOC
  exit 1
fi


# First, clean the HDFS if needed
echo "*** CLEANING HIVE DATA WAREHOUSE : $(date)"
hdfs dfs -rm -r -f /hive/warehouse/*
echo "*** CLEANING ANY MISCELLANEOUS DATA : $(date)"
hdfs dfs -rm -r -f /user/spark/data/*

# Next run PySpark calculations - TODO: fiddle around with executor config for speed ups
$SPARK_HOME/bin/spark-submit --driver-memory 10g \ #--num-executors ${NUM_EXECUTORS} --executor-cores ${EXECUTOR_CORES} --executor-memory ${EXECUTOR_MEMORY} \
   --driver-class-path $(pwd)/postgresql-42.0.0.jar --jars $(pwd)/postgresql-42.0.0.jar \
  ./shuffle_times.py -tt ${TARGET_DATASET} -ph ${POSTGRES_HOSTNAME} -pd ${POSTGRES_DATABASE} -U ${POSTGRES_USER} -W "${POSTGRES_PASSWORD}" -i ${NUM_PERMUTATIONS}

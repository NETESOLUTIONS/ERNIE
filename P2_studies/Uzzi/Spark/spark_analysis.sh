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
  * TARGET_DATASET                              the target dataset to evaluate
  * NUM_PERMUTATIONS                            num of permutations to run
HEREDOC
  exit 1
fi


# First, clean the HDFS if needed
echo "*** CLEANING HIVE DATA WAREHOUSE : $(date)"
hdfs dfs -rm -r -f /hive/warehouse/*
echo "*** CLEANING ANY MISCELLANEOUS DATA : $(date)"
hdfs dfs -rm -r -f /user/spark/data/*

# Next, import the target table from the PostgreSQL database
echo "*** SPARK IMPORT STARTED : $(date) ***"
echo "*** LOADING ${TARGET_DATASET} ***"
/usr/bin/hive -e "DROP TABLE IF EXISTS ${TARGET_DATASET}"
sqoop import --verbose --connect jdbc:postgresql://${POSTGRES_HOSTNAME}/${POSTGRES_DATABASE} \
--username ${POSTGRES_USER} --password ${POSTGRES_PASSWORD} -m 1 --table ${TARGET_DATASET} \
--columns source_id,source_year,source_document_id_type,source_issn,cited_source_uid,reference_year,reference_document_id_type,reference_issn \
--map-column-java source_id=String,source_year=String,source_document_id_type=String,\
source_issn=String,cited_source_uid=String,reference_year=Integer,\
reference_document_id_type=String,reference_issn=String \
--warehouse-dir=/hive/warehouse --hive-import --hive-table ${TARGET_DATASET} -- --schema ${POSTGRES_SCHEMA}
echo "*** SPARK IMPORT COMPLETED : $(date) ***"
echo "*** PERFORMING OBSERVED FREQUENCY CALCULATIONS FOR BASE SET: $(date) ***"
$SPARK_HOME/bin/spark-submit --driver-memory 4g  ./uzzi_count_and_analyze.py -tt ${TARGET_DATASET} -o "START"
echo "*** COMPLETED OBSERVED FREQUENCY CALCULATIONS FOR BASE SET: $(date) ***"



for (( i=0; i<$NUM_PERMUTATIONS; i++ )); do
  # Then, import the target table's shuffled version from the PostgreSQL database
  echo "*** SPARK IMPORT STARTED : $(date) ***"
  echo "*** LOADING ${TARGET_DATASET}_shuffled , PERMUTATION ${i} ***"
  /usr/bin/hive -e "DROP TABLE IF EXISTS ${TARGET_DATASET}_shuffled"
  sqoop import --verbose --connect jdbc:postgresql://${POSTGRES_HOSTNAME}/${POSTGRES_DATABASE} \
  --username ${POSTGRES_USER} --password ${POSTGRES_PASSWORD} -m 1 --table ${TARGET_DATASET}_shuffled \
  --columns source_id,source_year,source_document_id_type,source_issn,shuffled_cited_source_uid,shuffled_reference_year,shuffled_reference_document_id_type,shuffled_reference_issn \
  --map-column-java source_id=String,source_year=String,source_document_id_type=String,\
source_issn=String,shuffled_cited_source_uid=String,shuffled_reference_year=Integer,\
shuffled_reference_document_id_type=String,shuffled_reference_issn=String \
  --warehouse-dir=/hive/warehouse --hive-import --hive-table ${TARGET_DATASET}_shuffled -- --schema ${POSTGRES_SCHEMA}
  echo "*** SPARK IMPORT COMPLETED, PERMUTATION ${i} : $(date) ***"

  # After data is imported, submit a job to pyspark that will make use of the imported tables
  echo "*** PERFORMING OBSERVED FREQUENCY CALCULATIONS FOR PERMUTATION ${i}: $(date) ***"
  $SPARK_HOME/bin/spark-submit --driver-memory 4g  ./uzzi_count_and_analyze.py -tt ${TARGET_DATASET}_shuffled -o "COUNT" -i ${i}
  echo "*** COMPLETED OBSERVED FREQUENCY CALCULATIONS FOR PERMUTATION ${i}: $(date) ***"
done


# After that, perform final table construction
echo "*** PERFORMING OBSERVED FREQUENCY CALCULATIONS FOR PERMUTATION ${i}: $(date) ***"
$SPARK_HOME/bin/spark-submit --driver-memory 4g  ./uzzi_count_and_analyze.py -tt ${TARGET_DATASET} -o "ANALYZE" -i ${NUM_PERMUTATIONS}
echo "*** COMPLETED OBSERVED FREQUENCY CALCULATIONS FOR PERMUTATION ${i}: $(date) ***"


#TODO: Export data back into ERNIE PostgreSQL with Sqoop

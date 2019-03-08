from pyspark import Row
from pyspark.sql import SparkSession
from pyspark.sql.functions import rand
from pyspark.sql.functions import monotonically_increasing_id
from pyspark.sql import SQLContext
import time,sys
import argparse
import pandas as pd
import datetime
import numpy as np
from pyspark.sql.functions import col, udf, lit,struct
import pyspark.sql.types as sql_type
import threading as thr
import psycopg2


# Shuffle dataset in Spark -- must use rand() here instead of random per https://spark.apache.org/docs/2.4.0/api/sql/#rand
def spark_shuffle_data(table_name):
    sql = '''
        SELECT sq.source_id,
        sq.source_year,
        sq.source_document_id_type,
        sq.source_issn,
        sq.shuffled_cited_source_uid,
        sq.shuffled_reference_year,
        sq.shuffled_reference_document_id_type,
        sq.shuffled_reference_issn
       FROM ( SELECT a.source_id,
                a.source_year,
                a.source_document_id_type,
                a.source_issn,
                COALESCE(lead(a.cited_source_uid, 1) OVER (PARTITION BY a.reference_year ORDER BY (rand())), first_value(a.cited_source_uid) OVER (PARTITION BY a.reference_year ORDER BY (rand()))) AS shuffled_cited_source_uid,
                COALESCE(lead(a.reference_year, 1) OVER (PARTITION BY a.reference_year ORDER BY (rand())), first_value(a.reference_year) OVER (PARTITION BY a.reference_year ORDER BY (rand()))) AS shuffled_reference_year,
                COALESCE(lead(a.reference_document_id_type, 1) OVER (PARTITION BY a.reference_year ORDER BY (rand())), first_value(a.reference_document_id_type) OVER (PARTITION BY a.reference_year ORDER BY (rand()))) AS shuffled_reference_document_id_type,
                COALESCE(lead(a.reference_issn, 1) OVER (PARTITION BY a.reference_year ORDER BY (rand())), first_value(a.reference_issn) OVER (PARTITION BY a.reference_year ORDER BY (rand()))) AS shuffled_reference_issn
               FROM {} a) sq
      GROUP BY sq.source_id, sq.source_year, sq.source_document_id_type, sq.source_issn, sq.shuffled_cited_source_uid, sq.shuffled_reference_year, sq.shuffled_reference_document_id_type, sq.shuffled_reference_issn
     HAVING count(1) = 1'''.format(table_name)
    return spark.sql(sql)

# Functions to handle RW operations to PostgreSQL
def read_postgres_table_into_HDFS(table_name,connection_string,properties):
    spark.read.jdbc(url='jdbc:{}'.format(connection_string), table=table_name, properties=properties).write.mode("overwrite").saveAsTable(table_name)
def read_postgres_table_into_memory(table_name,connection_string,properties):
    spark.read.jdbc(url='jdbc:{}'.format(connection_string), table=table_name, properties=properties).write.mode("overwrite").saveAsTable(table_name)
def write_table_to_postgres(spark_table_name,postgres_table_name,connection_string,properties):
    df=spark.table(spark_table_name)
    df.write.jdbc(url='jdbc:{}'.format(connection_string), table=postgres_table_name, properties=properties, mode="overwrite")

# User Defined Functions for use with Spark data
'''
    A pass through Welford's algorithm is used here to update values stored in the SQL tables.

    Welford's algorithm, while potentially slower than the naive approach (Sum of Squares - derived from playing with the variance formula)
    due to there being a division operation at each pass rather than one big division at the end, is useful because it allows us to avoid a
    catastrophic cancellation event, which usually happens during the subtraction operation of the naive approach when working with
    high-value low-variance sets of data

    https://alessior.wordpress.com/2017/10/09/onlinerecursive-variance-calculation-welfords-method/
    https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance#Welford's_Online_algorithm
    https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance#Example
    https://en.wikipedia.org/wiki/Loss_of_significance
'''
def update_mean(current_mean,x,k):
    updated_mean = current_mean + (x - current_mean) / k
    return updated_mean

def welford_pass(x,current_mean,current_sum_squared_distances_from_mean, k):
    updated_mean = update_mean(current_mean,x,k)
    updated_sum_squared_distances_from_mean = current_sum_squared_distances_from_mean + (x - current_mean)*(x - updated_mean)
    return updated_sum_squared_distances_from_mean #can also return updated mean here, but Spark doesnt seem to play nice with a double return that can update two columns simultaneously -- might be worthwhile to test passing a tuple into the udf for this function at some point, i.e. store a tuple of floats in the database instead of two columns for M and S

def calculate_variance(sum_squared_distances_from_mean,k,ddof=0):
    if k-ddof < 1:
        return np.NaN
    return sum_squared_distances_from_mean/(k-ddof)

def calculate_std_dev(sum_squared_distances_from_mean,k,ddof=0):
    if k-ddof < 1:
        return np.NaN
    return np.sqrt(calculate_variance(sum_squared_distances_from_mean,k,ddof))

update_mean_udf = udf(lambda x: float(running_mean(x[0],x[1],x[2])), sql_type.DoubleType())
welford_pass_udf = udf(lambda x: float(running_std(x[0],x[1],x[2],x[3])), sql_type.DoubleType())
std_udf = udf(lambda x: float(calculate_std_dev(x[0],x[1],0)), sql_type.DoubleType()) ##TODO: adjust this based on whether team wants population or sample STDDEV

def obs_frequency_calculations(input_dataset):
    obs_df=spark.sql("SELECT source_id,reference_issn FROM {}".format(input_dataset))
    obs_df=obs_df.withColumn('id',monotonically_increasing_id())
    obs_df.createOrReplaceTempView('input_table')
    obs_df=spark.sql('''
            SELECT  journal_pair_A,
                    journal_pair_B,
                    count(*) as obs_frequency,
                    0.0 as current_mean,
                    0.0 as current_sum_squared_distances_from_mean,
                    0.0 as count
            FROM (
                    SELECT a.reference_issn as journal_pair_A, b.reference_issn as journal_pair_B
                    FROM input_table a
                    JOIN input_table b
                     ON a.source_id=b.source_id
                    WHERE a.reference_issn = b.reference_issn and a.id!=b.id
                     AND a.id < b.id
                    UNION ALL
                    SELECT a.reference_issn, b.reference_issn
                    FROM input_table a
                    JOIN input_table b
                     ON a.source_id=b.source_id
                    WHERE a.reference_issn < b.reference_issn) temp
            GROUP BY journal_pair_A,journal_pair_B''')
    spark.catalog.dropTempView('input_table')
    obs_df.write.mode("overwrite").saveAsTable("observed_frequencies")

def calculate_journal_pairs_freq(input_dataset,i):
    df=spark.sql("SELECT source_id,shuffled_reference_issn as reference_issn FROM {}".format(input_dataset))
    df=df.withColumn('id',monotonically_increasing_id())
    df.createOrReplaceTempView('bg_table')
    df=spark.sql('''
            SELECT  journal_pair_A,
                    journal_pair_B,
                    count(*) as bg_freq
            FROM (
                    SELECT a.reference_issn as journal_pair_A, b.reference_issn as journal_pair_B
                    FROM bg_table a
                    JOIN bg_table b
                     ON a.source_id=b.source_id
                    WHERE a.reference_issn = b.reference_issn
                    AND a.id!=b.id and a.id < b.id
                    UNION ALL
                    SELECT a.reference_issn,b.reference_issn
                    FROM bg_table a
                    JOIN bg_table b ON a.source_id=b.source_id
                    WHERE a.reference_issn < b.reference_issn) temp
            GROUP BY journal_pair_A,journal_pair_B''')
    df.createOrReplaceTempView('bg_table')
    # Join frequency counts from BG table to obs_frequency table
    temp_df=spark.sql('''
            SELECT  a.journal_pair_A,
                    a.journal_pair_B,
                    a.current_mean,
                    a.current_sum_squared_distances_from_mean,
                    a.count + CASE WHEN b.bg_freq IS NULL THEN 0 ELSE 1 END as count,
                    b.bg_freq
            FROM observed_frequencies a
            LEFT JOIN bg_table b
            ON a.journal_pair_A=b.journal_pair_A
             AND a.journal_pair_B=b.journal_pair_B ''')
    temp_df.createOrReplaceTempView('update_table')
    a = spark.table("update_table").withColumn('updated_mean', update_mean_udf(struct('current_mean','bg_freq','count')))
    b = a.withColumn('updated_sum_squared_distances_from_mean',welford_pass_udf(struct('bg_freq','current_mean','current_sum_squared_distances_from_mean','count')))
    b.registerTempTable("update_table_finished")
    df=spark.sql('''
            SELECT  a.journal_pair_A,
                    a.journal_pair_B,
                    a.obs_frequency,
                    b.updated_mean as current_mean,
                    b.updated_sum_squared_distances_from_mean as current_sum_squared_distances_from_mean,
                    b.count
            FROM observed_frequencies a
            LEFT JOIN update_table_finished b
            ON a.journal_pair_A=b.journal_pair_A
             AND a.journal_pair_B=b.journal_pair_B ''')
    df.write.mode("overwrite").saveAsTable("temp_observed_frequencies")
    temp_table=spark.table("temp_observed_frequencies")
    temp_table.write.mode("overwrite").saveAsTable("observed_frequencies")

def final_table(input_dataset,iterations):
    df=spark.sql("SELECT source_id,cited_source_uid,reference_issn FROM {}".format(input_dataset))
    df=df.withColumn('id',monotonically_increasing_id())
    df.createOrReplaceTempView('final_table')
    df=spark.sql('''
            SELECT a.source_id,
                   a.cited_source_uid AS wos_id_A,
                   b.cited_source_uid AS wos_id_B,
                   a.reference_issn AS journal_pair_A,
                   b.reference_issn AS journal_pair_B
            FROM final_table a
            JOIN final_table b
             ON a.source_id=b.source_id
            WHERE a.reference_issn = b.reference_issn
            AND a.id!=b.id and a.id < b.id
            UNION ALL
            SELECT a.source_id,
                   a.cited_source_uid,
                   b.cited_source_uid,
                   a.reference_issn,
                   b.reference_issn
            FROM final_table a
            JOIN final_table b
             ON a.source_id=b.source_id
            WHERE a.reference_issn < b.reference_issn ''')
    df.createOrReplaceTempView('final_table')
    df=spark.sql('''
            SELECT a.source_id,
                   '('||a.wos_id_A||','||a.wos_id_B||')' AS wos_id_pairs,
                   '('||a.journal_pair_A||','||a.journal_pair_B||')' AS journal_pairs,
                   b.obs_frequency,
                   b.mean,
                   CAST(b.z_scores AS double),
                   b.count,
                   b.std
            FROM final_table a
            JOIN z_scores_table b
            ON a.journal_pair_A=b.journal_pair_A
             AND a.journal_pair_B=b.journal_pair_B''')
    df.write.mode("overwrite").saveAsTable("output_table")

def z_score_calculations(input_dataset,iterations):
    a = spark.table("observed_frequencies").withColumn('std', std_udf(struct('current_sum_squared_distances_from_mean','count')))
    a.write.mode("overwrite").saveAsTable("z_score_prep_table")
    df=spark.sql('''
            SELECT journal_pair_A,journal_pair_B,obs_frequency,current_mean as mean,std,count,
            CASE
                WHEN std=0 AND (obs_frequency-current_mean) > 0
                    THEN 'Infinity'
                WHEN std=0 AND (obs_frequency-current_mean) < 0
                    THEN '-Infinity'
                WHEN std=0 AND (obs_frequency-current_mean) = 0
                    THEN NULL
                ELSE (obs_frequency-current_mean)/std
                END as z_scores
            FROM z_score_prep_table a
           ''').na.drop()
    df.write.mode("overwrite").saveAsTable("z_scores_table")
    final_table(input_dataset,iterations)

warehouse_location = '/user/spark/data'
spark = SparkSession.builder.appName("uzzi_analysis") \
                    .config("spark.sql.warehouse.dir", warehouse_location) \
                    .enableHiveSupport() \
                    .getOrCreate()
spark.conf.set("spark.sql.autoBroadcastJoinThreshold", -1)


# Collect user input and possibly override defaults based on that input
parser = argparse.ArgumentParser(description='''
 This script interfaces with the PostgreSQL database and then creates summary tables for the Abt project
''', formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument('-tt','--target_table',help='the target table in HDFS to perform an operation on',default='localhost',type=str)
parser.add_argument('-ph','--postgres_host',help='the server hosting the PostgreSQL server',default='localhost',type=str)
parser.add_argument('-pd','--postgres_dbname',help='the database to query in the PostgreSQL server',type=str,required=True)
parser.add_argument('-pp','--postgres_port',help='the port hosting the PostgreSQL service on the server', default='5432',type=int)
parser.add_argument('-U','--postgres_user',help='the PostgreSQL user to log in as',required=True)
parser.add_argument('-W','--postgres_password',help='the password of the PostgreSQL user',required=True)
parser.add_argument('-i','--permutations',help='the number of permutations we wish to execute',type=int)
args = parser.parse_args()
url = 'postgresql://{}:{}/{}'.format(args.postgres_host,args.postgres_port,args.postgres_dbname)
properties = {'user': args.postgres_user, 'password': args.postgres_password}
postgres_conn=psycopg2.connect(dbname=args.postgres_dbname,user=args.postgres_user,password=args.postgres_password, host=args.postgres_host, port=args.postgres_port)

# Read in the target table to the HDFS then perform the initial round of observed frequency calculations
print("*** START -  COLLECTING DATA AND PERFORMING OBSERVED FREQUENCY CALCULATIONS FOR BASE SET ***")
read_postgres_table_into_HDFS(args.target_table,url,properties)
obs_frequency_calculations(args.target_table)
print("*** END -  COLLECTING DATA AND PERFORMING OBSERVED FREQUENCY CALCULATIONS FOR BASE SET ***")


# For the number of desired permutations, generate a random permute structure and collect observed frequency calculations
for i in range(1,args.permutations+1):
    print("*** START -  COLLECTING DATA AND PERFORMING OBSERVED FREQUENCY CALCULATIONS FOR PERMUTATION {} ***".format(i))
    print("*** Performing shuffle in Spark ***".format(i))
    spark_shuffle_data("{}".format(args.target_table)).registerTempTable("{}_shuffled".format(args.target_table))
    SQLContext(spark).cacheTable("{}_shuffled".format(args.target_table))
    print("*** Calculating observed frequencies ***".format(i))
    calculate_journal_pairs_freq("{}_shuffled".format(args.target_table),i)
    print("*** END -  COLLECTING DATA AND PERFORMING OBSERVED FREQUENCY CALCULATIONS FOR PERMUTATION {} ***".format(i))

    # Conditional Statement for iteration number - if 10 or 100 take a pause to calculate z scores for the observations and write to postgres
    if i==10 or i==100:
        print("*** START -  Z-SCORE CALCULATION BREAK FOR PERMUTATION {} ***".format(i))
        z_score_calculations(args.target_table,i)
        print("*** END -  Z-SCORE CALCULATION BREAK FOR PERMUTATION {} ***".format(i))
        print("*** START -  POSTGRES EXPORT FOR PERMUTATION {} ***".format(i))
        #write_table_to_postgres("output_table","spark_results_{}_{}_permutations".format(args.target_table,i),url,properties)
        print("*** END -  POSTGRES EXPORT FOR PERMUTATION {} ***".format(i))

# Analyze the final results stored
print("*** START -  Z-SCORE CALCULATIONS ***")
z_score_calculations(args.target_table,args.permutations)
print("*** END -  Z-SCORE CALCULATIONS ***")
print("*** START -  FINAL POSTGRES EXPORT ***")
#write_table_to_postgres("output_table","spark_results_{}_{}_permutations".format(args.target_table,args.permutations),url,properties)
print("*** END -  FINAL POSTGRES EXPORT ***")
# Close out the spark session
spark.stop()

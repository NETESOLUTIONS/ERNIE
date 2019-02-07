from pyspark import Row
from pyspark.sql import SparkSession
from pyspark.sql.functions import rand
from pyspark.sql.functions import monotonically_increasing_id
import time,sys
import argparse
import pandas as pd

def obs_frequency_calculations(input_dataset):
    obs_df=spark.sql("SELECT source_id,reference_issn FROM {}".format(input_dataset))
    obs_df=obs_df.withColumn('id',monotonically_increasing_id())
    obs_df.createOrReplaceTempView('input_table')
    obs_df=spark.sql('''
            SELECT ref1,ref2,count(*) as obs_frequency
            FROM (
                    SELECT a.reference_issn as ref1, b.reference_issn as ref2
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
            GROUP BY ref1,ref2''')
    obs_df=obs_df.withColumnRenamed('ref1','journal_pair_A').withColumnRenamed('ref2','journal_pair_B')
    spark.catalog.dropTempView('input_table')
    obs_df.write.mode("overwrite").saveAsTable("observed_frequencies")

def calculate_journal_pairs_freq(input_dataset,i):
    df=spark.sql("SELECT source_id,reference_issn FROM {}".format(input_dataset)) #TODO: remember shuffle names, and prepare to cast it
    df=df.withColumn('id',monotonically_increasing_id())
    df.createOrReplaceTempView('bg_table')
    df=spark.sql('''
        SELECT ref1,ref2,count(*) as bg_freq
        FROM (
                SELECT a.reference_issn as ref1, b.reference_issn as ref2
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
        GROUP BY ref1,ref2''')
    df=df.withColumnRenamed('ref1','journal_pair_A').withColumnRenamed('ref2','journal_pair_B')
    df.createOrReplaceTempView('bg_table')
    df=spark.sql('''SELECT a.*,b.bg_freq
                    FROM observed_frequencies a
                    LEFT JOIN bg_table b
                    ON a.journal_pair_A=b.journal_pair_A
                     AND a.journal_pair_B=b.journal_pair_B ''')
    df=df.withColumnRenamed('bg_freq','bg_'+str(i))
    df.write.mode("overwrite").saveAsTable("observed_frequencies")

def final_table(input_dataset,iterations):
    df=spark.sql("SELECT source_id,cited_source_uid,reference_issn FROM {}".format(input_dataset)) #TODO: remember shuffle names, and prepare to cast it
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
            SELECT a.*,b.obs_frequency,b.z_score,b.count,b.mean
            FROM final_table a
            JOIN z_scores_table b
            ON a.journal_pair_A=b.journal_pair_A
             AND a.journal_pair_B=b.journal_pair_B''')
    df.repartition(1).write.csv("spark_results_"+str(iterations),header=True,mode='overwrite')

def z_score_calculations(input_dataset,iterations):
    pandas_df=spark.sql("SELECT * FROM observed_frequencies").toPandas()

    #Calculating the mean
    pandas_df['mean']=pandas_df.iloc[:,3:].mean(axis=1)

    #Calculating the standard deviation
    pandas_df['std']=pandas_df.iloc[:,3:iterations+3].std(axis=1)

    #Calculating z_scores
    pandas_df['z_score']=(pandas_df['obs_frequency']-pandas_df['mean'])/pandas_df['std']

    #Calculating the count
    pandas_df['count']=pandas_df.iloc[:,3:iterations+3].apply(lambda x: x.count(),axis=1)

    pandas_df=pandas_df[['journal_pair_A','journal_pair_B','obs_frequency','mean','z_score','count']].dropna()
    obs_df=spark.createDataFrame(pandas_df)
    obs_df.write.mode("overwrite").saveAsTable("z_scores_table")
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
parser.add_argument('-o','--operation',help='the operation to perform',type=str,required=True)
parser.add_argument('-i','--iteration',help='the permute we are currently on (used for frequency count and background table population)',type=int)
args = parser.parse_args()
target_table = argparse.target_table
operation = argparse.operation
iteration = argparse.iteration

if operation == "START":
    obs_frequency_calculations(target_table)
elif operation == "COUNT":
    calculate_journal_pairs_freq(target_table,iteration)
elif operation == "ANALYZE":
    z_score_calculations(target_table,iteration)

'''
obs_df=obs_frequency_calculations()
obs_df.createOrReplaceTempView('obs_frequency')
calculate_journal_pairs_freq(shuffled_dataset,i)
z_score_calculations(number_of_repetitions)
'''

spark.stop()

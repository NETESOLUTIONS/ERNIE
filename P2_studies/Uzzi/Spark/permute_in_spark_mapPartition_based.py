from pyspark import Row
from pyspark.sql import SparkSession
from pyspark.sql.functions import rand
from pyspark.sql.functions import monotonically_increasing_id
import time,sys
import argparse
import pandas as pd

warehouse_location = '/user/spark/data'

spark = SparkSession.builder.appName("permute_in_spark") \
                    .config("spark.sql.warehouse.dir", warehouse_location) \
                    .enableHiveSupport() \
                    .getOrCreate()
spark.conf.set("spark.sql.autoBroadcastJoinThreshold", -1)

# Read the input dataset into a variable
input_dataset = spark.sql("SELECT * FROM dataset1995 LIMIT 10000")
input_dataset.show()

def shuffle_generator(ref_year_group):
    group = []
    group_size = 0
    for row in ref_year_group:
        group.append(row)
        group_size += 1
    if group_size > 0:  # ready to process
        for i, row in enumerate(group):
            shuffle_index = i + 1 if i < group_size - 1 else 0
            yield Row(source_id=row.source_id,
                      source_year=row.source_year,
                      source_document_id_type=row.source_document_id_type,
                      source_issn=row.source_issn,
                      cited_source_uid=group[shuffle_index].cited_source_uid,
                      reference_year=group[shuffle_index].reference_year,
                      reference_document_id_type=group[shuffle_index].reference_document_id_type,
                      reference_issn=group[shuffle_index].reference_issn)

shuffled_rows = input_dataset \
	    .repartition("reference_year") \
	    .withColumn("rand", rand()) \
	    .sortWithinPartitions("rand") \
	    .rdd \
	    .mapPartitions(shuffle_generator) \
	    .distinct() \
	    .collect()

shuffled_dataset = spark.createDataFrame(shuffled_rows)
shuffled_dataset.show()

spark.stop()

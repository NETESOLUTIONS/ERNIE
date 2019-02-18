from pyspark import Row
from pyspark.sql import SparkSession
from pyspark.sql.functions import rand
from pyspark.sql.functions import monotonically_increasing_id
import time,sys
import argparse
import pandas as pd
import numpy as np
from pyspark.sql.functions import col, udf, lit,struct
import pyspark.sql.types as sql_type

warehouse_location = '/user/spark/data'
spark = SparkSession.builder.appName("testing") \
                    .config("spark.sql.warehouse.dir", warehouse_location) \
                    .enableHiveSupport() \
                    .getOrCreate()
spark.conf.set("spark.sql.autoBroadcastJoinThreshold", -1)
def pandas_mean(number_list):
    return pd.DataFrame(pd.to_numeric(number_list, errors='coerce')).mean()
def pandas_std(number_list):
    return pd.DataFrame(pd.to_numeric(number_list, errors='coerce')).std()
def pandas_sum(number_list):
    return pd.DataFrame(pd.to_numeric(number_list, errors='coerce')).sum()

mean_udf=udf(lambda row: float(pandas_mean(row)), sql_type.DoubleType())
std_udf=udf(lambda row: float(pandas_std(row)), sql_type.DoubleType())
sum_udf=udf(lambda row: float(pandas_sum(row)), sql_type.DoubleType())

#target columns
a = spark.table("observed_frequencies")
b=a.withColumn('mean', mean_udf(struct( [a[col] for col in a.columns[3:]] )))
b.show()

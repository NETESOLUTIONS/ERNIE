import os

from pyspark import Row
from pyspark.sql import SparkSession
from pyspark.sql.functions import rand

os.environ["PYSPARK_PYTHON"] = "/usr/local/opt/anaconda3/bin/python"
os.environ["PYSPARK_DRIVER_PYTHON"] = os.environ["PYSPARK_PYTHON"]

DATA_FILE = "dataset_test.csv"
spark = SparkSession.builder.appName("permute_in_spark").getOrCreate()
# spark.sparkContext.setLogLevel("INFO")
input_dataset = spark.read.format("csv").option("header", "true").load(DATA_FILE)
print("Input:")
input_dataset.show()


def shuffle(ref_year_group):
    global row_list
    group = []
    size = 0
    for row in ref_year_group:
        group.append(row)
        size += 1
    if size > 0:  # ready to process
        for i, row in enumerate(group):
            result_row = Row(source_id=row.source_id,
                             source_year=row.source_year,
                             source_document_id_type=row.source_document_id_type,
                             source_issn=row.source_issn,
                             cited_source_uid=group[size - 1 - i].cited_source_uid,
                             reference_year=group[size - 1 - i].reference_year,
                             reference_document_id_type=group[size - 1 - i].reference_document_id_type,
                             reference_issn=group[size - 1 - i].reference_issn)
            spark.createDataFrame(result_row, input_dataset.schema) \
                .write.mode('append') \
                .parquet('dataset_test.parquet')


input_dataset.repartition("reference_year") \
    .withColumn("rand", rand()) \
    .sortWithinPartitions("rand") \
    .foreachPartition(shuffle)

spark.stop()

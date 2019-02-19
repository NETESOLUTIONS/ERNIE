import os
import argparse
from pyspark import Row
from pyspark.sql import SparkSession
from pyspark.sql.functions import rand
#os.environ["PYSPARK_PYTHON"] = "/usr/local/opt/anaconda3/bin/python"
#os.environ["PYSPARK_DRIVER_PYTHON"] = os.environ["PYSPARK_PYTHON"]

parser = argparse.ArgumentParser(description='''
 This script is used to run a Spark job
''', formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument('-f','--input_file',help='the input file for the Spark job',type=str, required=True)
args = parser.parse_args()

DATA_FILE = args.input_file
spark = SparkSession.builder.appName("permute_in_spark").getOrCreate()
# spark.sparkContext.setLogLevel("INFO")
input_dataset = spark.read.format("csv").option("header", "true").load(DATA_FILE)
print("Input:")
input_dataset.show()


def shuffle(ref_year_group):
    group = []
    size = 0
    for row in ref_year_group:
        group.append(row)
        size += 1
    if size > 0:  # ready to process
        for i, row in enumerate(group):
            yield Row(source_id=row.source_id,
                             source_year=row.source_year,
                             source_document_id_type=row.source_document_id_type,
                             source_issn=row.source_issn,
                             cited_source_uid=group[size - 1 - i].cited_source_uid,
                             reference_year=group[size - 1 - i].reference_year,
                             reference_document_id_type=group[size - 1 - i].reference_document_id_type,
                             reference_issn=group[size - 1 - i].reference_issn)

output_dataset = input_dataset \
    .repartition("reference_year") \
    .withColumn("rand", rand()) \
    .sortWithinPartitions("rand") \
    .rdd.mapPartitions(shuffle).collect()
final_dataset = spark.createDataFrame(output_dataset)
final_dataset.show()
final_dataset.coalesce(1).write.option("header", "true").csv("/tmp/shuffled_output.csv", mode='overwrite')

spark.stop()

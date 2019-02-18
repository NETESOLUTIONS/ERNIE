from pyspark import Row
from pyspark.sql import SparkSession
from pyspark.sql.functions import rand

# os.environ["PYSPARK_PYTHON"] = "/usr/local/opt/anaconda3/bin/python"
# os.environ["PYSPARK_DRIVER_PYTHON"] = os.environ["PYSPARK_PYTHON"]

DATA_FILE = "test_data/dataset_test.csv"
spark = SparkSession.builder.appName("permute_in_spark").getOrCreate()
# spark.sparkContext.setLogLevel("INFO")
input_dataset = spark.read.format("csv").option("header", "true").load(DATA_FILE)
print("Input:")
input_dataset.show()


# region Solution using RDD.aggregate.mapPartitions()
# def shuffle_generator(ref_year_group):
#     group = []
#     group_size = 0
#     for row in ref_year_group:
#         group.append(row)
#         group_size += 1
#     if group_size > 0:  # ready to process
#         for i, row in enumerate(group):
#             shuffle_index = i + 1 if i < group_size - 1 else 0
#             yield Row(source_id=row.source_id,
#                       source_year=row.source_year,
#                       source_document_id_type=row.source_document_id_type,
#                       source_issn=row.source_issn,
#                       cited_source_uid=group[shuffle_index].cited_source_uid,
#                       reference_year=group[shuffle_index].reference_year,
#                       reference_document_id_type=group[shuffle_index].reference_document_id_type,
#                       reference_issn=group[shuffle_index].reference_issn)
#
#
# shuffled_rows = input_dataset \
#     .repartition("reference_year") \
#     .withColumn("rand", rand()) \
#     .sortWithinPartitions("rand") \
#     .rdd \
#     .mapPartitions(shuffle_generator) \
#     .distinct() \
#     .collect()
# endregion


# region Solution using RDD.aggregate
def shuffle(ref_year_group):
    result = set()
    group_size = len(ref_year_group)
    for i, row in enumerate(ref_year_group):
        shuffle_index = i + 1 if i < group_size - 1 else 0
        result.add(Row(source_id=row.source_id,
                       source_year=row.source_year,
                       source_document_id_type=row.source_document_id_type,
                       source_issn=row.source_issn,
                       cited_source_uid=ref_year_group[shuffle_index].cited_source_uid,
                       reference_year=ref_year_group[shuffle_index].reference_year,
                       reference_document_id_type=ref_year_group[shuffle_index].reference_document_id_type,
                       reference_issn=ref_year_group[shuffle_index].reference_issn))
    return list(result)


def accumulate(local_result, row):
    return local_result + [row]


def shuffle_and_combine(local_result_1, local_result_2):
    return shuffle(local_result_1) + shuffle(local_result_2)


shuffled_rows = input_dataset.repartition("reference_year") \
    .withColumn("rand", rand()) \
    .sortWithinPartitions("rand") \
    .rdd \
    .aggregate([], accumulate, shuffle_and_combine)
# endregion

shuffled_dataset = spark.createDataFrame(shuffled_rows)
shuffled_dataset.show()

spark.stop()

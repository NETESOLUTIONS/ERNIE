from pyspark.sql import SparkSession
DATA_FILE = "dataset_test.csv"
spark = SparkSession.builder.appName("Permute").getOrCreate()
# spark.sparkContext.setLogLevel("INFO")
df = spark.read.format("csv").option("header", "true").load(DATA_FILE).cache()

# numAs = df.filter(df.source_id.contains('A')).count()
# numBs = df.filter(df.source_id.contains('B')).count()

ref_years = df.groupBy("reference_year").count()
print("\nReference year stats:")
ref_years.show()

spark.stop()
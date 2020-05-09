library(sparklyr)
Sys.setenv(JAVA_HOME = "/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home")
sc <- spark_connect(master = "local",version="2.3")
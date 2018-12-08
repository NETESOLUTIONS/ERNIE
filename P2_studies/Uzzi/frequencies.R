# script to calculate probs for references
system.time({

	rm(list = ls())
	library(data.table)
	# read in data
	t <- fread('dataset1980_dec2018.csv')
	# subset to columns of interest
	t1 <- t[, .(cited_source_uid, reference_year)]
	# commented out because setkey interferes with unique
	# setkey(t1, cited_source_uid)
	# calculate frequencies of individual references
	t1[, `:=`(f, .N), by = c('cited_source_uid')]
	# suppress duplicate rows to avoid inflating counts by reference year
	t1 <- unique(t1)
	# calculate frequency of all references in a year
	t1[, `:=`(F, sum(f)), by = 'reference_year']
	# calculate probs for references
	t1[, `:=`(p, f/F)]
	t1 <- unique(t1)
})


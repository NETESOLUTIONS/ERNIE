#!/bin/bash

# pre-process by casting scps as character prefixed by 'a' to avoid
# unfortunate bigint events and export as tsv without colnames and rownames
Rscript pre_process.R --args $1
# generate MCL output
source ./mcl_script.sh
# postprocess mcloutput as csv
Rscript post_process.R



#!/bin/bash

# pre-process by casting scps as character prefixed by 'a' to avoid
# unfortunate bigint events and export as tsv without colnames and rownames
Rscript ~/ERNIE/P2_studies/theta_plus/pre_process.R --args $1
# generate MCL output
source ~/ERNIE/P2_studies/theta_plus/mcl_script.sh
sleep 10m
# postprocess mcloutput as csv
Rscript ~/ERNIE/P2_studies/theta_plus/post_process.R




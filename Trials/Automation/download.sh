#!/usr/bin/env bash
# download: directly from website
wget -r 'https://clinicaltrials.gov/ct2/results/download?term=&down_fmt=xml&down_typ=results&down_stds=all' \
     -O ./nct_files/CT_all.zip
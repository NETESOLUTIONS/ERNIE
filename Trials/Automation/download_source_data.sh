#!/usr/bin/env bash
set -xe

# download: directly from clinicaltrials.gov website
wget --no-verbose 'https://clinicaltrials.gov/ct2/results/download?term=&down_fmt=xml&down_typ=results&down_stds=all' \
     --output-document=CT_all.zip
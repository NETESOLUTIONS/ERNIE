#!/usr/bin/env bash
# Author: Samet Keserci,
# Updates all WoS tables except wos_references
# Created: 08/18/2017
# Modified:
# * 01/27/2018, Dmitriy "DK" Korobskiy, minor

set -xe
set -o pipefail

# Get a script directory, same as by $(dirname $0)
script_dir=${0%/*}
absolute_script_dir=$(cd "${script_dir}" && pwd)

non_ref_1_update_start=`date +%s`
echo "abstracts,addresses,authors and document_identifiers PARALLEL UPDATE started"
psql -f "${absolute_script_dir}/wos_update_abstracts.sql" &
psql -f "${absolute_script_dir}/wos_update_addresses.sql" &
psql -f "${absolute_script_dir}/wos_update_authors.sql" &
psql -f "${absolute_script_dir}/wos_update_doc_iden.sql" &

wait

non_ref_2_update_start=`date +%s`
echo $((non_ref_2_update_start-non_ref_1_update_start)) |  awk '{print int($1/3600) " hour : " int(($1/60)%60) " min : " int($1%60) " sec ::  abstracts,addresses,authors,document_identifiers update duration" }'

echo "grants, keyywords, publication and titles: PARALLEL UPDATE started "

psql -f "${absolute_script_dir}/wos_update_grants.sql" &
psql -f "${absolute_script_dir}/wos_update_keywords.sql" &
psql -f "${absolute_script_dir}/wos_update_publications.sql" &
psql -f "${absolute_script_dir}/wos_update_titles.sql" &

wait

non_ref_2_update_end=`date +%s`
echo $((non_ref_2_update_end-non_ref_2_update_start)) |  awk '{print int($1/3600) " hour : " int(($1/60)%60) " min : " int($1%60) " sec ::  grants, keyywords, publication, titles update duration" }'

echo "Post-Process - cleaning started"
psql -f "${absolute_script_dir}/wos_parallel_update_postprocess.sql"

non_ref_update_end=`date +%s`

echo $((non_ref_update_end-non_ref_1_update_start)) |  awk '{print int($1/3600) " hour : " int(($1/60)%60) " min : " int($1%60) " sec ::  Single CORE File wos_except_ref update processing duration" }'

wait
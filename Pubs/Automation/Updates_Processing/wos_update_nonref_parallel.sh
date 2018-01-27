

# Author: Samet Keserci,
# Create Date: 08/18/2017
# Updates all table except wos_references.

  non_ref_1_update_start=`date +%s`
  echo "abstracts,addresses,authors and document_identifiers PARALLEL UPDATE started (UTC): " >> time_keeper.txt
  date >> time_keeper.txt
  psql -d ernie -f wos_update_abstracts.sql &
  psql -d ernie -f wos_update_addresses.sql &
  psql -d ernie -f wos_update_authors.sql &
  psql -d ernie -f wos_update_doc_iden.sql &

  wait
  non_ref_2_update_start=`date +%s`
  echo $((non_ref_2_update_start-non_ref_1_update_start)) |  awk '{print int($1/3600) " hour : " int(($1/60)%60) " min : " int($1%60) " sec ::  abstracts,addresses,authors,document_identifiers update duration UTC" }' >> time_keeper.txt
  echo "grants, keyywords, publication and titles  PARALLEL UPDATE started (UTC): " >> time_keeper.txt
  date >> time_keeper.txt

  psql -d ernie -f wos_update_grants.sql &
  psql -d ernie -f wos_update_keywords.sql &
  psql -d ernie -f wos_update_publications.sql &
  psql -d ernie -f wos_update_titles.sql &

  wait
  non_ref_2_update_end=`date +%s`
  echo $((non_ref_2_update_end-non_ref_2_update_start)) |  awk '{print int($1/3600) " hour : " int(($1/60)%60) " min : " int($1%60) " sec ::  grants, keyywords, publication, titles update duration UTC " }' >> time_keeper.txt


  echo "Post-Process - cleaning started (UTC): " >> time_keeper.txt
  date >> time_keeper.txt

  psql -d ernie -f wos_parallel_update_postprocess.sql

  non_ref_update_end=`date +%s`

  echo $((non_ref_update_end-non_ref_1_update_start)) |  awk '{print int($1/3600) " hour : " int(($1/60)%60) " min : " int($1%60) " sec ::  Single CORE File wos_except_ref update processing duration UTC " }' >> time_keeper.txt

  wait

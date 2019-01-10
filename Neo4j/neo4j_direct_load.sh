#!/usr/bin/env bash
if [[ $1 == "-h" ]]; then
  cat <<'HEREDOC'
NAME
  neo4j_shuffle_edges.sh -- shuffle edges randomly while preserving node degrees

SYNOPSIS
  neo4j_shuffle_edges.sh

DESCRIPTION

    Clean the current Neo4j DB and load data directly over JDBC.

    Requires APOC Neo4j plug-in.

ENVIRONMENT

    ERNIE_ADMIN_POSTGRES `ernie_admin` password in the Dev/Prod DB
HEREDOC
  exit 1
fi

set -xe
set -o pipefail

# Get a script directory, same as by $(dirname $0)
script_dir=${0%/*}
absolute_script_dir=$(cd "${script_dir}" && pwd)
#work_dir=${1:-${absolute_script_dir}/build} # $1 with the default
#if [[ ! -d "${work_dir}" ]]; then
#  mkdir "${work_dir}"
#  chmod g+w "${work_dir}"
#fi
#cd "${work_dir}"
echo -e "\n## Running under ${USER}@${HOSTNAME} at ${PWD} ##\n"

if [[ ! ${ERNIE_ADMIN_POSTGRES} ]]; then
  echo "ERROR: ERNIE_ADMIN_POSTGRES environment variable is not defined"
  exit 1
fi

if ! which cypher-shell >/dev/null; then
  echo "ERROR: Neo4j is not installed"
  exit 1
fi

echo "Loading ..."
# language=Cypher
cypher-shell --format verbose <<HEREDOC
// Clean DB
MATCH (n)
DETACH DELETE n;

WITH 'jdbc:postgresql://ernie1/ernie?user=ernie_admin&password=${ERNIE_ADMIN_POSTGRES}' AS db,
     '-- Limited deterministic sample of publication references
     SELECT
       d.source_id,
       source_wp.document_title,
       d.source_year,
       d.source_document_id_type,
       d.source_issn,
       d.cited_source_uid,
       reference_wp.document_title AS reference_title,
       d.reference_year,
       d.reference_document_id_type,
       d.reference_issn
     FROM dataset1980 d
     JOIN wos_publications source_wp ON source_wp.source_id = d.source_id
     JOIN wos_publications reference_wp ON reference_wp.source_id = d.cited_source_uid
     ORDER BY d.source_id DESC
     LIMIT 100' AS sql
CALL apoc.load.jdbc(db, sql) YIELD row
MERGE (p:Publication {source_id: row.source_id, title: row.document_title, year: row.source_year,
                      issn_type: row.source_document_id_type, issn: row.source_issn})
MERGE (r:Publication {source_id: row.cited_source_uid, title: row.reference_title, year: row.reference_year,
                      issn_type: row.reference_document_id_type, issn: row.reference_issn})
MERGE (p)-[:CITES]->(r);
HEREDOC
echo "Loaded."

#echo "Calculating metrics and indexing ..."
#cypher-shell <<'HEREDOC'
#// Indexes will be created even if there are no nodes with indexed properties
#CREATE INDEX ON :Publication(endpoint);
#CREATE INDEX ON :Publication(nida_support);
#CREATE INDEX ON :Publication(other_hhs_support);
#
#// Calculate and store PageRank
#CALL algo.pageRank()
#YIELD nodes, iterations, loadMillis, computeMillis, writeMillis, dampingFactor, write, writeProperty;
#
#// Calculate and store Betweenness Centrality
#CALL algo.betweenness(null, null, {writeProperty: 'betweenness'})
#YIELD nodes, minCentrality, maxCentrality, sumCentrality, loadMillis, computeMillis, writeMillis;
#
#// Calculate and store Closeness Centrality
#CALL algo.closeness(null, null, {writeProperty: 'closeness'})
#YIELD nodes, loadMillis, computeMillis, writeMillis;
#
#// PageRank statistics
#MATCH (n)
#RETURN apoc.agg.statistics(n.pagerank);
#HEREDOC

# TODO Parallelize
#parallel --halt soon,fail=1 --verbose --line-buffer --pipe cypher-shell ::: "// Calculate and store PageRank
#  CALL algo.pageRank()
#  YIELD nodes, iterations, loadMillis, computeMillis, writeMillis, dampingFactor, write, writeProperty;" \
#  "// Calculate and store Betweenness Centrality
#  CALL algo.betweenness(null, null, {writeProperty: 'betweenness'})
#  YIELD nodes, minCentrality, maxCentrality, sumCentrality, loadMillis, computeMillis, writeMillis;" \
#  "// Calculate and store Closeness Centrality
#  CALL algo.closeness(null, null, {writeProperty: 'closeness'})
#  YIELD nodes, loadMillis, computeMillis, writeMillis;" \
#  "CREATE INDEX ON :Publication(endpoint);" \
#  "CREATE INDEX ON :Publication(nida_support);" \
#  "CREATE INDEX ON :Publication(other_hhs_support);"
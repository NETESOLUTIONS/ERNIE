#!/usr/bin/env bash
if [[ $1 == "-h" ]]; then
  cat <<'HEREDOC'
NAME
  neo4j_direct_load.sh -- load data from an RDBMS to Neo4j directly

SYNOPSIS
  neo4j_direct_load.sh

DESCRIPTION

    Clean the current Neo4j DB and load data directly over JDBC.

    Requires APOC Neo4j plug-in.

ENVIRONMENT

    ERNIE_ADMIN_POSTGRES `ernie_admin` password in the Dev/Prod DB
HEREDOC
  exit 1
fi

set -e
set -o pipefail

# Get a script directory, same as by $(dirname $0)
#script_dir=${0%/*}
#absolute_script_dir=$(cd "${script_dir}" && pwd)
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

if ! command -v cypher-shell >/dev/null; then
  echo "ERROR: Neo4j is not installed"
  exit 1
fi

echo "Cleaning"
# language=Cypher
cypher-shell --format verbose <<HEREDOC
DROP INDEX ON :Publication(source_id);

MATCH (n)
DETACH DELETE n;
HEREDOC

echo "Loading nodes"
# language=Cypher
cypher-shell --format verbose <<HEREDOC
WITH 'jdbc:postgresql://ernie2/ernie?user=ernie_admin&password=${ERNIE_ADMIN_POSTGRES}' AS db,
     '
SELECT source_id, cluster_20 AS cluster_no, pub_year, citation_count
FROM dblp_graclus
WHERE publication = TRUE
  AND citation_count IS NOT NULL
  AND pub_year IS NOT NULL' AS sql
CALL apoc.load.jdbc(db, sql) YIELD row
CREATE (p:Publication {source_id: row.source_id, cluster_no: row.cluster_no, year: row.pub_year,
                      citation_count: row.citation_count});
HEREDOC

echo "Indexing"
# language=Cypher
cypher-shell --format verbose <<HEREDOC
CREATE INDEX ON :Publication(source_id);
HEREDOC

echo "Loading edges"
# language=Cypher
cypher-shell --format verbose <<HEREDOC
WITH 'jdbc:postgresql://ernie1/ernie?user=ernie_admin&password=${ERNIE_ADMIN_POSTGRES}' AS db,
     '
SELECT source_id, cited_source_uid
FROM dblp_dataset
WHERE cited_source_uid IN (
    SELECT source_id
    FROM dblp_graclus
    WHERE publication = TRUE
      AND citation_count IS NOT NULL
      AND pub_year IS NOT NULL
)' AS sql
CALL apoc.load.jdbc(db, sql) YIELD row
MATCH (p:Publication {source_id: row.source_id}), (r:Publication {source_id: row.cited_source_uid})
MERGE (p)-[:CITES]->(r);
HEREDOC

echo "Calculating metrics"
cypher-shell <<'HEREDOC'
// Calculate and store PageRank
CALL algo.pageRank()
YIELD nodes, iterations, loadMillis, computeMillis, writeMillis, dampingFactor, write, writeProperty;

// Calculate and store Betweenness Centrality
CALL algo.betweenness(null, null, {writeProperty: 'betweenness'})
YIELD nodes, minCentrality, maxCentrality, sumCentrality, loadMillis, computeMillis, writeMillis;

// Calculate and store Closeness Centrality
CALL algo.closeness(null, null, {writeProperty: 'closeness'})
YIELD nodes, loadMillis, computeMillis, writeMillis;

// PageRank statistics
MATCH (n)
RETURN apoc.agg.statistics(n.pagerank);
HEREDOC
echo "Done"

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
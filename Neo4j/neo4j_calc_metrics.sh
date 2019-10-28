#!/usr/bin/env bash
if [[ $1 == "-h" || $# -lt 3 ]]; then
  cat <<'HEREDOC'
NAME

  neo4j_bulk_import.sh -- loads CSVs in bulk to Neo4j and optionally calculate metrics

SYNOPSIS

  neo4j_bulk_import.sh [-m] nodes_file edges_file current_user_password [DB_name_prefix]
  neo4j_bulk_import.sh -h: display this help

DESCRIPTION
  Bulk imports to a new `{DB_name_prefix-}v{file_timestamp}` DB.
  Spaces are replaced by underscores in the `DB_name_prefix`.
  Updates Neo4j config file and restarts Neo4j.

  The following options are available:

  -m  Calculate metrics: PageRank, Betweenness Centrality, Closeness Centrality

ENVIRONMENT

  Current user must be a sudoer.

HEREDOC
  exit 1
fi

set -e
set -o pipefail

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

#TBD Running into `Failed to invoke procedure `algo.pageRank`: Caused by: java.lang.NullPointerException`
#parallel --null --halt soon,fail=1 --line-buffer --tagstring '|job#{#} s#{%}|' 'echo {} | cypher-shell' ::: \
#  "// Calculate and store PageRank
#  CALL algo.pageRank()
#  YIELD nodes, iterations, loadMillis, computeMillis, writeMillis, dampingFactor, write, writeProperty;" \
#  "// Calculate and store Betweenness Centrality
#  CALL algo.betweenness(null, null, {writeProperty: 'betweenness'})
#  YIELD nodes, minCentrality, maxCentrality, sumCentrality, loadMillis, computeMillis, writeMillis;" \
#  "// Calculate and store Closeness Centrality
#  CALL algo.closeness(null, null, {writeProperty: 'closeness'})
#  YIELD nodes, loadMillis, computeMillis, writeMillis;" \
#  "CREATE INDEX ON :Publication(node_id);"
#
#cypher-shell <<'HEREDOC'
#// PageRank statistics
#MATCH (n)
#RETURN apoc.agg.statistics(n.pagerank);
#HEREDOC
#!/usr/bin/env bash
if [[ $1 == "-h" || $# -lt 3 ]]; then
  cat <<'HEREDOC'
NAME
  neo4j_load.sh -- loads CSV in bulk to Neo4j and calculate metrics

SYNOPSIS
  neo4j_load.sh nodes_file edges_file ernie_admin_password
  neo4j_load.sh -h: display this help

DESCRIPTION
  # Generates a new DB name
  # Bulk imports to a new DB
  # Updates Neo4j config file
  # Restarts Neo4j
  # Calculates metrics via cypher-shell
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

if ! which cypher-shell >/dev/null; then
  echo "Please install Neo4j"
  exit 1
fi

nodes_file="$1"
edges_file="$2"

# region Generate a unique db_name
name_with_ext=${nodes_file##*/}
if [[ "${name_with_ext}" != *.* ]]; then
  name_with_ext=${name_with_ext}.
fi

name=${name_with_ext%.*}
file_date1=$(date -r "${nodes_file}" +%F-%H-%M-%S)
file_date2=$(date -r "${edges_file}" +%F-%H-%M-%S)
if [[ ${file_date1} > ${file_date2} ]]; then
  db_ver="${file_date1}"
else
  db_ver="${file_date2}"
fi
db_name="${name%%_*}-v${db_ver}.db"
# endregion

# region Hide password from the output and decrease verbosity
set +x
# The current directory must be writeable for the neo4j user. Otherwise, it'd fail with the
# `java.io.FileNotFoundException: import.report (Permission denied)` error
echo "$3" | sudo --stdin -u neo4j bash -c "set -xe
  echo 'Loading data into ${db_name} ...'
  neo4j-admin import --nodes:Publication '${nodes_file}' --relationships:CITES '${edges_file}' --database='${db_name}'"

${absolute_script_dir}/neo4j_switch_db.sh "${db_name}" "$3"
set -x
# endregion

echo "Calculating metrics and indexing ..."
cypher-shell <<'HEREDOC'
// Indexes will be created even if there are no nodes with indexed properties
CREATE INDEX ON :Publication(endpoint);
CREATE INDEX ON :Publication(nida_support);
CREATE INDEX ON :Publication(other_hhs_support);

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
#!/usr/bin/env bash
if [[ $# -lt 2 || "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    calc-jaccard-co-citation-star-index.sh -- calculate Jaccard Co-Citation* Conditional Index in Neo4j.

SYNOPSIS

    calc-jaccard-co-citation-star-index.sh JDBC_conn_string co_cited_pairs_query
    calc-jaccard-co-citation-star-index.sh -h: display this help

DESCRIPTION

    Calculate Jaccard Co-Citation* Conditional Index for selected co-cited pairs retrieved directly from a RDBMS.
    Output CSV to stdout.

    The following options are available:

    JDBC_conn_string      JDBC connection string
    co_cited_pairs_query  SQL to execute. SQL should return (cited_1, cited_2) integer ids.

ENVIRONMENT

    Neo4j DB should be pre-loaded with data and indexed as needed.

EXAMPLES

    To find all occurrences of the word `patricia' in a file:

        $ calc-jaccard-co-citation-star-index.sh \
            "jdbc:postgresql://ernie2/ernie?user=ernie_admin&password=${ERNIE_ADMIN_POSTGRES}" \
            'SELECT 17538003 AS cited_1, 18983824 AS cited_2'

AUTHOR(S)

    Written by Dmitriy "DK" Korobskiy.
HEREDOC
  exit 1
fi

set -e
set -o pipefail

readonly JDBC_CONN_STRING="$1"
readonly CO_CITED_PAIRS_QUERY="$2"

# Get a script directory, same as by $(dirname $0)
#readonly SCRIPT_DIR=${0%/*}
#readonly ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)
#
#readonly WORK_DIR=${1:-${ABSOLUTE_SCRIPT_DIR}/build} # $1 with the default
#if [[ ! -d "${WORK_DIR}" ]]; then
#  mkdir "${WORK_DIR}"
#  chmod g+w "${WORK_DIR}"
#fi
#cd "${WORK_DIR}"
#echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##\n"

# Jaccard Co-Citation* Conditional Index: |N(xy) = Co-citing set|/|NxUNy = N*(x) union with N*(y)| in parallel
cypher-shell --format plain <<HEREDOC
WITH '$JDBC_CONN_STRING' AS db, '${CO_CITED_PAIRS_QUERY}' AS sql
CALL apoc.load.jdbc(db, sql) YIELD row
WITH collect({x_scp: row.cited_1, y_scp: row.cited_2}) AS pairs
CALL apoc.cypher.mapParallel2('
  MATCH (x:Publication {node_id: _.x_scp})<--(Nxy)-->(y:Publication {node_id: _.y_scp})
  WITH count(Nxy) AS intersect_size, min(Nxy.pub_year) AS first_co_citation_year, _.x_scp AS x_scp, _.y_scp AS y_scp
  OPTIONAL MATCH (x:Publication {node_id: x_scp})<--(Nx:Publication)
    WHERE Nx.node_id <> y_scp AND Nx.pub_year <= first_co_citation_year
  WITH collect(Nx) AS nx_list, intersect_size, first_co_citation_year, x_scp, y_scp
  OPTIONAL MATCH (y:Publication {node_id: y_scp})<--(Ny:Publication)
    WHERE Ny.node_id <> x_scp AND Ny.pub_year <= first_co_citation_year
  WITH nx_list + collect(Ny) AS union_list, intersect_size, x_scp, y_scp
  UNWIND union_list AS union_node
  RETURN x_scp, y_scp, toFloat(intersect_size) / (count(DISTINCT union_node) + 2) AS jaccard_index', {}, pairs, 16)
YIELD value
RETURN value.x_scp AS cited_1, value.y_scp AS cited_2, value.jaccard_index AS jaccard_co_citation_conditional_index
HEREDOC
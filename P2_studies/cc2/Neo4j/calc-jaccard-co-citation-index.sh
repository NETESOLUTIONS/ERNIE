#!/usr/bin/env bash
if [[ $# -lt 3 || "$1" == "-h" ]]; then
  cat << 'HEREDOC'
NAME

    calc-jaccard-co-citation-index.sh -- calculate Jaccard Co-Citation* Index in Neo4j for selected co-cited pairs.

SYNOPSIS

    calc-jaccard-co-citation-index.sh JDBC_conn_string co_cited_pairs_query output_file [min_rec_number]
    calc-jaccard-co-citation-index.sh -h: display this help

DESCRIPTION

    Calculate Jaccard Co-Citation* Index for selected co-cited pairs retrieved directly from a RDBMS.
    Output CSV to stdout.

    The following options are available:

    JDBC_conn_string      JDBC connection string
    co_cited_pairs_query  SQL to execute. SQL should return (cited_1, cited_2) integer ids.
    output_file           use `/dev/stdout` for `stdout`. Note: the number of records is printed to stdout.
    min_rec_number        If supplied, the number of output records is checked to be >= minimum

ENVIRONMENT

    Neo4j DB should be pre-loaded with data and indexed as needed.

EXIT STATUS

    The calc-jaccard-co-citation-index.sh utility exits with one of the following values:

    0   Success
    1   Exported less than the minimum number of records

EXAMPLES

    To find all occurrences of the word `patricia' in a file:

        $ calc-jaccard-co-citation-index.sh \
            "jdbc:postgresql://ernie2/ernie?user=ernie_admin&password=${ERNIE_ADMIN_POSTGRES}" \
            'SELECT 17538003 AS cited_1, 18983824 AS cited_2' index.csv

AUTHOR(S)

    Written by Dmitriy "DK" Korobskiy.
HEREDOC
  exit 1
fi

set -e
set -o pipefail

readonly JDBC_CONN_STRING="$1"
readonly CO_CITED_PAIRS_QUERY="$2"
readonly OUTPUT="$3"
if [[ $4 ]]; then
  declare -ri MIN_NUM_RECORDS=$4
fi

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

{
cypher-shell --format plain << HEREDOC
// Jaccard Co-Citation* Index: |N(xy) = Co-citing set|/|NxUNy = N*(x) union with N*(y)| in parallel
// 5 pairs: 4.4s-16.0s
WITH '$JDBC_CONN_STRING' AS db, '${CO_CITED_PAIRS_QUERY}' AS sql
CALL apoc.load.jdbc(db, sql) YIELD row
WITH collect({x_scp: row.cited_1, y_scp: row.cited_2}) AS pairs
CALL apoc.cypher.mapParallel2('
  MATCH (x:Publication {node_id: _.x_scp})<--(Nxy)-->(y:Publication {node_id: _.y_scp})
  WITH count(Nxy) AS intersect_size, _.x_scp AS x_scp, _.y_scp AS y_scp
  MATCH (x:Publication {node_id: x_scp})<--(Nx:Publication)
    WHERE Nx.node_id <> y_scp
  WITH collect(Nx) AS nx_list, intersect_size, x_scp, y_scp
  MATCH (y:Publication {node_id: y_scp})<--(Ny:Publication)
    WHERE Ny.node_id <> x_scp
  WITH nx_list + collect(Ny) AS union_list, intersect_size, x_scp, y_scp
  UNWIND union_list AS union_node
  RETURN x_scp AS cited_1, y_scp AS cited_2,
         toFloat(intersect_size) / (count(DISTINCT union_node) + 2) AS jaccard_co_citation_star_index', {}, pairs, 8)
YIELD value
RETURN value.cited_1 AS cited_1, value.cited_2 AS cited_2,
       value.jaccard_co_citation_star_index AS jaccard_co_citation_star_index;
HEREDOC
} | tee >(wc -l >num_of_lines.txt) >"$OUTPUT"

# shellcheck disable=SC2155 # suppressing an exit code here
declare -i num_of_records=$(cat num_of_lines.txt)
(( num_of_records=num_of_records-1 )) || :
echo "Exported $num_of_records records to $OUTPUT"

if (( num_of_records < MIN_NUM_RECORDS )); then
  # False if MIN_NUM_RECORDS is not defined
  echo "Error! It's less than the minimum number of records ($MIN_NUM_RECORDS)." 1>&2
  exit 1
fi

#cypher-shell --format plain <<HEREDOC
#WITH '$JDBC_CONN_STRING' AS db, '${CO_CITED_PAIRS_QUERY}' AS sql
#CALL apoc.load.jdbc(db, sql) YIELD row
#MATCH (x:Publication {node_id: row.cited_1})<--(Nxy)-->(y:Publication {node_id: row.cited_2})
#WITH count(Nxy) AS intersect_size, row.cited_1 AS x_scp, row.cited_2 AS y_scp
#MATCH (x:Publication {node_id: x_scp})<--(Nx:Publication)
#  WHERE Nx.node_id <> y_scp
#WITH collect(Nx) AS nx_list, intersect_size, x_scp, y_scp
#MATCH (y:Publication {node_id: y_scp})<--(Ny:Publication)
#  WHERE Ny.node_id <> x_scp
#WITH nx_list + collect(Ny) AS union_list, intersect_size, x_scp, y_scp
#UNWIND union_list AS union_node
#RETURN x_scp AS cited_1, y_scp AS cited_2,
#       toFloat(intersect_size) / (count(DISTINCT union_node) + 2) AS jaccard_co_citation_star_index;
#HEREDOC

exit 0

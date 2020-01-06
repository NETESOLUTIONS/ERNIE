#!/usr/bin/env bash
if [[ $# -lt 4 || "$1" == "-h" ]]; then
  cat << 'HEREDOC'
NAME

    neo4j-export-via-map-parallel2.sh -- perform calculations via `apoc.cypher.mapParallel2()` and export CSVs

SYNOPSIS

    neo4j-export-via-map-parallel2.sh output_file JDBC_conn_string SQL_query Cypher_query_file [expected_rec_number]
    neo4j-export-via-map-parallel2.sh -h: display this help

DESCRIPTION

    Perform calculations via Cypher_query and export in batches. The batch size is 1000 records.
    Output CSV.

    The following options are available:

    output_file           `-{batch #}` suffixes are automatically added when bactehd.use `/dev/stdout` for `stdout`. Note: the number of records is printed to stdout.
    JDBC_conn_string      JDBC connection string
    SQL_query             SQL to retrieve input data. Input data should be ordered when batched.
    Cypher_query_file     file containing Cypher query to execute which uses the `row` resultset returned by
                          `CALL apoc.load.jdbc(db, {SQL_query}) YIELD row`.
    expected_rec_number   If supplied, the number of output records is checked to be = expected
                          If `expected_rec_number` > 1000, output is batched and
                          ` LIMIT 1000 OFFSET {batch_offset}` clauses are added to `SQL_query`.

ENVIRONMENT

    Neo4j DB should be pre-loaded with data and indexed as needed.

EXIT STATUS

    The neo4j-export-via-map-parallel2 utility exits with one of the following values:

    0   Success
    1   The actual number of exported records is not the expected one

EXAMPLES

    To find all occurrences of the word `patricia' in a file:

        $ neo4j-export-via-map-parallel2.sh jaccard_co_citation_conditional_star_index.csv \
            "jdbc:postgresql://ernie2/ernie?user=ernie_admin&password=${ERNIE_ADMIN_POSTGRES}" \
            'SELECT 17538003 AS cited_1, 18983824 AS cited_2' \
            jaccard_co_citation_conditional_star_index.cypher

        jaccard_co_citation_conditional_star_index.cypher:
```
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
RETURN value.x_scp AS cited_1, value.y_scp AS cited_2, value.jaccard_index AS jaccard_co_citation_conditional_index;
```

AUTHOR(S)

    Written by Dmitriy "DK" Korobskiy.
HEREDOC
  exit 1
fi

set -e
set -o pipefail

declare -ri BATCH_SIZE=1000
readonly NUM_LINES_FILE="num_of_CSV_lines.txt"

readonly OUTPUT="$1"
readonly JDBC_CONN_STRING="$2"
readonly INPUT_DATA_SQL_QUERY="$3"
readonly CYPHER_QUERY_FILE="$4"
if [[ $5 ]]; then
  declare -ri EXPECTED_NUM_RECORDS=$5
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
// 5 pairs: 4.4s-16.0s
WITH '$JDBC_CONN_STRING' AS db, '${INPUT_DATA_SQL_QUERY}' AS sql
CALL apoc.load.jdbc(db, sql) YIELD row
$(cat "$CYPHER_QUERY_FILE")
HEREDOC
} | tee >(wc -l >"$NUM_LINES_FILE") >"$OUTPUT"

# shellcheck disable=SC2155 # suppressing an exit code here
declare -i num_of_records=$(cat "$NUM_LINES_FILE")
(( num_of_records=num_of_records-1 )) || :
echo "Exported $num_of_records records to $OUTPUT"

if [[ $EXPECTED_NUM_RECORDS && $num_of_records -ne $EXPECTED_NUM_RECORDS ]]; then
  # False if EXPECTED_NUM_RECORDS is not defined
  echo "Error! It's not the expected number of records ($EXPECTED_NUM_RECORDS)." 1>&2
  exit 1
fi

#cypher-shell --format plain <<HEREDOC
#WITH '$JDBC_CONN_STRING' AS db, '${INPUT_DATA_SQL_QUERY}' AS sql
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

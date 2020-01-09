#!/usr/bin/env bash
if [[ $# -lt 4 || "$1" == "-h" ]]; then
  cat << 'HEREDOC'
NAME

    neo4j-export-in-batches.sh -- batch input, perform calculations via a supplied Cypher query and export to a CSV

SYNOPSIS

    neo4j-export-in-batches.sh [-v] BATCH_OUTPUT JDBC_conn_string SQL Cypher_query_file [expected_rec_num] [batch_size]
    neo4j-export-in-batches.sh -h: display this help

DESCRIPTION

    Perform calculations via Cypher_query and export in batches. Export results to a CSV.

    The following options are available:

    -v                    verbose output

    BATCH_OUTPUT           `-{batch #}` suffixes are automatically added when bactehd.use `/dev/stdout` for `stdout`.
                          Note: the number of records is printed to stdout.

    JDBC_conn_string      JDBC connection string

    SQL                   SQL to retrieve input data. Input data should be ordered when batched.

    Cypher_query_file     file containing Cypher query to execute which uses the `row` resultset returned by
                          `CALL apoc.load.jdbc(db, {SQL_query}) YIELD row`.

                          WARNING: `apoc.cypher.mapParallel2()` is unstable as of v3.5.0.6 and may fail (produce
                          incomplete results) on medium-to-large batches. If this happens, adjust batch size downwards.

    expected_rec_number   If supplied, the number of output records is checked to be = expected

    batch_size            If `expected_rec_number` > `batch_size`, output is batched and
                          ` LIMIT {batch_size} OFFSET {batch_offset}` clauses are added to `SQL_query`.
                          WARNING: `apoc.cypher.mapParallel2()` is unstable as of v3.5.0.6 and may fail on
                          medium-to-large batches. batch_size = 50 is recommended to start with.

ENVIRONMENT

    Neo4j DB should be loaded with data and indexed as needed.

EXIT STATUS

    Exits with one of the following values:

    0   Success
    1   The actual number of exported records is not the expected one
    2   Cypher execution failed

EXAMPLES

    To find all occurrences of the word `patricia' in a file:

        $ neo4j-export-in-batches.sh /tmp/jaccard_co_citation_cond_star_i.csv
            "jdbc:postgresql://ernie2/ernie?user=ernie_admin&password=${ERNIE_ADMIN_POSTGRES}" \
            'SELECT 17538003 AS cited_1, 18983824 AS cited_2' \
            jaccard_co_citation_cond_star_i.cypher

        jaccard_co_citation_cond_star_i.cypher:
```
WITH $JDBC_conn_string AS db, $sql_query AS sql
CALL apoc.load.jdbc(db, sql) YIELD row
MATCH (x:Publication {node_id: row.cited_1})<--(Nxy)-->(y:Publication {node_id: row.cited_2})
WITH
  count(Nxy) AS intersect_size, min(Nxy.pub_year) AS first_co_citation_year, row.cited_1 AS x_scp, row.cited_2 AS y_scp
OPTIONAL MATCH (x:Publication {node_id: x_scp})<--(Nx:Publication)
  WHERE Nx.node_id <> y_scp AND Nx.pub_year <= first_co_citation_year
WITH collect(Nx) AS nx_list, intersect_size, first_co_citation_year, x_scp, y_scp
OPTIONAL MATCH (y:Publication {node_id: y_scp})<--(Ny:Publication)
  WHERE Ny.node_id <> x_scp AND Ny.pub_year <= first_co_citation_year
WITH nx_list + collect(Ny) AS union_list, intersect_size, x_scp, y_scp
UNWIND union_list AS union_node
RETURN x_scp AS cited_1, y_scp AS cited_2,
       toFloat(intersect_size) / (count(DISTINCT union_node) + 2) AS jaccard_co_citation_conditional_star_index;
```

AUTHOR(S)

    Written by Dmitriy "DK" Korobskiy.
HEREDOC
  exit 1
fi

set -e
set -o pipefail

readonly CYPHER_SHELL_OUTPUT=$(mktemp)

# Note: this file should be written to and owned by the `neo4j` user, hence can't use `mktemp`
readonly BATCH_OUTPUT="/tmp/batch.$$.csv"

while (( $# > 0 )); do
  case "$1" in
    -v)
      readonly VERBOSE_MODE="true";;
    *)
      break
  esac
  shift
done

readonly OUTPUT="$1"
readonly JDBC_CONN_STRING="$2"
readonly INPUT_DATA_SQL_QUERY="$3"
readonly CYPHER_QUERY_FILE="$4"
echo "Calculating via $CYPHER_QUERY_FILE"

if [[ $5 ]]; then
  declare -ri EXPECTED_NUM_RECORDS=$5
  shift
fi
if [[ $5 ]]; then
  declare -ri BATCH_SIZE=$5
  declare -i expected_batches=$(( EXPECTED_NUM_RECORDS / BATCH_SIZE ))
  if (( EXPECTED_NUM_RECORDS % BATCH_SIZE > 0 )); then
    (( ++expected_batches ))
  fi
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

declare -i processed_records=0 batch_num=1
export sql_query="'${INPUT_DATA_SQL_QUERY}'"
declare -i start_time batch_start_time batch_end_time elapsed_ms=0 est_total_time_ms
while (( processed_records < EXPECTED_NUM_RECORDS )); do
  # Epoch time + milliseconds
  batch_start_time=$(date +%s%3N)
  (( batch_num == 1 )) && (( start_time=batch_start_time ))
  if [[ $BATCH_SIZE ]]; then
    export sql_query="'${INPUT_DATA_SQL_QUERY} LIMIT $BATCH_SIZE OFFSET $processed_records'"
    declare -i expected_batch_records=$(( EXPECTED_NUM_RECORDS - processed_records ))
    if (( expected_batch_records > BATCH_SIZE )); then
      (( expected_batch_records = BATCH_SIZE ))
    fi
  else
    if [[ $EXPECTED_NUM_RECORDS ]]; then
      declare -i expected_batch_records=$EXPECTED_NUM_RECORDS
    fi
  fi

  # shellcheck disable=SC2016 # false alarm
  # cypher-shell :param does not support a multi-line string, hence de-tokenizing SQL query using `envsubst`.
  cypher_query="CALL apoc.export.csv.query(\"$(envsubst '\$sql_query' <"$CYPHER_QUERY_FILE")\", '$BATCH_OUTPUT',
    {params: {JDBC_conn_string: '$JDBC_CONN_STRING'}});"

  if ! echo "$cypher_query" | cypher-shell > "$CYPHER_SHELL_OUTPUT"; then
    cat << HEREDOC
The failed Cypher query:
=====
$cypher_query
=====

cypher-shell output:
=====
$(cat "$CYPHER_SHELL_OUTPUT")
=====
HEREDOC
    exit 2
  fi

  declare -i num_of_records
  # Suppress printing a file name
  num_of_records=$(wc --lines <"$BATCH_OUTPUT")
  if (( num_of_records > 0 )); then
    # Exclude CSV header
    (( --num_of_records )) || :
  fi
  if (( batch_num == 1 )); then
    # Copy to an output file owned by the current user
    cp "$BATCH_OUTPUT" "$OUTPUT"
  fi

  if [[ $BATCH_SIZE ]]; then
    echo -n "Batch #${batch_num}/${expected_batches}: "
    if (( batch_num > 1 )); then
      tail -n +2 <"$BATCH_OUTPUT" >> "$OUTPUT"
      if [[ "$VERBOSE_MODE" == true ]]; then
        ls -l "$OUTPUT"
      fi
    fi
  fi
  batch_end_time=$(date +%s%3N)
  (( delta_ms = batch_end_time - batch_start_time )) || :
  (( delta_s = delta_ms / 1000 )) || :

  # When performing calculations `/` will truncate the result and should be done last
  printf "%d records exported in %dh:%02dm:%02d.%01ds at %.1f records/min\n" "$num_of_records" \
      $(( delta_s / 3600 )) $(( (delta_s / 60) % 60 )) $(( delta_s % 60 )) $(( delta_ms % 1000 )) \
      "$(( 10**9 * num_of_records * 1000 * 60 / delta_ms ))e-9"

  if [[ $expected_batch_records && $num_of_records -ne $expected_batch_records ]]; then
    echo "Error! The actual exported number of records is not the expected number ($expected_batch_records)." 1>&2
    cat << HEREDOC
The failed Cypher query:
=====
$cypher_query
=====

cypher-shell output:
=====
$(cat "$CYPHER_SHELL_OUTPUT")
=====
HEREDOC
HEREDOC
    exit 1
  fi
  (( processed_records += num_of_records ))
  (( elapsed_ms += delta_ms ))

  if (( processed_records < EXPECTED_NUM_RECORDS )); then
    (( est_total_time_ms = elapsed_ms * EXPECTED_NUM_RECORDS / processed_records )) || :
    printf "ETA: %s" "$(TZ=America/New_York date --date=@$(( (start_time + est_total_time_ms) / 1000 )))"
  else
    printf "DONE"
  fi
  # When performing calculations `/` will truncate the result and should be done last
  printf " at %.1f records/min on average\n" "$(( 10**9 * processed_records * 1000 * 60 / elapsed_ms ))e-9"

  (( ++batch_num ))
done
rm -f "$CYPHER_SHELL_OUTPUT"

exit 0

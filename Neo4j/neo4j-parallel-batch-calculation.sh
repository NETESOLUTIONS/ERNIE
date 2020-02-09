#!/usr/bin/env bash
if [[ $# -lt 4 || "$1" == "-h" ]]; then
  cat << 'HEREDOC'
NAME

    neo4j-parallel-batch-calculation.sh -- perform calculations in batches via a Cypher query and export results

SYNOPSIS

    neo4j-parallel-batch-calculation.sh [-ae] [-v] input_CSV_file output_CSV_file Cypher_query_file [batch_size]
    neo4j-parallel-batch-calculation.sh -h: display this help

DESCRIPTION

    Perform calculations via `Cypher_query` in batches. Export results to a CSV.

    The following options are available:

    input_CSV_file        An RFC 4180-compliant CSV file (with EOLs set to `\n`) containing:
                            # all numeric (integer or float) columns
                            # a header row
                            # a trailing EOL in the last record line
                            # Future: no embedded commas in string columns

    output_CSV_file       Written as an RFC 4180-compliant CSV (with EOLs set to `\n`) containing a header row

    Cypher_query_file     file containing a Cypher query to execute which uses the `$input_data` array.

                          WARNING: `apoc.cypher.mapParallel2()` is unstable as of v3.5.0.6 and may fail (produce
                          incomplete results) on medium-to-large batches. If this happens, adjust batch size downwards.

    batch_size            If the number of input records > `batch_size`, process in parallel in batches.

    -ae                   If supplied, the number of output records per batch is asserted to be equal the number
                          of input records or +/- 1. The difference can occur due to approximate split into batches
                          performed by GNU Parallel `--block`.

                          Additionally, assert that the total number of output records = the number of input records.

    -v                    verbose diagnostics

ENVIRONMENT

    Neo4j DB should be loaded with data and indexed as needed.

EXIT STATUS

    Exits with one of the following values:

    0   Success
    1   The actual number of exported records is not the expected one
    2   Cypher execution failed

EXAMPLES

    To find all occurrences of the word `patricia' in a file:

        $ neo4j-parallel-batch-calculation.sh bin1.csv /tmp/jaccard_co_citation_i.csv jaccard_co_citation_i.cypher

        jaccard_co_citation_i.cypher:
```
UNWIND $input_data AS row
MATCH (x:Publication {node_id: row.cited_1})<--(Nxy)-->(y:Publication {node_id: row.cited_2})
WITH
  count(Nxy) AS intersect_size, row.cited_1 AS x_scp, row.cited_2 AS y_scp
OPTIONAL MATCH (x:Publication {node_id: x_scp})<--(Nx:Publication)
WITH collect(Nx) AS nx_list, intersect_size, x_scp, y_scp
OPTIONAL MATCH (y:Publication {node_id: y_scp})<--(Ny:Publication)
WITH nx_list + collect(Ny) AS union_list, intersect_size, x_scp, y_scp
UNWIND union_list AS union_node
RETURN
  x_scp AS cited_1, y_scp AS cited_2, toFloat(intersect_size) / count(DISTINCT union_node) AS jaccard_co_citation_index;
```

AUTHOR(S)

    Written by Dmitriy "DK" Korobskiy.
HEREDOC
  exit 1
fi

set -e
set -o pipefail

while (($# > 0)); do
  case "$1" in
    -ae)
      declare -rx ASSERT_NUM_REC_EQUALITY=true
      ;;
    -v)
      declare -rx VERBOSE_MODE=true
      ;;
    *)
      break
      ;;
  esac
  shift
done

declare -rx INPUT_FILE="$1"
declare -rx OUTPUT_FILE="$2"
declare -rx CYPHER_QUERY_FILE="$3"

declare -rxi INPUT_NUM_REC=$(($(wc --lines < "$INPUT_FILE") - 1))
echo -e "\nCalculating using $CYPHER_QUERY_FILE"
echo -n "The input number of records = $INPUT_NUM_REC"
if [[ $4 ]]; then
  declare -rxi BATCH_SIZE_REC=$4
  echo -n ", batch size: $BATCH_SIZE_REC"
  declare -xi expected_batches=$((INPUT_NUM_REC / BATCH_SIZE_REC))
  if ((INPUT_NUM_REC % BATCH_SIZE_REC > 0)); then
    ((expected_batches++))
  fi
  echo -e ", expected batches ≈ $expected_batches\n"

  # Retrieve the first batch by the number of records (exclude the header) and use its size as the batch size
  readonly BATCH_1=$(cat <(tail -n +2 "$INPUT_FILE" | head -"$BATCH_SIZE_REC"))
  readonly BATCH_SIZE=${#BATCH_1}
else
  declare -rxi expected_batches=1
fi
declare -xa HEADERS
# Parse headers using `csvtool` which outputs pure comma-separated cells
IFS=',' read -ra HEADERS < <(csvtool head 1 "$INPUT_FILE")
readonly HEADERS

export sql_query="'${INPUT_DATA_SQL_QUERY}'"
declare -ix START_TIME
START_TIME=$(date +%s%3N)

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

process_batch() {
  local -ri batch_num=$1
  local -i processed_records=$(((batch_num - 1) * BATCH_SIZE_REC))

  # Note: these files should be written to and owned by the `neo4j` user, hence can't use `mktemp`
  local -r BATCH_OUTPUT="/tmp/$$-batch-$batch_num.csv"
  local cypher_shell_output

  local -i batch_start_time batch_end_time delta_ms delta_s

  # Epoch time + milliseconds
  batch_start_time=$(date +%s%3N)

  # Convert piped data to a Cypher list
#  local input_data_list=":param input_data => [ "
  local input_data_list="[ "
  local -a cells
  local param_rows cell
  while IFS=',' read -ra cells; do
    # Convert one record to a Cypher map
    if [[ $param_rows ]]; then
      param_rows="$param_rows, "
    fi
    param_rows="$param_rows{"
    local -i i=0
    for cell in ${cells[*]}; do
      if ((i > 0)); then
        param_rows="$param_rows, "
      fi
      # Assume numeric input data. String input data should be double-quoted in Cypher.
      param_rows="${param_rows}${HEADERS[$i]}: $cell"

      ((i++))
    done
    param_rows="$param_rows}"
  done
  input_data_list="$input_data_list $param_rows ]"

  #  (( batch_num == 1 )) && (( START_TIME=batch_start_time ))
  if [[ $BATCH_SIZE_REC ]]; then
    declare -i expected_batch_records=$((INPUT_NUM_REC - processed_records))
    if ((expected_batch_records > BATCH_SIZE_REC)); then
      ((expected_batch_records = BATCH_SIZE_REC))
    fi
  else
    declare -i expected_batch_records=$INPUT_NUM_REC
  fi

  local cypher_query
  cypher_query="CALL apoc.export.csv.query('$(cat "$CYPHER_QUERY_FILE")', '$BATCH_OUTPUT',
    {params: {input_data: $input_data_list}});"

  if ! cypher_shell_output=$(echo "$cypher_query" | cypher-shell); then
    cat << HEREDOC
The failed Cypher query:
=====
$cypher_query
=====

cypher-shell output:
=====
$cypher_shell_output
=====
HEREDOC
    exit 2
  fi

  declare -i num_of_records
  # Suppress printing a file name
  num_of_records=$(wc --lines < "$BATCH_OUTPUT")
  if ((num_of_records > 0)); then
    # Exclude CSV header
    ((num_of_records--)) || :
  fi
  if [[ ! -s "$OUTPUT" ]]; then
    # Copy headers to an output file owned by the current user
    head -1 "$BATCH_OUTPUT" > "$OUTPUT"
  fi

  if [[ $BATCH_SIZE_REC ]]; then
    echo -n "Batch #${batch_num}/≈${expected_batches}: "
  fi
  # Appending with a write-lock to prevent corruption during concatenation in parallel
  # shellcheck disable=SC2094 # flock doesn't write to $OUTPUT, just locks it
  flock "$OUTPUT" tail -n +2 < "$BATCH_OUTPUT" >> "$OUTPUT"
  if [[ "$VERBOSE_MODE" == true ]]; then
    echo "Total records in the output file: $(($(wc --lines < "$OUTPUT") - 1))"
  fi

  batch_end_time=$(date +%s%3N)
  ((delta_ms = batch_end_time - batch_start_time)) || :
  ((delta_s = delta_ms / 1000)) || :

  # When performing calculations `/` will truncate the result and should be done last
  printf "%d records exported in %dh:%02dm:%02d.%ds at %.1f records/min (this thread)." "$num_of_records" \
      $((delta_s / 3600)) $(((delta_s / 60) % 60)) $((delta_s % 60)) $((delta_ms % 1000)) \
      "$((10 ** 9 * num_of_records * 1000 * 60 / delta_ms))e-9"

  if [[ $ASSERT_NUM_REC_EQUALITY == true ]]; then
    local -i difference=$((num_of_records - expected_batch_records))
    # ${difference#-}: abs(difference)
    if [[ ${difference#-} -gt 1 ]]; then
      exec 1>&2
      cat << HEREDOC
  Error! The actual number of records differs from the expected number ($expected_batch_records) for more than 1 record.
  The failed Cypher query:
  =====
  $cypher_query
  =====

  cypher-shell output:
  =====
  $cypher_shell_output
  =====
HEREDOC
      exit 1
    fi
  fi

  ((processed_records += num_of_records))
  local -i elapsed_ms=$((batch_end_time - START_TIME))
  if ((processed_records < INPUT_NUM_REC)); then
    ((est_total_time_ms = elapsed_ms * INPUT_NUM_REC / processed_records)) || :
    printf " ETA: %s" "$(TZ=America/New_York date --date=@$(((START_TIME + est_total_time_ms) / 1000)))"
  else
    printf " DONE"
  fi
  # When performing calculations `/` will truncate the result and should be done last
  printf " at %.1f records/min overall.\n" "$((10 ** 9 * processed_records * 1000 * 60 / elapsed_ms))e-9"
}
export -f process_batch

rm -f "$OUTPUT"
# Pipe input CSV (skipping the headers) and parse using `csvtool` which outputs pure comma-separated cells
tail -n +2 "$INPUT_FILE" \
    | csvtool col 1- - \
    | parallel --pipe --block "$BATCH_SIZE" --halt soon,fail=1 --line-buffer --tagstring '|job#{#} s#{%}|' \
        process_batch '{#}'

exit 0

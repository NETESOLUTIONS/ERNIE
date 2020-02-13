#!/usr/bin/env bash
if [[ $# -lt 4 || "$1" == "-h" ]]; then
  cat << 'HEREDOC'
NAME

    neo4j-batch-compute-csv-input.sh -- perform calculations in batches via a Cypher query and export results

SYNOPSIS

    neo4j-batch-compute-csv-input.sh [-c] [-ae] [-v] input_CSV_file output_CSV_file Cypher_query_file [appr_batch_size]
    neo4j-batch-compute-csv-input.sh -h: display this help

DESCRIPTION

    Perform calculations via Cyoher in batches. Export results to a CSV. The process can be gracefully stopped by
    creating (e.g. via `touch`) a file `{output_dir}/{output_CSV_file_name}.stop`.

    The following options are available:

    input_CSV_file        An RFC 4180-compliant CSV file (with EOLs set to `\n`) containing:
                            # all numeric (integer or float) columns (no quotes)
                            # a header row (no quotes)
                            # a trailing EOL in the last record line

    output_CSV_file       Written as an RFC 4180-compliant CSV (with EOLs set to `\n`) containing a header row.
                          Temporary CSV files are written into the same directory.

                          WARNING: Without clean start option, the output file, if exists, will be appended to.

    Cypher_query_file     A file containing a Cypher query to execute which uses the `$input_data` array.
                          TODO The query should not contain embedded double quotes.

                          WARNING: `apoc.cypher.mapParallel2()` is unstable as of v3.5.0.6 and may fail (produce
                          incomplete results) on medium-to-large batches. If this happens, adjust batch size downwards.

    appr_batch_size       An approximate number of records per batch.
                          If the number of input records > `appr_batch_size`, process in parallel in batches.
                          Batches are sliced by GNU Parallel in bytes.

    -c                    Clean start. The process normally resumes after failures, skipping over already generated
                          batches and appending to the output. Clean start would remove leftover batches and the
                          output first. This assumes that leftover batches if any are writeable by the current user.

                          WARNING: resume doesn't guarantee to produce clean results because GNU parallel `--halt now`
                          terminates remaining jobs abnormally. `-ae` is recommended to use when resuming. If the
                          total number of records in the output is not what's expected differences could be reconciled
                          manually.

    -ae                   Assert that:
                            1. The number of output records per batch = the number of batch input records.
                            2. The total number of output records = the total number of input records.

    -v                    Verbose diagnostics.

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

# Get a script directory, same as by $(dirname $0)
readonly SCRIPT_DIR=${0%/*}
readonly ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)

if ! command -v parallel >/dev/null; then
  echo "Please install GNU Parallel"
  exit 1
fi

while (($# > 0)); do
  case "$1" in
    -c)
      readonly CLEAN_START=true
      ;;
    -ae)
      readonly ASSERT_NUM_REC_EQUALITY=true
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

[[ $VERBOSE_MODE == true ]] && set -x

#region Parse input filename
declare -x input_file="$1"
if [[ "${input_file}" != */* ]]; then
  input_file=./${input_file}
fi
# Remove shortest /* suffix
readonly INPUT_DIR=${input_file%/*}
# dir = '.' for files in the current directory

# Remove longest */ prefix
readonly INPUT_NAME_WITH_EXT=${input_file##*/}

readonly ABSOLUTE_INPUT_DIR="$(cd ${INPUT_DIR} && pwd)"
readonly ABSOLUTE_INPUT_FILE="${ABSOLUTE_INPUT_DIR}/${INPUT_NAME_WITH_EXT}"
#endregion

#region Parse output filename
declare -x output_file="$2"
# Remove longest */ prefix
declare output_file_name_with_ext=${output_file##*/}

if [[ "${output_file_name_with_ext}" != *.* ]]; then
  output_file_name_with_ext=${output_file_name_with_ext}.
fi

# Remove shortest .* suffix
declare -rx OUTPUT_FILE_NAME=${output_file_name_with_ext%.*}

if [[ "${output_file}" != */* ]]; then
  output_file=./${output_file}
fi
# Remove shortest /* suffix
declare -rx OUTPUT_DIR=${output_file%/*}
#endregion

#region Parse input filename
declare cypher_query_file="$3"

if [[ "${cypher_query_file}" != */* ]]; then
  cypher_query_file=./${cypher_query_file}
fi
# Remove shortest /* suffix
readonly CYPHER_DIR=${cypher_query_file%/*}
# dir = '.' for files in the current directory

# Remove longest */ prefix
readonly CYPHER_NAME_WITH_EXT=${cypher_query_file##*/}

readonly ABSOLUTE_CYPHER_DIR="$(cd ${CYPHER_DIR} && pwd)"
declare -rx ABSOLUTE_CYPHER_FILE="${ABSOLUTE_CYPHER_DIR}/${CYPHER_NAME_WITH_EXT}"
#endregion

if [[ ! -d "${OUTPUT_DIR}" ]]; then
  mkdir -p "${OUTPUT_DIR}"
  chmod g+w "${OUTPUT_DIR}"
fi
cd "${OUTPUT_DIR}"
echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##\n"

declare -rxi INPUT_RECS=$(($(wc --lines < "$ABSOLUTE_INPUT_FILE") - 1))
echo -e "\nCalculating via ${ABSOLUTE_CYPHER_FILE}, $ABSOLUTE_INPUT_FILE => $output_file"
echo -n "The input number of records = $INPUT_RECS"
if [[ $4 ]]; then
  declare -rxi BATCH_SIZE_REC=$4
  echo -n ", batch size: $BATCH_SIZE_REC"

  declare -xi expected_batches=$((INPUT_RECS / BATCH_SIZE_REC))
  if ((INPUT_RECS % BATCH_SIZE_REC > 0)); then
    ((expected_batches++))
  fi
  echo -e ", expected batches ≈ $expected_batches"

  # Retrieve the first batch by the number of records (exclude the header) and use its size as the batch size
  readonly BATCH_1=$( cat <(tail -n +2 "$ABSOLUTE_INPUT_FILE" | head -"$BATCH_SIZE_REC") )
  declare -i batch_size=${#BATCH_1}

  # Pad batch size by ADJUSTMENT_PERCENT because GNU Parallel chops batches unevenly, by the byte size
  declare -ri ADJUSTMENT_PERCENT=120
  (( batch_size = batch_size * ADJUSTMENT_PERCENT / 100 ))
else
  declare -rxi expected_batches=1
  echo ""
fi
declare -x INPUT_COLUMN_LIST
# Parse headers
INPUT_COLUMN_LIST=$(head -1 "$ABSOLUTE_INPUT_FILE")
readonly INPUT_COLUMN_LIST
echo -e "Input columns: ${INPUT_COLUMN_LIST[*]}\n"

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
  [[ $VERBOSE_MODE == true ]] && set -x

  local -ri batch_num=$1
  if [[ $BATCH_SIZE_REC ]]; then
    echo -n "Batch #${batch_num}/≈${expected_batches}: "
  fi

  # Note: these files should be written to and owned by the `neo4j` user, hence can't use `mktemp`.
  # The path should be absolute for a Neo4j server to write to it.
  local -r BATCH_OUTPUT="$OUTPUT_DIR/$OUTPUT_FILE_NAME-batch-$batch_num.csv"
  if [[ -s ${BATCH_OUTPUT} ]]; then
    echo "SKIPPED (already generated)."
    exit 0
  fi
  readonly STOP_FILE_NAME="${OUTPUT_FILE_NAME}.stop"
  if [[ -f "$STOP_FILE_NAME" ]]; then
    echo "found the stop file: $OUTPUT_DIR/$STOP_FILE_NAME. Stopping the process..."
    rm -f "$STOP_FILE_NAME"
    exit 1
  fi

  local -a INPUT_COLUMNS
  # Parse a comma-separated list into an array
  IFS="," read -ra INPUT_COLUMNS <<< "${INPUT_COLUMN_LIST}"
  readonly INPUT_COLUMNS
  local -i appr_processed_records=$(( (batch_num - 1) * BATCH_SIZE_REC ))
  local -i batch_start_time batch_end_time delta_ms delta_s
  # Epoch time + milliseconds
  batch_start_time=$(date +%s%3N)

  # Convert piped data to a Cypher list
#  local input_data_list=":param input_data => [ "
  local input_data_list="[ "
  local -a cells
  local param_rows cell
  local -i input_batch_recs=0
  while IFS=',' read -ra cells; do
    ((input_batch_recs++))

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
      param_rows="${param_rows}${INPUT_COLUMNS[$i]}: $cell"

      ((i++))
    done
    param_rows="$param_rows}"
  done
  input_data_list="${input_data_list}${param_rows} ]"

  local cypher_query
  cypher_query="CALL apoc.export.csv.query(\"$(cat "$ABSOLUTE_CYPHER_FILE")\", '$BATCH_OUTPUT',
      {params: {input_data: $input_data_list}});"

  local cypher_shell_output
  if ! cypher_shell_output=$(echo "$cypher_query" | cypher-shell --encryption false); then
    cat << HEREDOC
Error! The Cypher query failed:
=====
$cypher_query
=====

The cypher-shell output:
=====
$cypher_shell_output
=====
HEREDOC
    exit 2
  fi

  local -i num_of_recs
  # Suppress printing a file name
  num_of_recs=$(wc --lines < "$BATCH_OUTPUT")
  if ((num_of_recs > 0)); then
    # Exclude CSV header
    ((num_of_recs--)) || :
  fi

  if [[ ! -s "$output_file" ]]; then
    # Copy headers to an output file owned by the current user
    head -1 "$BATCH_OUTPUT" > "$output_file"
  fi
  # Appending with a write-lock to prevent corruption during concatenation in parallel
  # shellcheck disable=SC2094 # flock doesn't write to $output_file, just locks it
  flock "$output_file" tail -n +2 < "$BATCH_OUTPUT" >> "$output_file"

  if [[ "$VERBOSE_MODE" == true ]]; then
    echo "Total records in the output file: $(($(wc --lines < "$output_file") - 1))"
  fi

  batch_end_time=$(date +%s%3N)
  ((delta_ms = batch_end_time - batch_start_time)) || :
  ((delta_s = delta_ms / 1000)) || :
  # When performing calculations `/` will truncate the result and should be done last
  printf "%d records exported in %dh:%02dm:%02d.%ds at %.1f records/min (this thread)." "$num_of_recs" \
      $((delta_s / 3600)) $(((delta_s / 60) % 60)) $((delta_s % 60)) $((delta_ms % 1000)) \
      "$((10 ** 9 * num_of_recs * 1000 * 60 / delta_ms))e-9"

  if [[ $ASSERT_NUM_REC_EQUALITY == true ]]; then
    if (( num_of_recs != input_batch_recs )); then
      cat << HEREDOC

Error! The actual number of records $num_of_recs differs from the expected number $input_batch_recs.
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

  ((appr_processed_records += num_of_recs))
  local -i elapsed_ms=$((batch_end_time - START_TIME))
  ((est_total_time_ms = elapsed_ms * INPUT_RECS / appr_processed_records)) || :
  # When performing calculations `/` will truncate the result and should be done last
  printf " ETA ≈ %s at ≈ %.1f records/min overall.\n" \
      "$(TZ=America/New_York date --date=@$(((START_TIME + est_total_time_ms) / 1000)))" \
      "$((10 ** 8 * appr_processed_records * 1000 * 60 / elapsed_ms))e-8"
}
export -f process_batch

if [[ "$CLEAN_START" == true ]]; then
  echo "Cleaning previously generated output if any"
  set +o pipefail
  ls | grep -E "${OUTPUT_FILE_NAME}.*\.csv$" | xargs -I '{}' rm -fv {}
  set -o pipefail
fi

# Pipe input CSV (skipping the headers)
# Reserve job slots lest the server gets CPU-taxed until Neo4j starts timing out `cypher-shell` connections (in 5s)
# FIXME report. With --pipe, --halt soon,fail=1 does not terminate on failures
# TODO report. With --pipe, --tagstring '|job#{#} s#{%}|' reports slot # = 1 for all jobs
# TODO report. CSV streaming parsing using `| csvtool col 1- -` fails on a very large file (97 Mb, 4M rows)
echo -e "\nStarting batch computation..."
tail -n +2 "$ABSOLUTE_INPUT_FILE" \
    | parallel --jobs 85% --pipe --block "$batch_size" --halt now,fail=1 --line-buffer --tagstring '|job#{#}|' \
        'process_batch {#}'

if [[ "$ASSERT_NUM_REC_EQUALITY" == true ]]; then
  declare -i num_of_recs
  num_of_recs=$(wc --lines < "$output_file")
  if ((num_of_recs > 0)); then
    # Exclude CSV header
    ((num_of_recs--)) || :
  fi
  if (( num_of_recs != INPUT_RECS )); then
    echo "Error! The total actual number of records $num_of_recs differs from the expected number $INPUT_RECS." >&2
    exit 1
  fi
fi

echo -e "\nBatch computation is DONE."
exit 0

#!/usr/bin/env bash
if [[ $# -lt 1 || "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    calculate_disruption.sh -- calculate disruption measures of focal paper(s)

SYNOPSIS

    calculate_disruption.sh output_file
    calculate_disruption.sh -h: display this help

DESCRIPTION

    Processes all supplied publications: in text format on `stdin`, CSV-like with one WoS id per line
    Header lines and any invalid ids (not starting with 'WOS:') are skipped automatically.

    Produces a CSV with the header.

ENVIRONMENT

    Postgres accessible by default (via `psql`).

    Set standard Postgres environment variables (https://www.postgresql.org/docs/current/libpq-envars.html) to alter
    connection parameters, e.g.:
      PGHOST
      PGPORT
      PGDATABASE
      PGPASSWORD/PGPASSFILE


EXAMPLES

        $ cat dataset100_wos_ids.csv | ./calculate_disruption.sh out/disruption_measures.csv

AUTHOR(S)

    Written by Dmitriy "DK" Korobskiy.
HEREDOC
  exit 1
fi

set -ex
set -o pipefail

# Get a script directory, same as by $(dirname $0)
readonly SCRIPT_DIR=${0%/*}
declare -rx ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)

declare -rx OUTPUT_FILE="$1"

echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##\n"

# Executed in a subshell by `parallel`
process_focal_paper() {
  set -e
  local input=$1
  # Header lines and any invalid ids (not starting with 'WOS:') are skipped

  echo "Processing ${input} ..."
  psql --quiet --tuples-only --no-align --field-separator=, -f "${ABSOLUTE_SCRIPT_DIR}/dependency.sql" \
        -v pub_id="${input}" >>"${OUTPUT_FILE}"
  echo "${input}: done."
}
export -f process_focal_paper


echo "focal_paper_id,dependency_index" >"${OUTPUT_FILE}"


#echo "focal_paper_id,disruption_i,disruption_j,j1,j2,j3,j4,j5,j6,j7,j8,j9,j10,j11,disruption_k,disruption" >"${OUTPUT_FILE}"
# Reading input from the script `stdin`
parallel --halt soon,fail=1 --verbose --line-buffer --tagstring '|job#{#} s#{%}|' process_focal_paper {}

exit 0

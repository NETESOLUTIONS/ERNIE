#!/usr/bin/env bash
if [[ $# -lt 1 || "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    calculate_disruption.sh -- calculate disruption measures of focal paper(s)

SYNOPSIS

    calculate_disruption.sh output_file
    calculate_disruption.sh -h: display this help

DESCRIPTION

    Processes all supplied publications: text on STDIN, CSV-like with one WoS id per line
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

        $ cat dataset100_wos_ids.csv | calculate_disruption.sh out/dataset100_disruption_measure.csv

AUTHOR(S)

    Written by Dmitriy "DK" Korobskiy.
HEREDOC
  exit 1
fi

set -ex
set -o pipefail

# Get a script directory, same as by $(dirname $0)
readonly SCRIPT_DIR=${0%/*}
readonly ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)

readonly OUTPUT_FILE="$1"

echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##\n"

process_focal_paper() {
  set -e
  local input=$1
  if [[ $input = WOS:* ]]; then
    echo "Processing ${input} ..."
    psql -f "${ABSOLUTE_SCRIPT_DIR}/disruption.sql" -v pub_id="${input}" >>"${OUTPUT_FILE}"
    echo "${input}: done."
  fi
}
export -f process_focal_paper

parallel --halt soon,fail=1 --verbose --line-buffer --tagstring '|job#{#} s#{%}|' process_focal_paper {} <&1

exit 0

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
  if [[ -n "${input}" ]]; then
    echo "Processing ${input} ..."
    psql --quiet --tuples-only --no-align --field-separator=, -f "${ABSOLUTE_SCRIPT_DIR}/disruption.sql" \
        -v pub_id="${input}" >>"${OUTPUT_FILE}"
    echo "${input}: done."
  fi
}
export -f process_focal_paper

if [[ "$2" == "f1000_disruption.sql" ]]; then
    echo "focal_paper_id,i,orig_j,orig_k,k1_1,k2_1,k3_1,k4_1,k5_1,k6_1,k7_1,k8_1,k9_1,k10_1,k11_1,k1_2,k2_2,k3_2,k4_2,k5_2,"\
    "k6_2,k7_2,k8_2,k9_2,k10_2,k11_2,j1_1,j2_1,j3_1,j4_1,j5_1,j6_1,j7_1,j8_1,j9_1,j10_1,j11_1,j1_2,j2_2,j3_2,j4_2,j5_2,j6_2,"\
    "j7_2,j8_2,j9_2,j10_2,j11_2" >"${OUTPUT_FILE}"
else
    echo "focal_paper_id,i,orig_j,orig_k,new_j,new_j1_1,new_j2_1,new_j3_1,new_j4_1,new_j5_1,new_j6_1,new_j7_1,new_j8_1,"\
    "new_j9_1,new_j10_1,new_j11_1,new_j1_2,new_j2_2,new_j3_2,new_j4_2,new_j5_2,new_j6_2,new_j7_2,new_j8_2,new_j9_2,new_j10_2,"\
    "new_j11_2,new_k,new_k1_1,new_k2_1,new_k3_1,new_k4_1,new_k5_1,new_k6_1,new_k7_1,new_k8_1,new_k9_1,new_k10_1,new_k11_1,"\
    "new_k1_2,new_k2_2,new_k3_2,new_k4_2,new_k5_2,new_k6_2,new_k7_2,new_k8_2,new_k9_2,new_k10_2,new_k11_2" >"${OUTPUT_FILE}"
fi

#echo "focal_paper_id,disruption_i,disruption_j,j1,j2,j3,j4,j5,j6,j7,j8,j9,j10,j11,disruption_k,disruption" >"${OUTPUT_FILE}"
# Reading input from the script `stdin`
parallel --halt soon,fail=1 --verbose --line-buffer --tagstring '|job#{#} s#{%}|' process_focal_paper {}

exit 0

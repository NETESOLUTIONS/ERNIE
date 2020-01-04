#!/usr/bin/env bash
if [[ $# -lt 1 || "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    calculate_co_cited_neighborhoods.sh -- calculate disruption measures of focal paper(s)

SYNOPSIS

    calculate_co_cited_neighborhoods.sh output_file
    calculate_co_cited_neighborhoods.sh -h: display this help

DESCRIPTION

    Processes all supplied publications: in text format on `stdin`
    CSV file with columns cited_1,cited_2,first_cited_year


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

        $ cat dataset100_wos_ids.csv | ./calculate_co_cited_neighborhoods.sh out/co_cited_neighborhood_measures.csv

AUTHOR(S)

    Written by Sitaram Devarakonda.
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

process_co_cited_pair() {
    set -e
    cited_1=$(echo $1 | cut -d ',' -f 1)
    cited_2=$(echo $1 | cut -d ',' -f 2)
    first_cited_year=$(echo $1 | cut -d ',' -f 3)

    psql --quiet --tuples-only --no-align --field-separator=, -f "${ABSOLUTE_SCRIPT_DIR}/co_cited_neighborhoods.sql" \
        -v cited_1="${cited_1}" -v cited_2="${cited_2}" -v first_cited_year="${first_cited_year}" >>"${OUTPUT_FILE}"

    echo "${cited_1} ${cited_2} ${first_cited_year} done"
}

export -f process_co_cited_pair

echo "cited_1,cited_2,first_cited_year,cited_1_count,cited_2_count,pair_edges,exy,intersection_count,union_count,union_xy,intersection_count2,union_count2,union_xy2" >> "${OUTPUT_FILE}"

parallel --halt soon,fail=1 --verbose --line-buffer --tagstring '|job#{#} s#{%}|' process_co_cited_pair {}

exit 0
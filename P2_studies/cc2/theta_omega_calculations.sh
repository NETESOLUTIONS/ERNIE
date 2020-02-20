#!/usr/bin/env bash
if [[ "$1" == "-h" ]]; then
#  cat <<'HEREDOC'
#NAME
#
#    theta_omega_calculations.sh -- calculate theta omega measures of co-cited pairs
#
#SYNOPSIS
#
#    theta_omega_calculations.sh
#    theta_omega_calculations.sh -h: display this help
#
#DESCRIPTION
#
#    Processes all supplied co-cited pairs: in text format on `stdin`
#ENVIRONMENT
#
#    Postgres accessible by default (via `psql`).
#
#    Set standard Postgres environment variables (https://www.postgresql.org/docs/current/libpq-envars.html) to alter
#    connection parameters, e.g.:
#      PGHOST
#      PGPORT
#      PGDATABASE
#      PGPASSWORD/PGPASSFILE
#
#
#EXAMPLES
#
#        $ cat dataset100_wos_ids.csv | ./theta_omega_calculations.sh
#
#AUTHOR(S)
#
#    Written by Sitaram Devarakonda
#HEREDOC
#  exit 1
fi

set -ex
set -o pipefail


# Get a script directory, same as by $(dirname $0)
readonly SCRIPT_DIR=${0%/*}
declare -rx ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)

declare -ix START_TIME
START_TIME=$(date +%s)

echo "start time $START_TIME"

declare -ix intermediate_time

declare -ix counter
counter=0

theta_omega_calculations() {

  set -e
  local input=$1

  echo "Processing ${input} ..."


  first=$(echo ${input} | cut -d ',' -f 1)
  second=$(echo ${input} | cut -d ',' -f 2)
  year=$(echo ${input} | cut -d ',' -f 3)
  psql -f ${ABSOLUTE_SCRIPT_DIR}/Postgres/theta_omega.sql -v cited_1=${first} -v cited_2=${second} -v first_year=${year}

  counter=$((counter+1))

  if [[ ${counter} == 1000   ]]; then
    intermediate_time=$(date +%s)
    duration=$(echo "$intermediate_time - $START_TIME" | bc)
    per_minute=$(($counter * 60))
    printf "Number of records per minute %.1f \n"  \
    "$(($per_minute/$duration))e-7"
  fi

}

export -f theta_omega_calculations

parallel --halt soon,fail=1 --verbose --line-buffer --tagstring '|job#{#} s#{%}|' theta_omega_calculations {}

end_time=$(date +%s)
echo "end time $end_time"

exit 0
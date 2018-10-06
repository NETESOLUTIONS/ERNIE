#!/usr/bin/env bash
if [[ $1 == "-h" || $# -lt 2 ]]; then
  cat <<HEREDOC
NAME

    parallel_move_tables -- move Postgres tables to a different tablespace

SYNOPSIS

    $0 table_regex_pattern destination_tablespace
    $0 -h: display this help

DESCRIPTION

    Moves all tables conforming to a SQL regex (in SIMILAR TO) to the destination tablespace in parallel.

EXAMPLES

    Move all uhs* and del* tables to temp_tbs tablespace

        parallel_move_tables.sh 'uhs%|del%' temp_tbs
HEREDOC
  exit 1
fi

set -xe
set -o pipefail

# Get a script directory, same as by $(dirname $0)
script_dir=${0%/*}
absolute_script_dir=$(cd "${script_dir}" && pwd)

echo -e "\n## Running under ${USER}@${HOSTNAME} at ${PWD} ##\n"

psql -f "${absolute_script_dir}/public_tables.sql" -v "tablePattern=$1" --quiet | \
  parallel --halt soon,fail=1 --line-buffer "set -e
    echo 'Job #{#} for {}: starting at the parallel slot #{%} ...'
    psql -v ON_ERROR_STOP=on --echo-all -c 'ALTER TABLE public.{} SET TABLESPACE $2;'
    echo 'Job #{#} for {}: done.'"
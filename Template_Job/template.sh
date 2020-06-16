#!/usr/bin/env bash
# Author: Dmitriy "DK" Korobskiy
# Created: 12/1/2017

if [[ $1 == "-h" ]]; then
  cat <<END
SYNOPSIS
  $0 [{working directory}]

DESCRIPTION
  * Changes working directory to a specified or {script_dir}/build/ by default.
  This directory will be created if needed otherwise it must be writeable for this system group.
  * Executes sample Postgres and Python scripts
  ** template_job_lf.csv is expected in the working directory

ENVIRONMENT
  Required environment variables:
  * PGHOST/PGDATABASE/PGUSER  default Postgres connection parameters
END
  exit 1
fi

# -x Print a trace of simple commands, for commands, case commands, select commands, and arithmetic for commands and
# their arguments or associated word lists after they are expanded and before they are executed.
#
# -e Exit immediately if a pipeline, a single simple command , a list (see Lists), or a compound command returns a
#   non-zero status. The shell does not exit if the command that fails is:
#   * part of the command list immediately following a while or until keyword
#   * part of the test in an if statement
#   * part of any command executed in a && or || list except the command following the final && or ||
#   * any command in a pipeline but the last
#   * or if the command’s return status is being inverted with !
set -xe

# Get a script directory, same as by $(dirname $0)
script_dir=${0%/*}
absolute_script_dir=$(cd "${script_dir}" && pwd)
work_dir=${1:-${absolute_script_dir}/build} # $1 with the default
if [[ ! -d "${work_dir}" ]]; then
  mkdir "${work_dir}"
  chmod g+w "${work_dir}"
fi
cd "${work_dir}"
echo -e "\n## Running under ${USER}@${HOSTNAME} at ${PWD} ##\n"

if [[ "${HOSTNAME}" == *ernie2* ]]; then
  echo "Executing a Postgres script via $(psql --version)"
  # The script uses `\set ON_ERROR_STOP on` and `\set ECHO all`
  # -h localhost switches from Unix sockets to TCP/IP
  psql -f ${absolute_script_dir}/template_psql_script.sql -v "work_dir=${work_dir}"

  echo "Executing a Postgres connectivity test in Python ..."
  # Unquoted $SWITCHES get expanded into *multiple* command-line arguments
  # Quoted $SWITCHES get expanded into a *single* command-line argument
  # Python 2.7.13 :: Anaconda custom (64-bit)
  /anaconda2/bin/python ${absolute_script_dir}/template_connect_to_Postgres.py -t test 'arg with spaces' ${switches}
fi

if [[ "${HOSTNAME}" == *neo4j* ]]; then
  echo "Executing a Cypher script ..."
  cypher-shell <"${absolute_script_dir}/template_cypher_script.cypher"
fi

echo -e "Done on this server.\n"
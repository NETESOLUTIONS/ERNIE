#!/usr/bin/env bash
if [[ $1 == "-h" || $# -lt 5 ]]; then
  cat <<'HEREDOC'
NAME

  neo4j_bulk_import.sh -- loads CSVs in bulk to Neo4j 4+

SYNOPSIS

  neo4j_bulk_import.sh node_label nodes_file edge_label edges_file current_user_password [DB_name_prefix]
  neo4j_bulk_import.sh -h: display this help

DESCRIPTION

  Bulk imports to a new `{DB_name_prefix-}v{file_timestamp}` DB and switches to this DB.
  WARNING: Neo4j service is restarted.

  Spaces are replaced by underscores in the `DB_name_prefix`.

ENVIRONMENT

  Executing user must be a sudoer.
  The current directory must be writeable for the neo4j user

HEREDOC
  exit 1
fi

set -e
set -o pipefail


# Get a script directory, same as by $(dirname $0)
readonly SCRIPT_DIR=${0%/*}
readonly ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)

readonly NODE_LABEL="$1"
readonly NODES_FILE="$2"
readonly EDGE_LABEL="$3"
readonly EDGES_FILE="$4"
readonly USER_PASSWORD="$5"
if [[ $6 ]]; then
  readonly DB_PREFIX="${6// /_}-"
fi

echo -e "\n## Running under ${USER}@${HOSTNAME} at ${PWD} ##\n"

if ! command -v cypher-shell >/dev/null; then
  echo "Please install Neo4j"
  exit 1
fi

# region Generate a unique db_name

file_date1=$(date -r "${NODES_FILE}" +%F-%H-%M-%S)
file_date2=$(date -r "${EDGES_FILE}" +%F-%H-%M-%S)
if [[ ${file_date1} > ${file_date2} ]]; then
  db_ver="${file_date1}"
else
  db_ver="${file_date2}"
fi
db_name="${DB_PREFIX}v${db_ver}.db"
# endregion

# The current directory must be writeable for the neo4j user. Otherwise, it'd fail with the
# `java.io.FileNotFoundException: import.report (Permission denied)` error
echo "$USER_PASSWORD" | sudo --stdin -u neo4j bash -c "set -xe
  echo 'Loading data into ${db_name}'
  neo4j-admin import '--nodes=${NODE_LABEL}=${NODES_FILE}' --id-type=INTEGER \\
    '--relationships=${EDGE_LABEL}=${EDGES_FILE}' '--database=${db_name}'"

"${ABSOLUTE_SCRIPT_DIR}/neo4j_switch_db.sh" "${db_name}" "$USER_PASSWORD"

exit 0

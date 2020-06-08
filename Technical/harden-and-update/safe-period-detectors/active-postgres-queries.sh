#!/usr/bin/env bash

usage() {
  cat << 'HEREDOC'
NAME

    active_postgres_queries.sh -- check the running non-system Postgres queries in a Postgres DB

SYNOPSIS

    active_postgres_queries.sh [-v] postgres_DB
    active_postgres_queries.sh -h: display this help

DESCRIPTION

    Check the running non-system Postgres queries in the specified database.

    Running queries are all queries excluding:

    1. `idle` queries
    2. Queries executed by `postgres` user

    The following options are available:

    -v    verbose: print all execute lines

ENVIRONMENT

    Pre-requisite dependencies:

      # `pcregrep`

EXIT STATUS

    The utility exits with one of the following values:

    0   No running queries
    1   Running queries are found

AUTHOR(S)

    Written by Dmitriy "DK" Korobskiy.
HEREDOC
  exit 1
}

set -e
set -o pipefail

# if a character is followed by a colon, the option is expected to have an argument
while getopts vh OPT; do
  case "$OPT" in
    v)
      readonly VERBOSE=true
      ;;
    *) # -h or `?`: an unknown option
      usage
      ;;
  esac
done
shift $((OPTIND - 1))
# Positional parameters
[[ $1 == "" ]] && usage
readonly POSTGRES_DB="$1"

[[ "${VERBOSE}" == true ]] && set -x

if ! command -v pcregrep >/dev/null; then
  echo "Please install pcregrep"
  exit 1
fi

echo "Checking active Postgres queries in the $POSTGRES_DB DB".

readonly QUERIES=$(
  # Avoid any directory permission warning
  cd /tmp
  # language=PostgresPLSQL
  sudo -u jenkins psql -v ON_ERROR_STOP=on "$POSTGRES_DB" << 'HEREDOC'
SELECT *
FROM pg_stat_activity
WHERE pid <> pg_backend_pid() and state <> 'idle' and usename != 'postgres';
HEREDOC
)

# Minus header and footer
declare -i QUERY_COUNT=$(pcregrep -o1 '^\((\d+) rows?\)$'<<< "$QUERIES")

if ((QUERY_COUNT > 0)); then
  cat <<HEREDOC
**Not in a quiet period.** The following $QUERY_COUNT non-system Postgres queries are running:
-----
HEREDOC
  printf '%s\n' "${QUERIES[@]}"
  echo "-----"
  exit 1
fi
echo "In a quiet period"

exit 0

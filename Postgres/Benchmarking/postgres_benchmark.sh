#!/usr/bin/env bash
if [[ "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    postgres_benchmark.sh -- run pgbench and extract tps (excluding connections establishing) into a CSV

SYNOPSIS

    postgres_benchmark.sh [--file=custom_pgbench_script] [benchmark_time_seconds] [simulated_clients]
    postgres_benchmark.sh -h: display this help

DESCRIPTION

    Run pgbench and extract tps (excluding connections establishing) into a CSV.
    Display progress every 20 seconds.

    The following options are available:

    --file                 Execute a custom pgbench script and extract TPS to `pgbench_custom.csv`.
                           The default is to execute built-in scripts and extract TPS to `pgbench_buitin.csv`.
    benchmark_time_seconds Run the test for this many seconds. Default is 10.
    simulated_clients      Number of clients simulated, that is, number of concurrent database sessions. Default is 5.

ENVIRONMENT

    # PGDATABASE/PGUSER, etc.: default Postgres connection parameters
    # pgbench must be installed on the system PATH. For example: `sudo ln -snfv /usr/pgsql*/bin/pgbench /usr/bin`.
    # pgbench must be initialized. For example, for 5 simulated clients: `pgbench -i -s 5`.
    # pcregrep must be installed.

AUTHOR(S)

    Written by Dmitriy "DK" Korobskiy.
HEREDOC
  exit 1
fi

set -e
set -o pipefail
#set -x

if ! command -v pgbench >/dev/null; then
  cat <<HEREDOC
pgbench is not found. Please add it to the system PATH. For example:

  $ sudo ln -snfv /usr/pgsql*/bin/pgbench /usr/bin
HEREDOC
  exit 2
fi

if ! command -v  pcregrep >/dev/null; then
  echo "pcregrep is not found. Please install it."
  exit 2
fi

if [[ $1 == --file=* ]]; then
  readonly CUSTOM_SCRIPT_OPTION="$1"
  readonly OUTPUT_CSV="pgbench_custom.csv"
  shift
else
  readonly OUTPUT_CSV="pgbench_buitin.csv"
fi

readonly BENCHMARK_TIME_SECONDS=${1:-10}
shift
readonly SIMULATED_CLIENTS=${1:-5}

echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##\n"

echo '"TPS (excluding connections establishing)"' >"$OUTPUT_CSV"
# Output progress to stdout and tee the extracted TPS into the output CSV
pgbench --client=${SIMULATED_CLIENTS} --time=${BENCHMARK_TIME_SECONDS} --progress=20 "${CUSTOM_SCRIPT_OPTION}" | \
  tee >(pcregrep -o1 'tps = ([\d.]+).*excluding connections' >>"$OUTPUT_CSV")

exit 0

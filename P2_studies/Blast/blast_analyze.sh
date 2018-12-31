#!/usr/bin/env bash
if [[ $# -lt 2 || "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    blast_analyze.sh -- do something

SYNOPSIS

    blast_analyze.sh start_year end_year [scale_factor]
    blast_analyze.sh -h: display this help

DESCRIPTION

    Generates data for BLAST analysis.

    The following options are available:

    start_year, end_year  range of dataset slices to generate (in parallel)

    scale_factor          Scale the number of publications in the comparison dataset relative to the analysis dataset.
                          Default = 1.0.

EXAMPLES

        $ blast_analyze.sh 1991

AUTHOR(S)

    Written by Dmitriy "DK" Korobskiy.
HEREDOC
  exit 1
fi

set -ex
set -o pipefail

# Get a script directory, same as by $(dirname $0)
script_dir=${0%/*}
absolute_script_dir=$(cd "${script_dir}" && pwd)

start_year=$1
end_year=$2
scale_factor=${3:-1.0}

work_dir=${absolute_script_dir}
cd "${work_dir}"
echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##\n"

parallel --halt soon,fail=1 --verbose --line-buffer --tagstring '|job#{#} s#{%}|' \
  'psql -f blast_analyze.sql -v year={} -v scale_factor=${scale_factor}' ::: $(seq ${start_year} ${end_year})

exit 0

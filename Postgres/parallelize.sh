#!/usr/bin/env bash
if [[ $# -lt 1 || "$1" == "-h" ]]; then
  cat << 'HEREDOC'
NAME

    parallelize.sh -- run statements from a sql script file in parallel

SYNOPSIS

    parallelize.sh script
    parallelize.sh -h: display this help

DESCRIPTION

    Runs all the statements in a sql script file in parallel.
    The script file should contain all the sql statements saperated by ';'
HEREDOC
  exit 1
fi

set -ex
set -o pipefail

grep "^[^--]" $1 |tr -s " \t\n" " "|tr -s " \t" " " |tr ";" "; " | parallel --halt soon,fail=1 --line-buffer \
    --tagstring '|job#{#} s#{%}|' -d '; ' psql -v ON_ERROR_STOP=on --echo-all -c "{};"
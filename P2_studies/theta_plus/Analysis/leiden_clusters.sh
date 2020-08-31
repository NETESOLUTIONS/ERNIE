#!/usr/bin/env bash

usage() {
  cat <<'HEREDOC'
NAME

    leiden_clusters.sh -- identify clusters (also known as communities) in a network, using Leiden algorithm

SYNOPSIS

    leiden_clusters.sh edges_CSV_with_headers cluster_TSV
    leiden_clusters.sh -h: display this help

DESCRIPTION

    Identify clusters (also known as communities) in a network, using Leiden algorithm with the default parameters.

AUTHOR(S)

    Created by Dmitriy "DK" Korobskiy, August 2020
HEREDOC
  exit 1
}

set -e
set -o pipefail

(( $# < 2 )) && usage
readonly INPUT_FILE=$1
readonly OUTPUT_FILE=$2

# Get a script directory, same as by $(dirname $0)
#readonly SCRIPT_DIR=${0%/*}
#readonly ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)

#readonly WORK_DIR=${1:-${ABSOLUTE_SCRIPT_DIR}/build} # $1 with the default
#if [[ ! -d "${WORK_DIR}" ]]; then
#  mkdir "${WORK_DIR}"
#  chmod g+w "${WORK_DIR}"
#fi
#cd "${WORK_DIR}"
echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##\n"

java -jar /usr/local/bin/RunNetworkClustering.jar -o "$OUTPUT_FILE" <(tail -n +2 "$INPUT_FILE" \
    | while IFS=',' read -r citing cited citing_index cited_index; do echo -e "$citing_index\t$cited_index"; done)

exit 0

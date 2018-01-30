#!/usr/bin/env bash
set -xe

# Get a script directory, same as by $(dirname $0)
script_dir=${0%/*}
${script_dir}/download_source_data.sh
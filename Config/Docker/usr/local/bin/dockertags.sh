#!/usr/bin/env bash
if [[ $# -lt 1 || "$1" == "-h" ]]; then
  cat << 'HEREDOC'
NAME

    dockertags.sh -- list all tags for a Docker image in the Docker Hub

SYNOPSIS

    dockertags.sh image
    dockertags.sh -h: display this help

DESCRIPTION

    List all tags for a Docker image in the Docker Hub sorted in the reverse numerical order.

EXAMPLES

    To list all tags for the ubuntu image:

        $ dockertags.sh ubuntu

AUTHOR(S)

    ForDoDone (see https://fordodone.com/2015/10/02/docker-get-list-of-tags-in-repository/)
    Dmitriy "DK" Korobskiy
HEREDOC
  exit 1
fi

#set -x
set -e
set -o pipefail

# Get a script directory, same as by $(dirname $0)
#script_dir=${0%/*}
#absolute_script_dir=$(cd "${script_dir}" && pwd)
#
#work_dir=${1:-${absolute_script_dir}/build} # $1 with the default
#if [[ ! -d "${work_dir}" ]]; then
#  mkdir "${work_dir}"
#  chmod g+w "${work_dir}"
#fi
#cd "${work_dir}"
#echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##\n"

image="$1"
# TBD Migrate to APIv2
# The example in https://gist.github.com/robv8r/fa66f5e0fdf001f425fe9facf2db6d49 using APIv2 breaks down on ubuntu
wget -q https://registry.hub.docker.com/v1/repositories/${image}/tags -O - | jq --raw-output '.[].name' | sort -nr

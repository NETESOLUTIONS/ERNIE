#!/usr/bin/env bash
if [[ $1 == "-h" ]]; then
  cat <<'HEREDOC'
NAME
  monitor_monit.sh -- checks monit for any disabled (unmonitored) services

SYNOPSIS
  monitor_monit.sh
  monitor_monit.sh -h: display this help

DESCRIPTION
  Requires sudoer permissions. sudo password can be supplied via stdin.
HEREDOC
  exit 1
fi

set -ex
set -o pipefail

# Get a script directory, same as by $(dirname $0)
script_dir=${0%/*}
absolute_script_dir=$(cd "${script_dir}" && pwd)
#work_dir=${1:-${absolute_script_dir}/build} # $1 with the default
#if [[ ! -d "${work_dir}" ]]; then
#  mkdir "${work_dir}"
#  chmod g+w "${work_dir}"
#fi
#cd "${work_dir}"
echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##\n"

declare -i unmonitored_services
unmonitored_services=$(sudo --stdin monit report unmonitored)
if (( unmonitored_services == 0 )); then
  echo "monit reports no unmonitored services"
  exit
fi
echo -e "monit reports ${unmonitored_services} unmonitored service(s):\n"
sudo --stdin monit status
exit 1
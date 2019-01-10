#!/usr/bin/env bash
if [[ "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    beautify.sh -- formats committed to Git SQL files via DataGrip CLI formatter according to the project code style

SYNOPSIS

    beautify.sh
    beautify.sh -h: display this help

DESCRIPTION

    Formats SQL files included in the last commit (if any) via DataGrip CLI formatter according to the project code style.
    Commits and pushes the updated files.

ENVIRONMENT
    The current directory must be a prohject directory.

    Required variables:

    GIT_COMMIT                      latest Git commit id
    GIT_PREVIOUS_SUCCESSFUL_COMMIT  previous Git commit id for determining delta of files to be formatted
    DATAGRIP_HOME                   DataGrip server installation directory

EXAMPLES

    To format:

        $ cd ERNIE
        $ beautify.sh
HEREDOC
  exit 1
fi

set -ex
set -o pipefail

# Get a script directory, same as by $(dirname $0)
script_dir=${0%/*}
absolute_script_dir=$(cd "${script_dir}" && pwd)

echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##\n"

if [[ ! ${GIT_COMMIT} ]]; then
  echo "GIT_COMMIT environment variable must be defined"
  exit 1
fi
if [[ ! ${GIT_PREVIOUS_SUCCESSFUL_COMMIT} ]]; then
  echo "GIT_PREVIOUS_SUCCESSFUL_COMMIT environment variable must be defined"
  exit 1
fi
if [[ ! ${DATAGRIP_HOME} ]]; then
  echo "DATAGRIP_HOME environment variable must be defined"
  exit 1
fi

readonly PROJECT_STYLE=.idea/codeStyles/Project.xml
if [[ ! -f ${PROJECT_STYLE} ]]; then
  echo "Could not find the project style in ${PROJECT_STYLE}"
  exit 1
fi

readonly PROJECT_DIR=$(pwd)
export PATH=$PATH:${DATAGRIP_HOME}/bin

git diff --diff-filter=ACMRTUXB ${GIT_PREVIOUS_SUCCESSFUL_COMMIT} ${GIT_COMMIT} --name-only | grep '\.sql$' | \
    tee /dev/stdout | xargs -I '{}' format.sh -s "${PROJECT_DIR}/.idea/codeStyles/Project.xml" {}

exit 0

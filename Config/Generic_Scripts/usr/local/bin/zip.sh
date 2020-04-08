#!/usr/bin/env bash
if [[ "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    zip.sh -- archive to a ZIP recursively using 500MB split archives

SYNOPSIS

    zip.sh [zip switch] [...] [dir or archive] [file] [...]
    zip.sh -h: display this help

DESCRIPTION

    Create or update an archive and sync contents (delete non-existent files).
    NOTE: Assumes that glob expansion will not exceed command lime limit.

    The following options are available:

    dir or archive      Target directory or ZIP name. ZIP name defaults to the current directory name when omitted.

    file ...            Defaults to '*' when omitted. File globs are matched using `dotglob`: including hidden files.

    zip switches        Passed through.

EXAMPLES

    To archive contents of the current directory to /tmp/curdir.zip

        /home/curdir$ zip.sh /tmp

AUTHOR(S)

    Written by Dmitriy "DK" Korobskiy.
HEREDOC
  exit 1
fi

set -e
set -o pipefail
#set -x

# Get a script directory, same as by $(dirname $0)
#readonly SCRIPT_DIR=${0%/*}
#readonly ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)

# Find first non-switch (not -*) option
while (( $# > 0 )); do
  case "$1" in
    -*)
      options="$options $1"
      ;;
    *)
      if [[ ${archive} ]]; then
        files="$files $1"
      else
        if [[ -d "$1" ]]; then
          target_dir="$1"
        else
          archive="$1"
        fi
      fi
      ;;
  esac
  shift
done

#readonly WORK_DIR=${1:-${ABSOLUTE_SCRIPT_DIR}/build} # $1 with the default
#if [[ ! -d "${WORK_DIR}" ]]; then
#  mkdir "${WORK_DIR}"
#  chmod g+w "${WORK_DIR}"
#fi
#cd "${WORK_DIR}"
shopt -s dotglob

if [[ ! ${archive} ]]; then
  # Remove longest */ prefix
  readonly dir_name_with_ext=${PWD##*/}
  if [[ ${target_dir} ]]; then
    archive="${target_dir}/${dir_name_with_ext}"
  else
    archive="${dir_name_with_ext}"
  fi
fi
[[ ${files} ]] || files='*'

echo -e "\n## ${PWD}> Archiving to ${archive}.zip ##\n"

# --filesync: synchronize archive contents (archive files not present in the list will be deleted from the archive)
# -r: recurse subdirectories
# --split-size <size>[k,b]: create volumes with size=<size>*1000 [*1024, *1]
# FIXME Convert to xargs
# shellcheck disable=SC2086
zip --filesync -r --split-size 500m ${options} ${archive} ${files}

command -v growlnotify && growlnotify "zip.sh" -m "Finished archiving ${archive}.zip"

exit 0
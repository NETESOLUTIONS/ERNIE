#!/usr/bin/env bash
if [[ "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    7z.sh -- archive to a .7z recursively using 100MB split volumes

SYNOPSIS

    7z.sh [-{option}] [...] [dir or archive] [file] [...]
    7z.sh -h: display this help

DESCRIPTION

    Create or update a .7z archive and sync contents (delete non-existent files).

    NOTE: Assumes that glob expansion will not exceed command lime limit.

    WARNING: 7-Zip does not store the owner/group of files. If you need to preserve them, use other options.

    The following options are available:

    dir or archive      Target directory or archive name (which defaults to the current directory name).
                        This name must not start with `-`.

    file ...            Defaults to '*' when omitted. File globs are matched using `dotglob`: including hidden files.

    -{option}           Passed through 7-Zip option. Added after `u -uq0 -v100m`.

EXAMPLES

    To archive contents of the current directory to `./curdir.7z` or `/tmp/curdir.7z.001, /tmp/curdir.7z.002, ...`:

        /home/curdir$ 7z.sh

    To archive contents of the current directory to `./foo.7z*`:

        /home/curdir$ 7z.sh foo

    To archive contents of the current directory to `/tmp/curdir.7z*`:

        /home/curdir$ 7z.sh /tmp

    To archive contents of the current directory to `./curdir.7z*` and delete source files:

        /home/curdir$ 7z.sh -sdel

AUTHOR(S)

    Written by Dmitriy "DK" Korobskiy.
HEREDOC
  exit 1
fi

set -e
set -o pipefail

declare -a options files
# Find first non-switch (not -*) option
while (( $# > 0 )); do
  case "$1" in
    -*)
      options+=("$1")
      ;;
    *)
      if [[ "${archive}" ]]; then
        files+=("$1")
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

# Get a script directory, same as by $(dirname $0)
readonly SCRIPT_DIR=${0%/*}
readonly ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)
# Remove longest */ prefix
readonly SCRIPT_NAME_WITH_EXT=${0##*/}
# Remove shortest .* suffix
readonly SCRIPT_NAME=${name_with_ext%.*}

shopt -s dotglob

if [[ ! ${archive} ]]; then
  # Default to directory name (with extension)
  # Remove longest */ prefix
  readonly archive_name=${PWD##*/}
  if [[ ${target_dir} ]]; then
    archive="${target_dir}/${archive_name}"
  else
    target_dir=.
    archive="${archive_name}"
  fi
fi
if (( ${#files[@]} == 0 )); then
  files=('*')
fi

echo -e "\n## ${PWD}> Archiving to ${archive}.7z.* ##\n"

# Since `-sdel` is supported for add only, determine the command to use based on existence of archive
if [[ -f ${archive} ]]; then
  # `-u` update options: `q` File exists in archive, but doesn't exist on disk + `0` don't create item in new archive
  readonly COMMAND_7ZIP="u -uq0"
else
  readonly COMMAND_7ZIP="a"
fi

# shellcheck disable=SC2086 # Expansions should be unquoted to split them into multiple arguments
7za ${COMMAND_7ZIP} -v100m ${options[*]} ${archive} ${files[*]}

# Volumes are named .7z.001, .7z.002, ...
# If there is a single volume at the end, rename it to .7z
if [[ ! -s ${archive}.7z.002 ]]; then
  mv "${archive}.7z.001" "${target_dir}/${archive_name}.7z"
fi

command -v growlnotify >/dev/null && growlnotify "$SCRIPT_NAME" -m "Finished archiving ${archive}.zip"

exit 0
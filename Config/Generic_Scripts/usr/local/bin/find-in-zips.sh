#!/usr/bin/env bash
while (( $# > 0 )); do
  case "$1" in
    -h) break;;
    -u)
      shift
      if [[ -d $1 ]]; then
        readonly UNZIP_DIR="$1"
      else
        readonly UNZIP_DIR="."
        break
      fi
      ;;
    *)
      break
  esac
  shift
done

if [[ $# -lt 2 || "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    find-in-zips.sh -- find file(s) anywhere in ZIP(s), optionally unzip and exit on the first match

SYNOPSIS

    find-in-zips.sh [-u [{dir}]] {zip_file} [{zip_file}...] {file_name_or_glob}
    find-in-zips.sh -h: display this help

DESCRIPTION

    Find `file_name_or_glob` file(s) anywhere in a ZIP. The following options are available:

    -u    Extract found file(s) to a destination directory (./ by default) flatly (with no paths)

EXIT STATUS

    The find-in-zips.sh utility exits with one of the following values:

    0   Not found
    255 Found

EXAMPLES

    To find a file by name anywhere in a ZIP:

        $ find-in-zips.sh 2018-eids-from-1050001-to-1060000.zip 2-s2.0-85046115839.xml

    To find a file by a glob anywhere in all ZIPs in the current directory:

        $ find-in-zips.sh *.zip '2-s2.0-85046115839.*'

    To find a file by a glob in ZIPs recursively (or in a large number of):

        $ find . -name *.zip -print0 | xargs -0 -I{} find-in-zips.sh {} '2-s2.0-85046115839.*'

    To find a file by a glob anywhere in ZIPs and unzip into the current directory:

        $ find-in-zips.sh -u *.zip '*85046115839.xml'

    To find multiple globs and extract matches into `~/inbox/`:

        $ for f in 33746539903 33749371923 34547692041 77952490155; do
            find-in-zips.sh -u ~/inbox *.zip "*$f.xml"
          done

AUTHOR(S)

    Written by Dmitriy "DK" Korobskiy.
HEREDOC
  exit 1
fi

set -e
set -o pipefail
#set -x

readonly args=("$@")
readonly argc=${#args[@]}
# last argument
readonly FILE_NAME_OR_GLOB="${args[$argc-1]}"

# Process all arguments except last
while [[ $# -gt 1 ]]; do
  # zipinfo uses glob patterns to match files.
  # `${FILE_NAME_OR_GLOB}` would match file(s) in the root dir.
  # `*/${FILE_NAME_OR_GLOB}` would match file(s) in any sub-dir.
  if zipinfo -h "$1" "${FILE_NAME_OR_GLOB}" "*/${FILE_NAME_OR_GLOB}" 2>/dev/null; then
    echo -e "\nFound '${FILE_NAME_OR_GLOB}' in '$1'."
    if [[ $UNZIP_DIR ]]; then
      # -u Update existing files
      # -j junk paths
      unzip -u -j "$1" "${FILE_NAME_OR_GLOB}" "*/${FILE_NAME_OR_GLOB}" -d "$UNZIP_DIR" 2>/dev/null
    fi
    exit 255
  fi
  shift
done
echo -e "\nNot found: '${FILE_NAME_OR_GLOB}'."

exit 0

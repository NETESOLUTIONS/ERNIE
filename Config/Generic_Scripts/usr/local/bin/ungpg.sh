#!/usr/bin/env bash
if [[ $# -lt 1 || "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    ungpg.sh -- decrypt symmetrically encrypted *.gpg-s in parallel

SYNOPSIS

    ungpg.sh [-d] passphrase [file] ...
    ungpg.sh -h: display this help

DESCRIPTION

    Decrypt either the specified files or all files found under the current directory (`**/*.gpg`).
    Output to a file with a stripped .gpg extension. Skips decryption for a particular .gpg if an output file exists.

    The following options are available:

    -d    remove the original file after successful decryption

ENVIRONMENT

    Pre-requisite: GNU Parallel must be installed
HEREDOC
  exit 1
fi

set -e
#set -ex
set -o pipefail

if ! which parallel >/dev/null; then
  echo "Please install GNU Parallel"
  exit 1
fi

if [[ "$1" == "-d" ]]; then
  declare -rx DELETE_ORIGINALS=true
  shift
fi
declare -rx PASS_PHRASE="$1"
shift

decrypt_gpg() {
  set -e
#  set -ex
  set -o pipefail

  file="$1"
  # Remove shortest .gpg suffix
  file_without_gpg_ext=${file%.gpg}
  if [[ -f "${file_without_gpg_ext}" ]]; then
    echo "Skipping existing output file ${file_without_gpg_ext}"
  else
    echo "Decrypting ${file} ..."
    gpg --batch --passphrase "${PASS_PHRASE}" --output "${file_without_gpg_ext}" --decrypt "${file}"
    if [[ "${DELETE_ORIGINALS}" == true ]]; then
      rm -fv "${file}"
    fi
  fi
}
export -f decrypt_gpg

if (( $# > 0 )); then
  parallel --halt soon,fail=1 --line-buffer --tagstring '|job#{#} s#{%}|' 'decrypt_gpg {}' ::: "$@"
  #--verbose
else
  find . -name '*.gpg' -type f -print0 | \
      parallel -0 --halt soon,fail=1 --line-buffer --tagstring '|job#{#} s#{%}|' 'decrypt_gpg {}'
fi
echo -e "\nSuccess"

exit 0

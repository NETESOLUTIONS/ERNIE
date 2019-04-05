#!/usr/bin/env bash
if [[ $# -lt 1 || "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    unarc.sh -- extract files from the tarball(s)

SYNOPSIS

    unarc.sh tarball ... [destination_dir]
    unarc.sh -h: display this help

DESCRIPTION

    Extract files from the tarball file(s) into the destination directory ({TAR dir}/{TAR name}/ by default)
HEREDOC
  exit 1
fi

args=( "$@" )
argc=${#args[@]}
last_arg="${args[$argc-1]}"
if [[ ! -f "$last_arg" ]]; then
  dest_dir="$last_arg"
  ((argc = argc - 1))
fi

for (( i=0; i < ${argc}; i++ )); do
  file=${args[$i]}
  name_with_ext=${file##*/}
  [[ "$file" != */* ]] && file_spec=./${file} || file_spec=${file}
  dir=${dest_dir:-${file_spec%/*}/${name_with_ext%%.*}/}
  [[ ! -d "$dir" ]] && mkdir "$dir"
  echo "Extracting $file ==> $dir"
  tar -xvf "$file" -C "$dir"
  echo
done

exit 0

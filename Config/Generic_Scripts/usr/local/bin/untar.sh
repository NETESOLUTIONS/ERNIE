#!/usr/bin/env bash
if [[ $# -lt 1 || "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    untar.sh -- extract files from the tarball(s)

SYNOPSIS

    untar.sh tarball ... [destination_dir]
    untar.sh -h: display this help

DESCRIPTION

    Extract files from the tarball file(s) into the destination directory.
    The destination defaults to `{TAR dir}/{TAR name}/`, {TAR name}=tarball name without the last extension (e.g. '.gz')
HEREDOC
  exit 1
fi

readonly args=( "$@" )
argc=${#args[@]}
readonly last_arg="${args[$argc-1]}"
if [[ ! -f "$last_arg" ]]; then
  # The last argument does not represent an existing tarball
  readonly dest_dir="$last_arg"
  ((argc = argc - 1))
  readonly argc
fi

for (( i=0; i < ${argc}; i++ )); do
  file=${args[$i]}
  name_with_ext=${file##*/}
  [[ "$file" != */* ]] && file_spec=./${file} || file_spec=${file}
  if [[ ${dest_dir} ]]; then
    dir=${dest_dir}
  else
    dir=${name_with_ext%.*}
    dir=${file_spec%/*}/${dir//.tar/}
  fi
  [[ ! -d "$dir" ]] && mkdir "$dir"
  echo "Extracting $file ==> $dir"
  tar -xvf "$file" -C "$dir"
  echo
done

exit 0

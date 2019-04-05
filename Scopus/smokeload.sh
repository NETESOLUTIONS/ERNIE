#!/usr/bin/env bash
if [[ $1 == "-h" ]]; then
  cat <<'HEREDOC'
NAME

  smokeload.sh -- smokeload baseline of Scopus data directories of the zipped (*.zip) Scopus XMLs

SYNOPSIS

  smokeload.sh [-c] [-r] data_directory [...]
  smokeload.sh -h: display this help

DESCRIPTION

  This script is largely based on the PARDI DWPI smokeload script.

  The script processes specified directories in alphabetical or reverse order.
  The process upserts data and automatically resumes on failures.

  If you need to stop process gracefully after the current directory is processed, create `./.stop` file.

  The following options are available:

    -c    clean data before processing and don't resume processing. WARNING: be aware that you'll lose all loaded data!
    -r    reverse order of processing

EXAMPLES

  Process 2000-20XX data directories

      smokeload.sh 20??

  Process all 20XX data directories in a reverse order

      smokeload.sh -r /erniedev_data1/Scopus/20??
HEREDOC
  exit 1
fi

#set -e
set -ex
set -o pipefail

STOP_FILE=".stop"
# Get a script directory, same as by $(dirname $0)
script_dir=${0%/*}
absolute_script_dir=$(cd "${script_dir}" && pwd)

while (( $# > 0 )); do
  case "$1" in
    -c)
      clean_mode="-nr";;
    -r)
      sort_order="--reverse";;
    *)
      break
  esac
  shift
done
arg_array=( "$@" )
# Courtesy of https://stackoverflow.com/questions/7442417/how-to-sort-an-array-in-bash
IFS=$'\n' sorted_args=($(sort ${sort_order} <<<"${arg_array[*]}")); unset IFS

echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##\n"
echo -e "Data directories to process:\n${sorted_args[@]}"

rm -f eta.log
declare -i process_start_time directories i=0 start_time stop_time delta delta_s delta_m della_h elapsed=0 est_total eta
directories=${#sorted_args[@]}
for dir in "${sorted_args[@]}"; do
  start_time=$(date '+%s')
  if [[ -d "${dir}/tmp"  && ! ${clean_mode} ]]; then
    resume_mode=" (resumed)"
    # Don't count partial directory
    ((directories--))
  else
    unset resume_mode
    process_start_time=${start_time}
    echo -e "\n## Directory #$((++i)) out of ${directories} ##"
  fi
  echo "Processing${resume_mode} ${dir} directory ..."
  # TODO: have option to pass c as option and specify clean mode
  #"${absolute_script_dir}/process_directory.sh" ${clean_mode} "${dir}"
  sleep 2
  stop_time=$(date '+%s')

  ((delta=stop_time - start_time)) || :
  ((delta_s=delta % 60)) || :
  ((delta_m=(delta / 60) % 60)) || :
  ((della_h=delta / 3600)) || :
  printf "\n$(TZ=America/New_York date) Done with ${dir} data directory in %dh:%02dm:%02ds${resume_mode}\n" ${della_h} \
         ${delta_m} ${delta_s} | tee -a eta.log
  if [[ -f "${STOP_FILE}" ]]; then
    echo "Found the stop signal file. Gracefully stopping..."
    rm -f "${STOP_FILE}"
    break
  fi
  if [[ ! ${resume_mode} ]]; then
    echo "elapsed is : ${elapsed} | delta is : ${delta}"
    ((elapsed=elapsed + delta))
    ((est_total=directories * elapsed / i)) || :
    ((eta=process_start_time + est_total))
    echo "ETA after ${dir} data directory: $(TZ=America/New_York date --date=@${eta})" | tee -a eta.log
  fi
done

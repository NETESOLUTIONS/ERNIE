#!/usr/bin/env bash
if [[ $1 == "-h" ]]; then
  cat <<'HEREDOC'
NAME

  update.sh -- update Scopus data in a PostgreSQL database with zipped (*.zip) Scopus XMLs delivered by the provider
  Note that clean mode is NOT available with this script.

SYNOPSIS

  update.sh [-r] [-s subset_SP] data_directory [...]
  update.sh -h: display this help

DESCRIPTION

  Process specified zip files in alphabetical or reverse order.
  TODO: automatically skip processing of files based on a finished_filelist.txt file. Copy files from some secondary storing location and then proceed to work on them.
  data_directory could be an absolute or relative to the working directory location.

  The following options are available:

    -r    reverse order of processing

    -s subset_SP: parse a subset of data via the specified subset parsing Stored Procedure (SP)

  To stop process gracefully after the current ZIP is processed, create a `{working_dir}/.stop` signal file.
  This file is automatically removed

EXAMPLES

  Process all available ZIP data in a reverse order:

      update.sh -r /erniedev_data1/Scopus_custom_data/*ITEM-full-format-xml.zip
HEREDOC
  exit 1
fi

set -e
set -o pipefail
#set -x

readonly STOP_FILE=".stop"
# Get a script directory, same as by $(dirname $0)
readonly SCRIPT_DIR=${0%/*}
readonly ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)
readonly FAILED_FILES_DIR=../failed

while (( $# > 0 )); do
  case "$1" in
    -r)
      readonly SORT_ORDER="--reverse"
      ;;
    -s)
      shift
      readonly SUBSET_OPTION="-s $1"
      ;;
    *)
      break
  esac
  shift
done
arg_array=( "$@" )
echo "${arg_array[*]}"
# Courtesy of https://stackoverflow.com/questions/7442417/how-to-sort-an-array-in-bash
IFS=$'\n' sorted_args=($(sort ${SORT_ORDER} <<<"${arg_array[*]}")); unset IFS

echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##\n"
echo -e "Zip files to process:\n${sorted_args[@]}"

rm -f eta.log
declare -i files=${#sorted_args[@]} i=0 start_time file_start_time file_stop_time delta delta_s delta_m della_h \
    elapsed=0 est_total eta
for ZIP_DATA in "${sorted_args[@]}"; do
  file_start_time=$(date '+%s')
  (( i == 0 )) && start_time=${file_start_time}
  echo -e "\n## Zip file #$((++i)) out of ${files} ##"
  echo "Unzipping ${ZIP_DATA} file into a working directory ..."
  DATA_DIR="${ZIP_DATA%.zip}"
  unzip -u -q "${ZIP_DATA}" -d "${DATA_DIR}"

  #echo "Processing ${DATA_DIR} directory ..."
  #if ! "${ABSOLUTE_SCRIPT_DIR}/process_directory.sh" -f "${FAILED_FILES_DIR}" ${SUBSET_OPTION} "${DATA_DIR}"; then
  #  failures_occurred="true"
  #fi
  file_stop_time=$(date '+%s')

  ((delta=file_stop_time - file_start_time + 1)) || :
  ((delta_s=delta % 60)) || :
  ((delta_m=(delta / 60) % 60)) || :
  ((della_h=delta / 3600)) || :
  printf "\n$(TZ=America/New_York date) Done with ${ZIP_DATA} data file in %dh:%02dm:%02ds\n" ${della_h} \
         ${delta_m} ${delta_s} | tee -a eta.log
  if [[ -f "${ZIP_DATA}/${STOP_FILE}" ]]; then
    echo "Found the stop signal file. Gracefully stopping the update..."
    rm -f "${ZIP_DATA}/${STOP_FILE}"
    break
  fi

  ((elapsed=elapsed + delta))
  ((est_total=elapsed * files / i)) || :
  ((eta=start_time + est_total))
  echo "ETA after ${ZIP_DATA} data file: $(TZ=America/New_York date --date=@${eta})" | tee -a eta.log
done

[[ "${failures_occurred}" == "true" ]] && exit 1
exit 0

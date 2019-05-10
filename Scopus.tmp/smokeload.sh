#!/usr/bin/env bash
if [[ $1 == "-h" ]]; then
  cat <<'HEREDOC'
NAME

  smokeload.sh -- smokeload baseline of Scopus data directories of the zipped (*.zip) Scopus XMLs

SYNOPSIS

  smokeload.sh [-c] [-r] [-s SP_name] data_directory [...]
  smokeload.sh -h: display this help

DESCRIPTION

  Process specified directories in alphabetical or reverse order.
  data_directory could be an absolute or relative to the working directory location.

  To stop process gracefully after the data_directory is processed, create a `{data_directory}/.stop` signal file.

  The following options are available:

    -c    clean data and previous failures before processing
    WARNING: be extra cautious! You'll lose all loaded data.

    -r    reverse order of processing

    -s    parse a subset of data via the specified subset parsing Stored Procedure (SP)
EXAMPLES

  Process all 20XX data directories in a reverse order:

      smokeload.sh -r /erniedev_data1/Scopus/20??
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
    -c)
      readonly CLEAN_MODE="true"
      ;;
    -r)
      readonly SORT_ORDER="--reverse"
      ;;
    -s)
      shift
      readonly SUBSET_OPTION=-s $1
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
echo -e "Data directories to process:\n${sorted_args[@]}"

if [[ ${CLEAN_MODE} == "true" ]]; then
  echo "IN CLEAN MODE. TRUNCATING ALL DATA..."
  psql -f ${ABSOLUTE_SCRIPT_DIR}/clean_data.sql

  cd ${sorted_args[0]}
  rm -rf "${FAILED_FILES_DIR}"
fi

rm -f eta.log
declare -i directories=${#sorted_args[@]} i=0 start_time dir_start_time dir_stop_time delta delta_s delta_m della_h \
    elapsed=0 est_total eta
for DATA_DIR in "${sorted_args[@]}"; do
  dir_start_time=$(date '+%s')
  (( i == 0 )) && start_time=${dir_start_time}
  echo -e "\n## Directory #$((++i)) out of ${directories} ##"
  echo "Processing ${DATA_DIR} directory ..."
  if ! "${ABSOLUTE_SCRIPT_DIR}/process_directory.sh" -f "${FAILED_FILES_DIR}" ${SUBSET_OPTION} "${DATA_DIR}"; then
    failures_occurred="true"
  fi
  dir_stop_time=$(date '+%s')

  ((delta=dir_stop_time - dir_start_time + 1)) || :
  ((delta_s=delta % 60)) || :
  ((delta_m=(delta / 60) % 60)) || :
  ((della_h=delta / 3600)) || :
  printf "\n$(TZ=America/New_York date) Done with ${DATA_DIR} data directory in %dh:%02dm:%02ds\n" ${della_h} \
         ${delta_m} ${delta_s} | tee -a eta.log
  if [[ -f "${STOP_FILE}" ]]; then
    echo "Found the stop signal file. Gracefully stopping..."
#    rm -f "${STOP_FILE}"
    break
  fi

#  echo "elapsed is : ${elapsed} | delta is : ${delta}"
  ((elapsed=elapsed + delta))
  ((est_total=elapsed * directories / i)) || :
  ((eta=start_time + est_total))
  echo "ETA after ${DATA_DIR} data directory: $(TZ=America/New_York date --date=@${eta})" | tee -a eta.log
done

[[ "${failures_occurred}" == "true" ]] && exit 1
exit 0

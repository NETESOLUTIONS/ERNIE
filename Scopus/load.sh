#!/usr/bin/env bash
declare -ri FATAL_FAILURE_CODE=255
if [[ $1 == "-h" ]]; then
  cat << 'HEREDOC'
NAME

  load.sh -- Smokeload or update Scopus data

SYNOPSIS
  load.sh -k [common_option] ... data_directory [...]
  load.sh -u [-rep] [common_option] ... data_directory [...]
  load.sh -h: display this help

DESCRIPTION

  The following processing modes are available:

    -k                smokeload using Scopus publication ZIPs in all specified data directories

    -u                update using Scopus update packages (super-ZIPs) in all specified data directories

      -rep            reprocess previously successfully completed publication ZIPs

  Common options:

    -r                reverse order of processing

    -c                clean load: truncate data. WARNING: be aware that you'll lose all loaded data!

    -s subset_SP      parse a subset of data via the specified parsing Stored Procedure (SP)

    -e max_errors     stop when the error number per a directory or an update super-ZIP reaches this threshold
                      101 by default.

    -v                verbose output: print processed XML files

    -v -v             extra-verbose output: print all lines (`set -x`)

    -n parallel_jobs  maximum number of jobs to run in parallel, # of CPU cores by default

    -t tmp_dir        `tmp` or `tmp-{SP_name}` (for subsets) by default
                      WARNING: be aware that `{tmp_dir}` is removed on success.

    -f failed_pub_dir move failed publication XML files to `{failed_pub_dir}/{pub_ZIP_name}/`, `../failed` by default
                      WARNING: be aware that `failed_pub_dir` is cleaned before processing.

  To stop process gracefully after the current ZIP is processed, create a `{working_dir}/.stop` signal file.
  This file is automatically removed

ENVIRONMENT

    * PGHOST/PGDATABASE/PGUSER  default Postgres connection parameters

EXIT STATUS

    Exits with one of the following values:

    0    Success
    1    An error occurred
    255  Maximum number of errors reached / fatal failure

HEREDOC
  exit $FATAL_FAILURE_CODE
fi

set -e
set -o pipefail
# Initially off: is turned on by `-v -v`
set +x

readonly STOP_FILE=".stop"
# Get a script directory, same as by $(dirname $0)
readonly SCRIPT_DIR=${0%/*}
readonly ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)
readonly FAILED_FILES_DIR=../failed
declare NUM_JOBS=8

while (($# > 0)); do
  case "$1" in
    -k)
      readonly MODE="SMOKELOAD"
      ;;
    -u)
      readonly MODE="UPDATE"
      ;;
    -rep)
      readonly REPROCESS_OPTION=$1
      ;;
    -r)
      readonly SORT_ORDER=true
      ;;
    -c)
      readonly CLEAN_MODE_OPTION=$1
      ;;
    -s)
      readonly SUBSET_OPTION="$1 $2"
      shift
      ;;
    -e)
      readonly MAX_ERRORS_OPTION="$1 $2"
      shift
      ;;
    -v)
      # Second "-v" = extra verbose?
      if [[ "$VERBOSE" == "true" ]]; then
        set -x
        VERBOSE_OPTION="-v -v"
      else
        readonly VERBOSE=true
        VERBOSE_OPTION="-v"
      fi
      ;;
    -n)
      PARALLEL_JOBSLOTS_OPTION="$1 $2"
      shift
      ;;
    *)
      break
      ;;
  esac
  shift
done

if [[ "${CLEAN_MODE_OPTION}" ]]; then
  echo "IN CLEAN MODE. TRUNCATING ALL DATA..."
  psql -f ${ABSOLUTE_SCRIPT_DIR}/clean_data.sql
  cd ${sorted_args[0]}
  rm -rf "${FAILED_FILES_DIR}"
fi

arg_array=("$@")
echo "${arg_array[*]}"
# Courtesy of https://stackoverflow.com/questions/7442417/how-to-sort-an-array-in-bash
IFS=$'\n' sorted_args=($(sort ${SORT_ORDER} <<< "${arg_array[*]}"))
unset IFS

echo "${MODE} JOB"

for DATA_DIR in "${sorted_args[@]}"; do
  if [[ "${MODE}" == "smokeload" ]]; then
    dir_start_time=$(date '+%s')
    ((i == 0)) && start_time=${dir_start_time}
    echo -e "\n## Directory #$((++i)) out of ${directories} ##"
    echo "Processing ${DATA_DIR} directory ..."
    "${ABSOLUTE_SCRIPT_DIR}/process_pub_zips.sh" ${MAX_ERRORS_OPTION} \
        ${PARALLEL_JOBSLOTS_OPTION} ${SUBSET_OPTION} ${VERBOSE_OPTION} -f "${FAILED_FILES_DIR}" "${DATA_DIR}"
    declare -i result_code=$?
    if ((result_code > 0)); then
      # Faial error?
      ((result_code == FATAL_FAILURE_CODE)) && exit $FATAL_FAILURE_CODE

      failures_occurred="true"
    fi
    dir_stop_time=$(date '+%s')

    ((delta = dir_stop_time - dir_start_time + 1)) || :
    ((delta_s = delta % 60)) || :
    ((delta_m = (delta / 60) % 60)) || :
    ((della_h = delta / 3600)) || :
    printf "\n$(TZ=America/New_York date) Done with ${DATA_DIR} data directory in %dh:%02dm:%02ds\n" ${della_h} \
    ${delta_m} ${delta_s} | tee -a eta.log
    if [[ -f "${DATA_DIR}/${STOP_FILE}" ]]; then
      echo "Found the stop signal file. Gracefully stopping the smokeload..."
      rm -f "${DATA_DIR}/${STOP_FILE}"
      break
    fi
    ((elapsed = elapsed + delta))
    ((est_total = elapsed * directories / i)) || :
    ((eta = start_time + est_total))
    echo "ETA after ${DATA_DIR} data directory: $(TZ=America/New_York date --date=@${eta})" | tee -a eta.log
  else
    readonly PROCESSED_LOG="${DATA_DIR}/processed.log"
    [[ "${CLEAN_MODE_OPTION}" ]] && rm -rf "${PROCESSED_LOG}"

    echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##\n"
    echo -e "Update packages to process:\n$(ls ${DATA_DIR}/*.zip)"
    rm -f eta.log
    declare -i files=$(ls "${DATA_DIR}"/*ANI-ITEM-full-format-xml.zip | wc -l) i=0
    declare -i start_time file_start_time file_stop_time delta delta_s delta_m della_h elapsed=0 est_total eta
    declare -i directories=${#sorted_args[@]} i=0 start_time dir_start_time dir_stop_time delta delta_s delta_m della_h \
    elapsed=0 est_total eta

    for ZIP_DATA in "${DATA_DIR}"/*ANI-ITEM-full-format-xml.zip; do
      file_start_time=$(date '+%s')
      ((i == 0)) && start_time=${file_start_time}
      echo -e "\n## Update package #$((++i)) out of ${files} ##"
      echo "Extracting ${ZIP_DATA} ..."
      UPDATE_DIR="${ZIP_DATA%.zip}"
      unzip -u -q "${ZIP_DATA}" -d "${UPDATE_DIR}"

      echo "Processing ${UPDATE_DIR} directory"
      # shellcheck disable=SC2086
      #   SUBSET_OPTION must be unquoted
      set +e
      "${ABSOLUTE_SCRIPT_DIR}/process_pub_zips.sh" -l "${PROCESSED_LOG}" ${REPROCESS_OPTION} ${MAX_ERRORS_OPTION} \
          ${PARALLEL_JOBSLOTS_OPTION} ${SUBSET_OPTION} ${VERBOSE_OPTION} -f "${FAILED_FILES_DIR}" "${UPDATE_DIR}"
      declare -i result_code=$?
      set -e
      if ((result_code == 0)); then
        echo "Removing directory ${UPDATE_DIR}"
        rm -rf "${UPDATE_DIR}"
      else
        # Faial error?
        ((result_code == FATAL_FAILURE_CODE)) && exit $FATAL_FAILURE_CODE

        failures_occurred="true"
      fi
      file_stop_time=$(date '+%s')

      ((delta = file_stop_time - file_start_time + 1)) || :
      ((delta_s = delta % 60)) || :
      ((delta_m = (delta / 60) % 60)) || :
      ((della_h = delta / 3600)) || :

      printf "\n$(TZ=America/New_York date) Done with ${ZIP_DATA} package in %dh:%02dm:%02ds\n" ${della_h} \ ${delta_m} ${delta_s} | tee -a eta.log
      if [[ -f "${ZIP_DATA}/${STOP_FILE}" ]]; then
        echo "Found the stop signal file. Gracefully stopping the update."
        rm -f "${ZIP_DATA}/${STOP_FILE}"
        break
      fi

      ((elapsed = elapsed + delta))
      ((est_total = elapsed * files / i)) || :
      ((eta = start_time + est_total))

      echo "ETA for updates after ${ZIP_DATA} package: $(TZ=America/New_York date --date=@${eta})" | tee -a eta.log
    done
    psql -f "${ABSOLUTE_SCRIPT_DIR}/scopus_update_log.sql"

    # Do delete files exist?
    if compgen -G "$DATA_DIR/*ANI-ITEM-delete.zip" > /dev/null; then
      echo -e "\nMain update process completed. Processing delete files.\n"
      declare -i num_deletes=$(ls "$DATA_DIR"/*ANI-ITEM-delete.zip | wc -l) i=0
      for ZIP_DATA in $(
        cd $DATA_DIR
        ls *ANI-ITEM-delete.zip
      ); do
        if grep -q "^${ZIP_DATA}$" "${PROCESSED_LOG}"; then
          echo "Skipping file ${ZIP_DATA} ( .zip file #$((++i)) out of ${num_deletes} ). It is already marked as completed."
        else
          echo -e "\nProcessing delete file ${ZIP_DATA} ( .zip file #$((++i)) out of ${num_deletes} )..."
          unzip ${DATA_DIR}/${ZIP_DATA}
          psql -f "${ABSOLUTE_SCRIPT_DIR}/process_deletes.sql"
          rm delete.txt
          echo "${ZIP_DATA}" >> ${PROCESSED_LOG}
          echo "Delete file ${ZIP_DATA} processed."
        fi
      done
    fi
  fi
done

# language=PostgresPLSQL
psql -v ON_ERROR_STOP=on --echo-all << 'HEREDOC'
SELECT *
FROM update_log_scopus
ORDER BY id DESC
LIMIT 10;
HEREDOC

if [[ "${failures_occurred}" == "true" ]]; then
  exit 1
fi

exit 0

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

arg_array=("$@")
echo "${arg_array[*]}"
# Courtesy of https://stackoverflow.com/questions/7442417/how-to-sort-an-array-in-bash
IFS=$'\n' SORTED_ARGS=($(sort ${SORT_ORDER} <<< "${arg_array[*]}"))
unset IFS

echo "${MODE} JOB"

if [[ "${CLEAN_MODE_OPTION}" ]]; then
  echo "IN CLEAN MODE. TRUNCATING ALL DATA..."
  psql -f "${ABSOLUTE_SCRIPT_DIR}/clean_data.sql"
  cd "${SORTED_ARGS[0]}"
  rm -rf "${FAILED_FILES_DIR}"
fi

for data_dir in "${SORTED_ARGS[@]}"; do
  if [[ "${MODE}" == "smokeload" ]]; then
    dir_start_time=$(date '+%s')
    ((i == 0)) && start_time=${dir_start_time}
    echo -e "\n## Directory #$((++i)) out of ${directories} ##"
    echo "Processing ${data_dir} directory ..."
    # shellcheck disable=SC2086
    "${ABSOLUTE_SCRIPT_DIR}/process_pub_zips.sh" ${MAX_ERRORS_OPTION} \
        ${PARALLEL_JOBSLOTS_OPTION} ${SUBSET_OPTION} ${VERBOSE_OPTION} -f "${FAILED_FILES_DIR}" "${data_dir}"
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
    printf "\n$(TZ=America/New_York date) Done with ${data_dir} data directory in %dh:%02dm:%02ds\n" ${della_h} \
    ${delta_m} ${delta_s} | tee -a eta.log
    if [[ -f "${data_dir}/${STOP_FILE}" ]]; then
      echo "Found the stop signal file. Gracefully stopping the smokeload..."
      rm -f "${data_dir}/${STOP_FILE}"
      break
    fi
    ((elapsed = elapsed + delta))
    ((est_total = elapsed * directories / i)) || :
    ((eta = start_time + est_total))
    echo "ETA after ${data_dir} data directory: $(TZ=America/New_York date --date=@${eta})" | tee -a eta.log
  else
    echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##\n"
    echo -e "Update and delete packages to process:"
    ls "${data_dir}"/*.zip

    processed_log="${data_dir}/processed.log"
    [[ "${CLEAN_MODE_OPTION}" ]] && rm -rf "${processed_log}"
    processed_archive_dir="${data_dir}/processed"
    if [[ ! -d "${processed_archive_dir}" ]]; then
      mkdir "${processed_archive_dir}"
      chmod g+w "${processed_archive_dir}"
    fi

    rm -f eta.log
    declare -i files=$(ls "${data_dir}"/*ANI-ITEM-full-format-xml.zip | wc -l) i=0
    declare -i start_time file_start_time file_stop_time delta delta_s delta_m della_h elapsed=0 est_total eta
    declare -i directories=${#SORTED_ARGS[@]} i=0 start_time dir_start_time dir_stop_time delta delta_s delta_m della_h \
    elapsed=0 est_total eta

    for zip_data in "${data_dir}"/*ANI-ITEM-full-format-xml.zip; do
      file_start_time=$(date '+%s')
      ((i == 0)) && start_time=${file_start_time}
      echo -e "\n## Update package #$((++i)) out of ${files} ##"
      echo "Extracting ${zip_data} ..."
      UPDATE_DIR="${zip_data%.zip}"
      unzip -u -q "${zip_data}" -d "${UPDATE_DIR}"

      echo "Processing ${UPDATE_DIR} directory"
      set +e
      # shellcheck disable=SC2086
      "${ABSOLUTE_SCRIPT_DIR}/process_pub_zips.sh" -l "${processed_log}" ${REPROCESS_OPTION} ${MAX_ERRORS_OPTION} \
          ${PARALLEL_JOBSLOTS_OPTION} ${SUBSET_OPTION} ${VERBOSE_OPTION} -f "${FAILED_FILES_DIR}" "${UPDATE_DIR}"
      declare -i result_code=$?
      set -e
      if ((result_code == 0)); then
        echo "Removing directory ${UPDATE_DIR}"
        rm -rf "${UPDATE_DIR}"
        mv -v "${zip_data}" "${processed_archive_dir}"
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

      printf "\n$(TZ=America/New_York date) Done with ${zip_data} package in %dh:%02dm:%02ds\n" ${della_h} \ ${delta_m} ${delta_s} | tee -a eta.log
      if [[ -f "${zip_data}/${STOP_FILE}" ]]; then
        echo "Found the stop signal file. Gracefully stopping the update."
        rm -f "${zip_data}/${STOP_FILE}"
        break
      fi

      ((elapsed = elapsed + delta))
      ((est_total = elapsed * files / i)) || :
      ((eta = start_time + est_total))

      echo "ETA for updates after ${zip_data} package: $(TZ=America/New_York date --date=@${eta})" | tee -a eta.log
    done
    psql -f "${ABSOLUTE_SCRIPT_DIR}/scopus_update_log.sql"

    # Do delete files exist?
    if compgen -G "$data_dir/*ANI-ITEM-delete.zip" > /dev/null; then
      echo -e "\nMain update process completed. Processing delete packages.\n"
      declare -i num_delete_files=$(ls "$data_dir"/*ANI-ITEM-delete.zip | wc -l) i=0
      for zip_data in "$data_dir"/*ANI-ITEM-delete.zip; do
        # Remove longest */ prefix
        name_with_ext=${zip_data##*/}

        # Remove shortest .* suffix
        name=${name_with_ext%.*}

        if grep -q "^${name}$" "${processed_log}"; then
          echo "Skipping file ${name} ( .zip file #$((++i)) out of ${num_delete_files} ). It is already marked as completed."
        else
          echo -e "\nProcessing delete file ${name} ( .zip file #$((++i)) out of ${num_delete_files} )..."
          unzip -o "${zip_data}"
          psql -f "${ABSOLUTE_SCRIPT_DIR}/process_deletes.sql"
          rm delete.txt
          echo "${name}" >> "${processed_log}"
          echo "ALL IS WELL"
        fi
        mv -v "${zip_data}" "${processed_archive_dir}"
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

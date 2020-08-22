#!/usr/bin/env bash
if [[ $1 == "-h" ]]; then
  cat <<'HEREDOC'
NAME

   LN_ad_hoc_download.sh --  download LexisNexis XMLs via lftp and NOT request data via API
                             Note that clean mode is NOT available with this script.

SYNOPSIS

   LexisNexis_download.sh [ -p processed_log ] [ -w data_directory ] [ -U username ]
                          [ -W password ] [ -R service_reference ]

   LexisNexis_download.sh -h: display this help

DESCRIPTION

   Download zip files into the working directory.
   The following options are available:

    -w  work_dir           directory where IPDD data is stored
    -p  processed_log      log successfully completed publication ZIPs and skip already processed files
    -U  username           IPDD username
    -W  password           IPDD password

HEREDOC
  exit 1
fi

if [[ ! -f /anaconda3/bin/python ]]; then
    echo "/anaconda3/bin/python does not exist."
    exit 1
fi

set -e
set -o pipefail

readonly STOP_FILE=".stop"
# Get a script directory, same as by $(dirname $0)
readonly SCRIPT_DIR=${0%/*}
declare -rx ERROR_LOG=error.log
declare -rx PARALLEL_LOG=parallel.log
PROCESSED_LOG="processed.log"

while (( $# > 0 )); do
  echo "Using CLI arg '$1'"
  case "$1" in
    -p)
      shift
      echo "Using CLI arg '$1'"
      readonly PROCESSED_LOG="$1"
      ;;
    -w)
      shift
      WORK_DIR=$1
      ;;
    -U)
      shift
      IPDD_USERNAME=$1
      ;;
    -W)
      shift
      IPDD_PASSWORD=$1
      ;;
    *)
      break
  esac
  shift
done

cd ${WORK_DIR}
echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##"

if ! which parallel >/dev/null; then
  echo "Please install GNU Parallel"
  exit 1
fi

# Download XMLs into Zip files in a local storage directory
mkdir -p API_downloads

echo "Checking server for files..."
lftp -u ${IPDD_USERNAME},${IPDD_PASSWORD} ftp-ipdatadirect.lexisnexis.com <<HEREDOC
nlist >> ftp_filelist.txt
quit
HEREDOC

# Download files if any new or missed ones are available
cat >group_download.sh <<HEREDOC
lftp -u ${IPDD_USERNAME},${IPDD_PASSWORD} ftp-ipdatadirect.lexisnexis.com <<SCRIPTEND
lcd API_downloads/
HEREDOC
grep -F -x -v --file="${PROCESSED_LOG}" ftp_filelist.txt | \
   sed 's/.*/mirror -v --use-pget -i &/' >>group_download.sh || { echo "Nothing to download" && exit 0; }
cat >>group_download.sh <<HEREDOC
quit
SCRIPTEND

HEREDOC

echo "Downloading from IPDD ..."
bash -xe group_download.sh
echo "Download finished."


#!/usr/bin/env bash
if [[ $1 == "-h" ]]; then
  cat <<'HEREDOC'
NAME

   generic_mcl_pipeline.sh -- End-to-end MCL pipeline

SYNOPSIS

   generic_mcl_pipeline.sh [ -f input_file ] [ -i inflation ]

   generic_mcl_pipeline.sh -h: display this help

DESCRIPTION

   Pre-process input CSV file and produce cluster output
   the working directory.
   The following options are required:

   -f input_file      edge-list in CSV format
   -i inflation       inflation parameter to be used. Must be entered
                      in decimal form, i.e., input -i 2.0 for inflation of 2.0

HEREDOC
  exit 1
fi


while (( $# > 0 )); do
  echo "Using CLI arg '$1'"
  case "$1" in
    -f)
      shift
      echo "Input file: '$1'"
      FILE_NAME="$1"
      ;;
    -i)
      shift
      echo "Using Inflation Parameter = '$1'"
      INFLATION_VAL="$1"
      ;;
    *)
      break
  esac
  shift
done

# pre-process by casting scps as character prefixed by 'a' to avoid
# unfortunate bigint events and export as tsv without colnames and rownames
Rscript ~/ERNIE/P2_studies/theta_plus/pre_process.R --args "$FILE_NAME"
# generate MCL output
source ~/ERNIE/P2_studies/theta_plus/mcl_script.sh -i "$INFLATION_VAL"
# postprocess mcloutput as csv
Rscript ~/ERNIE/P2_studies/theta_plus/post_process.R




#!/usr/bin/env bash
if [[ $1 == "-h" ]]; then
  cat <<'HEREDOC'
NAME

   mcl_script.sh -- Run MCL for given input file

SYNOPSIS

   mcl_script.sh [ -i inflation ]

   mcl_script.sh.sh -h: display this help

DESCRIPTION

   Takes .tsv output from pre-process.R and generates MCL output in
   the working directory.
   The following options are available:

   -i inflation       inflation parameter to be used. Must be entered
                      in decimal form, i.e., input -i 2.0 for inflation of 2.0

HEREDOC
  exit 1
fi

#
#

while (( $# > 0 )); do
  echo "Using CLI arg '$1'"
  case "$1" in
    -i)
      shift
      echo "Using Inflation Parameter = '$1'"
      ;;
    *)
      break
  esac
  shift
done

first_val="$(cut -d'.' -f1 <<<"$i")"
second_val="$(cut -d'.' -f2 <<<"$i")"

I_suffix="I$first_val$second_val"

#clean up any leftovers from previous runs
rm *jU0YWEwOWE3*

# loop
for f in *.tsv;
do
echo "input files - $f"
# copy input to generic label
cp $f jU0YWEwOWE3
# generate MCL output

# convert tsv to mcl native matrijU0YWEwOWE3
mcxload --stream-mirror -abc jU0YWEwOWE3 -o jU0YWEwOWE3.mci -write-tab jU0YWEwOWE3.tab
# run mcl with inflation factor =2.0 all others default
mcl jU0YWEwOWE3.mci -I "$i" # should result in out.jU0YWEwOWE3.mci.I20
# check output
clm info jU0YWEwOWE3.mci out.jU0YWEwOWE3.mci."$I_suffix"
# ejU0YWEwOWE3port matrijU0YWEwOWE3 output to labels
mcxdump -icl out.jU0YWEwOWE3.mci."$I_suffix" -tabr jU0YWEwOWE3.tab -o dump.jU0YWEwOWE3.mci."$I_suffix"

# generate shuffled matrijU0YWEwOWE3 as a null model
mcxrand -imx jU0YWEwOWE3.mci  -shuffle 1000000 -o jU0YWEwOWE3_shuffled_1million.mci
# generate clusters from shuffled matrijU0YWEwOWE3
mcl jU0YWEwOWE3_shuffled_1million.mci  -I "$i" # should result in out.jU0YWEwOWE3_shuffled_1million.mci.I20
# ejU0YWEwOWE3port matrijU0YWEwOWE3 output to labels
mcxdump -icl out.jU0YWEwOWE3_shuffled_1million.mci."$I_suffix" -tabr jU0YWEwOWE3.tab -o dump.jU0YWEwOWE3_shuffled_1million."$I_suffix"

# edit jU0YWEwOWE3-based names to recreate filenames relative to state of the loop
  for p in *jU0YWEwOWE3*.*; 
  do mv -v "$p" "${p/jU0YWEwOWE3/${f%%.*}}"; 
  done;
rm jU0YWEwOWE3
done






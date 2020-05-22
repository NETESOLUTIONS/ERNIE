# takes .tsv output from pre-process.R and generates MCL output

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
mcl jU0YWEwOWE3.mci -I 2.0 # should result in out.jU0YWEwOWE3.mci.I20
# check output
clm info jU0YWEwOWE3.mci out.jU0YWEwOWE3.mci.I20
# ejU0YWEwOWE3port matrijU0YWEwOWE3 output to labels
mcxdump -icl out.jU0YWEwOWE3.mci.I20 -tabr jU0YWEwOWE3.tab -o dump.jU0YWEwOWE3.mci.I20

# generate shuffled matrijU0YWEwOWE3 as a null model
mcxrand -imx jU0YWEwOWE3.mci  -shuffle 1000000 -o jU0YWEwOWE3_shuffled_1million.mci
# generate clusters from shuffled matrijU0YWEwOWE3
mcl jU0YWEwOWE3_shuffled_1million.mci  -I 2.0 # should result in out.jU0YWEwOWE3_shuffled_1million.mci.I20
# ejU0YWEwOWE3port matrijU0YWEwOWE3 output to labels
mcxdump -icl out.jU0YWEwOWE3_shuffled_1million.mci.I20 -tabr jU0YWEwOWE3.tab -o dump.jU0YWEwOWE3_shuffled_1million.I20

# edit jU0YWEwOWE3-based names to recreate filenames relative to state of the loop
  for p in *jU0YWEwOWE3*.*; 
  do mv -v "$p" "${p/jU0YWEwOWE3/${f%%.*}}"; 
  done;
rm jU0YWEwOWE3
done






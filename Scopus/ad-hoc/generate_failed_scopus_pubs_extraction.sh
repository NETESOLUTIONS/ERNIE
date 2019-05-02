#!/usr/bin/env bash
readonly DEST_DIR='../failed/'
pcregrep -o1 -o2 --om-separator=' ' 'cannot move.*(2-s2.0-\d+).* to .*/([\da-z-]+\.zip)' job.log | while read pub zip
do
  echo "unzip $zip '*$pub.xml' -d $DEST_DIR"
done

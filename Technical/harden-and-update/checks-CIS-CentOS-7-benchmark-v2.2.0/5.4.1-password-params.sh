#!/usr/bin/env bash
set -e
set -o pipefail
echo -e '## 5.4 User Accounts and Environment ##\n\n'

echo -e '### 5.4.1 Set Shadow Password Suite Parameters ###'

echo "5.4.1.1 Ensure password expiration is 365 days or less"
echo "___CHECK___"
declare -i actual=$(pcregrep -o1 '^\s*PASS_MAX_DAYS\s+(\d+)' /etc/login.defs)
if ((actual > 0 && actual <= 365)); then
  echo "Check PASSED"
else
  echo "Check FAILED"
  echo "Found unexpected actual value in /etc/login.defs for the pattern '^\s*PASS_MAX_DAYS\s+(\d+)' = '$actual'"
  echo "___SET___"
  upsert /etc/login.defs '^\s*PASS_MAX_DAYS' $'PASS_MAX_DAYS\t90'
fi
printf "\n\n"

echo "5.4.1.2 Ensure minimum days between password changes is 7 or more"
echo "___CHECK___"
actual=$(pcregrep -o1 '^\s*PASS_MIN_DAYS\s+(\d+)' /etc/login.defs)
if ((actual >= 7)); then
  echo "Check PASSED"
else
  echo "Check FAILED"
  echo "Found unexpected actual value in /etc/login.defs for the pattern '^\s*PASS_MIN_DAYS\s+(\d+)' = '$actual'"
  echo "___SET___"
  upsert /etc/login.defs '^\s*PASS_MIN_DAYS' $'PASS_MIN_DAYS\t7'
fi
printf "\n\n"

echo "5.4.1.3 Ensure password expiration warning days is 7 or more"
echo "___CHECK___"
actual=$(pcregrep -o1 '^\s*PASS_WARN_AGE\s+(\d+)' /etc/login.defs)
if ((actual >= 7)); then
  echo "Check PASSED"
else
  echo "Check FAILED"
  echo "Found unexpected actual value in /etc/login.defs for the pattern '^\s*PASS_WARN_AGE\s+(\d+)' = '$actual'"
  echo "___SET___"
  upsert /etc/login.defs '^\s*PASS_WARN_AGE' $'PASS_WARN_AGE\t7'
fi
printf "\n\n"

echo "5.4.1.4 Ensure inactive password lock is 30 days or less"
echo "___CHECK___"
INACTIVE_PASSWORD_LOCK=$(useradd -D | pcregrep -o1 'INACTIVE=(-?\d+)')
declare -ri INACTIVE_PASSWORD_LOCK
if ((INACTIVE_PASSWORD_LOCK <= 30)); then
  echo "Check PASSED"
else
  echo "Check FAILED..."
  echo "The actual inactive lock = '$INACTIVE_PASSWORD_LOCK'"
  echo "Correcting ..."
  echo "___SET___"
  useradd -D -f 30
fi
printf "\n\n"
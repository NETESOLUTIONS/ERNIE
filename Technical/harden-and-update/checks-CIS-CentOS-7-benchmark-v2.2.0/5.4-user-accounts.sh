#!/usr/bin/env bash
echo -e '## 5.4 User Accounts and Environment ##\n\n'

echo -e '### 5.4.1 Set Shadow Password Suite Parameters ###'

echo "5.4.1.1 Ensure password expiration is 365 days or less"
echo "___CHECK___"
ensure /etc/login.defs '^#*\s*PASS_MAX_DAYS ' 'PASS_MAX_DAYS 90'
printf "\n\n"

echo "5.4.1.2 Ensure minimum days between password changes is 7 or more"
echo "___CHECK___"
ensure /etc/login.defs '^#*\s*PASS_MIN_DAYS ' 'PASS_MIN_DAYS 7'
printf "\n\n"

echo "5.4.1.3 Ensure password expiration warning days is 7 or more"
echo "___CHECK___"
ensure /etc/login.defs '^#*\s*PASS_WARN_AGE ' 'PASS_WARN_AGE 7'
printf "\n\n"

echo "5.4.1.4 Ensure inactive password lock is 30 days or less"
echo "___CHECK___"
declare -i actual=$(useradd -D | pcregrep -o1 'INACTIVE=(-?\d+)')
if ((actual <= 30)); then
  echo "Check PASSED"
else
  echo "Check FAILED..."
  echo "The actual inactive lock = ${actual}"
  echo "Correcting ..."
  echo "___SET___"
  useradd -D -f 30
fi
printf "\n\n"

echo "5.4.2 Ensure system accounts are non-login"
unset check_failed
echo "___CHECK___"
while IFS=: read -r user enc_passwd uid gid full_name home shell; do
  if [[ "$user" != "root" && "$user" != "sync" && "$user" != "shutdown" && "$user" != "halt" ]] && \
        ((uid < MIN_NON_SYSTEM_UID)) && [[ "$shell" != "/sbin/nologin" && "$shell" != "/bin/false" ]]; then
    check_failed=true
    echo "Check FAILED..."
    echo "$user:$uid:$gid:$full_name:$home:$shell"
    echo "___SET___"
    usermod --lock "${user}"
    usermod --shell /sbin/nologin "${user}"
  fi
done < <(grep -E -v "^\+" /etc/passwd)
[[ $check_failed == true ]] && exit 1
echo "Check PASSED"
printf "\n\n"

echo "5.4.3 Ensure default group for the root account is GID 0"
echo "___CHECK___"
if [[ "$(grep "^root:" /etc/passwd | cut -f4 -d:)" == 0 ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  usermod -g 0 root
fi
printf "\n\n"

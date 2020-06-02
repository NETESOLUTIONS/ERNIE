#!/usr/bin/env bash
echo -e '## 5.2 SSH Server Configuration ##\n\n'

echo "5.2.1 Ensure permissions on /etc/ssh/sshd_config are configured"
echo "____CHECK____"
ensure_permissions /etc/ssh/sshd_config
printf "\n\n"

echo "5.2.2 Ensure SSH Protocol is set to 2"
echo "____CHECK____"
ensure /etc/ssh/sshd_config '^Protocol.*' 'Protocol 2'
printf "\n\n"

echo "5.2.3 Ensure SSH LogLevel is set to INFO"
echo "____CHECK____"
ensure /etc/ssh/sshd_config '^LogLevel.*' 'LogLevel INFO'
if ! grep -E '^LogLevel [^I]' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, SET IN ACTION "
  echo "____SET____"
  sed --in-place --regexp-extended '/^LogLevel [^I]/d' /etc/ssh/sshd_config
fi
printf "\n\n"

# X11 is needed to run DataGrip on server(s)
#echo "6.2.4 Disable X11 Forwarding"
#printf "\n\n"

echo "6.2.5 Set SSH MaxAuth Tries to 4 or less"
echo "____CHECK____"
declare -i value
# value = 0 when not found
value=$(pcregrep --only-matching=1 '^MaxAuthTries (.*)' /etc/ssh/sshd_config) || :
if ((value > 0 && value <= 4)); then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert /etc/ssh/sshd_config '#*MaxAuthTries ' 'MaxAuthTries 4'
fi
printf "\n\n"

echo "6.2.6 Set SSH IgnoreRhosts to yes (default)"
echo "____CHECK____"
if ! grep -E '^IgnoreRhosts no' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert /etc/ssh/sshd_config 'IgnoreRhosts ' 'IgnoreRhosts yes'
fi
printf "\n\n"

echo "6.2.7 Set SSH HostbasedAuthentication to no (default)"
if ! grep -E '^HostbasedAuthentication yes' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert /etc/ssh/sshd_config 'HostbasedAuthentication ' 'HostbasedAuthentication no'
fi
printf "\n\n"

echo "6.2.8 Disable SSH Root Login"
echo "____CHECK____"
if grep -E '^PermitRootLogin no' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert /etc/ssh/sshd_config '#*PermitRootLogin ' 'PermitRootLogin no'
fi
printf "\n\n"

echo "6.2.9 Set SSH PermitEmptyPasswords to no (default)"
echo "____CHECK____"
if ! grep -E '^PermitEmptyPasswords yes' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert /etc/ssh/sshd_config 'PermitEmptyPasswords ' 'PermitEmptyPasswords no'
fi
printf "\n\n"

echo "6.2.10 Set SSH PermitUserEnvironment to no (default)"
echo "____CHECK____"
if ! grep -E '^PermitUserEnvironment yes' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert /etc/ssh/sshd_config 'PermitUserEnvironment ' 'PermitUserEnvironment no'
fi
printf "\n\n"

echo "6.2.11 Use Only Approved Ciphers in Counter Mode"
echo "____CHECK____"
if grep -E '^Ciphers aes128-ctr,aes192-ctr,aes256-ctr' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert /etc/ssh/sshd_config '#*Ciphers ' 'Ciphers aes128-ctr,aes192-ctr,aes256-ctr'
fi
printf "\n\n"

echo "6.2.12 Set SSH Idle Timeout"
echo "____CHECK 1/2____"
if grep -E '^ClientAliveInterval 3600' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert /etc/ssh/sshd_config '#*ClientAliveInterval ' 'ClientAliveInterval 3600'
fi
echo "____CHECK 2/2____"
if grep -E '^ClientAliveCountMax 0' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert /etc/ssh/sshd_config '#*ClientAliveCountMax ' 'ClientAliveCountMax 0'
fi
printf "\n\n"

echo "6.2.13 Limit Access via SSH"
if grep -E '^AllowGroups' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  cat << HEREDOC
Check FAILED, correct this!
Add AllowGroups to /etc/ssh/sshd_config
HEREDOC
  exit 1
fi
printf "\n\n"

echo "6.2.14 Set SSH Banner"
echo "____CHECK____"
if grep -E '^Banner' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  if [[ ! -f /etc/issue.net ]]; then
    cat > /etc/issue.net << 'HEREDOC'
********************************************************************
*                                                                  *
* This system is for the use of authorized users only.  Usage of   *
* this system may be monitored and recorded by system personnel.   *
*                                                                  *
* Anyone using this system expressly consents to such monitoring   *
* and is advised that if such monitoring reveals possible          *
* evidence of criminal activity, system personnel may provide the  *
* evidence from such monitoring to law enforcement officials.      *
*                                                                  *
********************************************************************
HEREDOC
  fi
  upsert /etc/ssh/sshd_config '#*Banner ' 'Banner /etc/issue.net'
  systemctl restart sshd
fi
printf "\n\n"

# Reload configuration for changes to take effect
systemctl reload sshd
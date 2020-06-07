#!/usr/bin/env bash
echo -e '## 5.2 SSH Server Configuration ##\n\n'

# Make sure that new configurations keys are not appended to a conditional block at the end of file
ensure /etc/ssh/sshd_config '^\s*Match All'

echo "5.2.1 Ensure permissions on /etc/ssh/sshd_config are configured"
echo "____CHECK____"
ensure_permissions /etc/ssh/sshd_config
printf "\n\n"

echo "5.2.2 Ensure SSH Protocol is set to 2"
echo "____CHECK____"
ensure /etc/ssh/sshd_config '^#*\s*Protocol.*' 'Protocol 2'
printf "\n\n"

echo "5.2.3 Ensure SSH LogLevel is set to INFO"
echo "____CHECK____"
ensure /etc/ssh/sshd_config '^#*\s*LogLevel' 'LogLevel INFO'
printf "\n\n"

# WARNING: X11 is needed to run DataGrip and other GUI apps on the server
echo "5.2.4 Ensure SSH X11 forwarding is disabled"
echo "____CHECK____"
ensure /etc/ssh/sshd_config '^#*\s*X11Forwarding' 'X11Forwarding no'
printf "\n\n"

echo "5.2.5 Ensure SSH MaxAuthTries is set to 4 or less"
echo "____CHECK____"
# value defaults to 0 when not found
declare -i value=$(pcregrep --only-matching=1 '^MaxAuthTries (.*)' /etc/ssh/sshd_config)
if ((value > 0 && value <= 4)); then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert /etc/ssh/sshd_config '#*\s*MaxAuthTries ' 'MaxAuthTries 4'
fi
printf "\n\n"

echo "5.2.6 Ensure SSH IgnoreRhosts is enabled"
echo "____CHECK____"
ensure /etc/ssh/sshd_config '^#*\s*IgnoreRhosts ' 'IgnoreRhosts yes'
printf "\n\n"

echo "5.2.7 Ensure SSH HostbasedAuthentication is disabled"
echo "____CHECK____"
ensure /etc/ssh/sshd_config '^#*\s*HostbasedAuthentication ' 'HostbasedAuthentication no'
printf "\n\n"

echo "5.2.8 Ensure SSH root login is disabled"
echo "____CHECK____"
ensure /etc/ssh/sshd_config '^#*\s*PermitRootLogin ' 'PermitRootLogin no'
printf "\n\n"

echo "5.2.9 Ensure SSH PermitEmptyPasswords is disabled"
echo "____CHECK____"
ensure /etc/ssh/sshd_config '^#*\s*PermitEmptyPasswords ' 'PermitEmptyPasswords no'
printf "\n\n"

echo "5.2.10 Ensure SSH PermitUserEnvironment is disabled"
echo "____CHECK____"
ensure /etc/ssh/sshd_config '^#*\s*PermitUserEnvironment ' 'PermitUserEnvironment no'
printf "\n\n"

echo "5.2.11 Ensure only approved MAC algorithms are used"
echo "____CHECK____"
ensure /etc/ssh/sshd_config '^#*\s*MACs ' "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,\
umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com"
printf "\n\n"

echo "5.2.12 Ensure SSH Idle Timeout Interval is configured"

echo "____CHECK 1/2____"
# Site policy-specific interval (recommended = 300)
ensure /etc/ssh/sshd_config '^#*\s*ClientAliveInterval ' 'ClientAliveInterval 3600'

echo "____CHECK 2/2____"
ensure /etc/ssh/sshd_config '^#*\s*ClientAliveCountMax ' 'ClientAliveCountMax 0'

printf "\n\n"

echo "5.2.13 Ensure SSH LoginGraceTime is set to one minute or less"
echo "____CHECK____"
ensure /etc/ssh/sshd_config '^#*\s*LoginGraceTime ' 'LoginGraceTime 60'
printf "\n\n"

echo "5.2.14 Ensure SSH access is limited"
ensure /etc/ssh/sshd_config '^AllowGroups '
printf "\n\n"

echo "5.2.15 Ensure SSH warning banner is configured"
echo "____CHECK____"
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
ensure /etc/ssh/sshd_config '^#*\s*Banner ' 'Banner /etc/issue.net'
printf "\n\n"

# Reload configuration for changes to take effect
systemctl reload sshd

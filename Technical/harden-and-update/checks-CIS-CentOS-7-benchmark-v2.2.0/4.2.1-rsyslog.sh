#!/usr/bin/env bash
set -e
set -o pipefail
echo -e '## 4.2 Configure Logging ##\n\n'

echo -e '### 4.2.1 Configure rsyslog ###\n\n'

# rsyslog is often installed in the baseline image
# Hence it's preferred over `syslog-ng` (4.2.2)
echo "4.2.1.1 Ensure rsyslog Service is enabled"
#ensure_installed rsyslog
#ensure_service_disabled syslog
ensure_service_enabled rsyslog

echo "4.2.1.3 Ensure rsyslog default file permissions configured"
for file in /etc/rsyslog.conf /etc/rsyslog.d/*.conf; do
  # shellcheck disable=SC2016 # `$` is a part of property key
  ensure "$file" '^\s*\$FileCreateMode' '$FileCreateMode 0640'
done
printf "\n\n"

# Assumes the hardened server is *not* the log host
echo "4.2.1.5 Ensure remote rsyslog messages are only accepted on designated log hosts."
echo "___CHECK 1/2___"
# shellcheck disable=SC2016 # `$` is a part of property key
ensure /etc/rsyslog.conf '^\s*\$ModLoad.*imtcp' '#$ModLoad imtcp'

echo "___CHECK 2/2___"
# shellcheck disable=SC2016 # `$` is a part of property key
ensure /etc/rsyslog.conf '^\s*\$InputTCPServerRun 514' '#$InputTCPServerRun 514'

# TBD This could be done only when the configuration is changed
pkill -HUP rsyslogd

printf "\n\n"

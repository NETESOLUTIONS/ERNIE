#!/usr/bin/env bash
echo "3.16 Configure Mail Transfer Agent for Local-Only Mode"
echo "___CHECK___"
netstat -an | grep LIST | grep ":25[[:space:]]" || :
matches=$(netstat -an | grep LIST | grep ":25[[:space:]]" || :)
b='tcp 0 0 127.0.0.1:25 0.0.0.0:* LISTEN'
if [[ "$(echo $matches)" == *"$b"* ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  sed -i '/^inet_interfaces/d' /etc/postfix/main.cf
  echo 'inet_interfaces = localhost' >> /etc/postfix/main.cf
fi
printf "\n\n"

#!/usr/bin/env bash
echo "2.2.3 Ensure Avahi Server is not enabled"
disable_sysv_service avahi-daemon

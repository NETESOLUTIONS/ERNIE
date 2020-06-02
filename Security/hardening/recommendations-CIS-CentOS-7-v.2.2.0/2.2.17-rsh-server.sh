#!/usr/bin/env bash
echo "2.2.17 Ensure rsh server is not enabled"
disable_sysv_service rsh.socket
disable_sysv_service rlogin.socket
disable_sysv_service rexec.socket

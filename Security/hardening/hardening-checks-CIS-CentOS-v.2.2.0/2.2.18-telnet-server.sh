#!/usr/bin/env bash
echo "2.2.18 Ensure telnet server is not enabled"
disable_sysv_service telnet.socket

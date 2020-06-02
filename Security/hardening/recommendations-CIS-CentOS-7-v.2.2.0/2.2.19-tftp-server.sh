#!/usr/bin/env bash
echo "2.2.19 Ensure tftp server is not enabled"
disable_sysv_service tftp.socket

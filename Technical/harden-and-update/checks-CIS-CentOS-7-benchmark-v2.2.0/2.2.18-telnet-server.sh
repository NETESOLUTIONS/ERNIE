#!/usr/bin/env bash
echo "2.2.18 Ensure telnet server is not enabled"
ensure_service_disabled telnet.socket

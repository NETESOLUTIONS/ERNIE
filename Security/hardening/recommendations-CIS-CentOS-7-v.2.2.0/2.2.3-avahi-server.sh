#!/usr/bin/env bash
echo "2.2.3 Ensure Avahi Server is not enabled"
ensure_service_disabled avahi-daemon

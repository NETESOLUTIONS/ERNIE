#!/usr/bin/env bash
echo "2.2.20 Ensure rsync service is not enabled"
ensure_service_disabled rsyncd

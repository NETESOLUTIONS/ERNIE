#!/usr/bin/env bash
echo '2.2.10 Ensure HTTP server is not enabled'
ensure_service_disabled httpd

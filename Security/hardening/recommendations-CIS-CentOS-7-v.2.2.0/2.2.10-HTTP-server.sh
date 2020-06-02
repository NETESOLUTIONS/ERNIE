#!/usr/bin/env bash
echo '2.2.10 Ensure HTTP server is not enabled'
disable_sysv_service httpd

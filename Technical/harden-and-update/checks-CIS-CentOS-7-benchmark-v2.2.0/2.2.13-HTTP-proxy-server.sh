#!/usr/bin/env bash
echo '2.2.13 Ensure HTTP Proxy Server is not enabled'
ensure_service_disabled squid

#!/usr/bin/env bash
echo '2.2.14 Ensure SNMP Server is not enabled'
ensure_service_disabled snmpd

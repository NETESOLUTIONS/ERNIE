#!/usr/bin/env bash
echo "2.3 Service Clients"
ensure_uninstalled "2.3.1 Ensure NIS Client is not installed" ypbind
ensure_uninstalled "2.3.2 Ensure rsh client is not installed" rsh
ensure_uninstalled "2.3.3 Ensure talk client is not installed" talk
ensure_uninstalled "2.3.4 Ensure telnet client is not installed" telnet
ensure_uninstalled "2.3.5 Ensure LDAP client is not installed" openldap-clients
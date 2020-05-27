#!/usr/bin/env bash
echo "2.3 Service Clients"
uninstall "2.3.1 Ensure NIS Client is not installed" ypbind
uninstall "2.3.2 Ensure rsh client is not installed" rsh
uninstall "2.3.3 Ensure talk client is not installed" talk
uninstall "2.3.4 Ensure telnet client is not installed" telnet
uninstall "2.3.5 Ensure LDAP client is not installed" openldap-clients
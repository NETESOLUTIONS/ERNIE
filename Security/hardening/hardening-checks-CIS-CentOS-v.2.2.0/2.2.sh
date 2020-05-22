#!/usr/bin/env bash
echo -e '## 2.2 Special Purpose Services ##\n\n'

echo "2.2.4 Ensure CUPS is not enabled"
disable_sysv_service cups

uninstall '3.5 Remove DHCP Server' dhcp

uninstall 2.1.1 telnet-server
uninstall 2.1.2 telnet
uninstall 2.1.3 rsh-server
uninstall 2.1.4 rsh
uninstall 2.1.5 ypbind
uninstall 2.1.6 ypserv
uninstall 2.1.7 tftp
uninstall 2.1.8 tftp-server
uninstall 2.1.9 talk
uninstall 2.1.10 talk-server

echo "2.1.18 Disable tcpmux-server"
disable_sysv_service tcpmux-server
#!/usr/bin/env bash
echo -e '# 2. Services #\n\n'

echo -e '## 2.1 inetd Services ##\n\n'

echo "2.1.1 Ensure chargen services are not enabled"
disable_sysv_service chargen-dgram
disable_sysv_service chargen-stream

echo "2.1.2 Ensure daytime services are not enabled"
disable_sysv_service daytime-dgram
disable_sysv_service daytime-stream

echo "2.1.3 Ensure discard services are not enabled"
disable_sysv_service discard-dgram
disable_sysv_service discard-stream

echo "2.1.4 Ensure echo services are not enabled"
disable_sysv_service echo-dgram
disable_sysv_service echo-stream

echo "2.1.5 Ensure time services are not enabled"
disable_sysv_service time-dgram
disable_sysv_service time-stream

echo "2.1.6 Ensure tftp server is not enabled"
disable_sysv_service tftp

echo "2.1.7 Ensure xinetd is not enabled"
disable_sysv_service xinetd
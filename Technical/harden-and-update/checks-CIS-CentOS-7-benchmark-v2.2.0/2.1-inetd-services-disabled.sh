#!/usr/bin/env bash
echo -e '# 2. Services #\n\n'

echo -e '## 2.1 inetd Services ##\n\n'

echo "2.1.1 Ensure chargen services are not enabled"
ensure_service_disabled chargen-dgram
ensure_service_disabled chargen-stream

echo "2.1.2 Ensure daytime services are not enabled"
ensure_service_disabled daytime-dgram
ensure_service_disabled daytime-stream

echo "2.1.3 Ensure discard services are not enabled"
ensure_service_disabled discard-dgram
ensure_service_disabled discard-stream

echo "2.1.4 Ensure echo services are not enabled"
ensure_service_disabled echo-dgram
ensure_service_disabled echo-stream

echo "2.1.5 Ensure time services are not enabled"
ensure_service_disabled time-dgram
ensure_service_disabled time-stream

echo "2.1.6 Ensure tftp server is not enabled"
ensure_service_disabled tftp

echo "2.1.7 Ensure xinetd is not enabled"
ensure_service_disabled xinetd
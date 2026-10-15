#!/usr/bin/env bash
# Scan the DVWA container. Usage: scan-dvwa.sh [full|fast|discovery]
cd "$(dirname "$0")/.."
docker exec "$(docker compose ps -q ospd-openvas)" sh -c 'getent hosts 172.30.0.10 >/dev/null 2>&1; ping -c1 -W2 172.30.0.10 >/dev/null 2>&1' \
  && echo "Scanner can reach DVWA." \
  || echo "Warning: could not ping 172.30.0.10 from scanner (ping may be missing); continuing."
exec scripts/scan.sh dvwa-lab 172.30.0.10 "${1:-full}"

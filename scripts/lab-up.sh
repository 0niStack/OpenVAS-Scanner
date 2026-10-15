#!/usr/bin/env bash
# Start DVWA and connect the OpenVAS scanner to its network.
set -euo pipefail
cd "$(dirname "$0")/.."
docker compose -f dvwa/docker-compose.yml up -d
docker compose -f docker-compose.yml -f docker-compose.lab.yml up -d
echo
echo "DVWA   : http://127.0.0.1:4280   (admin / password, then click 'Create / Reset Database')"
echo "Target : 172.30.0.10 (reachable from the OpenVAS scanner)"
echo "Scan   : scripts/scan-dvwa.sh"

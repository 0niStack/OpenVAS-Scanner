#!/usr/bin/env bash
# Remove DVWA (and its DB volume). OpenVAS stays up.
set -euo pipefail
cd "$(dirname "$0")/.."
docker compose -f dvwa/docker-compose.yml down -v
docker compose up -d ospd-openvas
echo "DVWA lab removed."

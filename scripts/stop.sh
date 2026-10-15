#!/usr/bin/env bash
. "$(dirname "$0")/common.sh"
dc down
echo "Stopped. Data kept in Docker volumes. Use 'docker compose down -v' to wipe everything."

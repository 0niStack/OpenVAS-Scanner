#!/usr/bin/env bash
# Shared helpers
set -euo pipefail
cd "$(dirname "$0")/.."
[ -f .env ] && set -a && . ./.env && set +a
GVM_USER="${GVM_USER:-admin}"
GVM_PASSWORD="${GVM_PASSWORD:-}"

dc() { docker compose "$@"; }

gmp() {  # gmp '<xml/>'
  docker compose run --rm -T gvm-tools gvm-cli \
    --gmp-username "$GVM_USER" --gmp-password "$GVM_PASSWORD" \
    socket --socketpath /run/gvmd/gvmd.sock --xml "$1" 2>/dev/null
}

xml_attr_id() { sed -n 's/.*id="\([0-9a-f-]\{36\}\)".*/\1/p' | head -n1; }

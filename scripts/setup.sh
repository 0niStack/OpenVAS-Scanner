#!/usr/bin/env bash
# One-shot setup: checks Docker, creates .env, pulls images, starts stack, sets admin password.
set -euo pipefail
cd "$(dirname "$0")/.."

command -v docker >/dev/null || { echo "Docker not found. Install: curl -fsSL https://get.docker.com | sh"; exit 1; }
docker compose version >/dev/null 2>&1 || { echo "Docker Compose v2 plugin required."; exit 1; }

if [ ! -f .env ]; then
  cp .env.example .env
  PW="$(openssl rand -base64 18 | tr -d '/+=' | cut -c1-20)"
  sed -i "s|^GVM_PASSWORD=.*|GVM_PASSWORD=${PW}|" .env
  echo "Created .env with a random admin password (see GVM_PASSWORD in .env)."
fi
. ./.env

echo "[1/3] Pulling images (large, several GB)..."
docker compose pull

echo "[2/3] Starting stack..."
docker compose up -d

echo "[3/3] Setting admin password (waits for gvmd)..."
for i in $(seq 1 60); do
  if docker compose exec -T -u gvmd gvmd gvmd --user="$GVM_USER" --new-password="$GVM_PASSWORD" >/dev/null 2>&1; then
    OK=1; break
  fi
  sleep 10
done
[ "${OK:-0}" = 1 ] || echo "Could not set password yet; gvmd still initialising. Run scripts/set-password.sh in a few minutes."

cat <<MSG

Done.
  Web UI : http://${GSA_BIND:-127.0.0.1}:${GSA_PORT:-9392}
  User   : $GVM_USER
  Pass   : in .env (GVM_PASSWORD)

IMPORTANT: the first start downloads/loads the vulnerability feeds (NVTs, SCAP, CERT).
This can take 30-90+ minutes. Scans started before the feed finishes will be incomplete.
Check progress with: scripts/feed-status.sh
MSG

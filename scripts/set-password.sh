#!/usr/bin/env bash
# Reset the admin password to GVM_PASSWORD from .env
. "$(dirname "$0")/common.sh"
[ -n "$GVM_PASSWORD" ] || { echo "Set GVM_PASSWORD in .env"; exit 1; }
dc exec -T -u gvmd gvmd gvmd --user="$GVM_USER" --new-password="$GVM_PASSWORD"
echo "Password updated for $GVM_USER"

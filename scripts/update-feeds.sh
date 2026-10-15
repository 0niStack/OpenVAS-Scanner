#!/usr/bin/env bash
# Refresh vulnerability feeds (run weekly/daily via cron)
. "$(dirname "$0")/common.sh"
dc pull vulnerability-tests notus-data scap-data cert-bund-data dfn-cert-data data-objects report-formats gpg-data
dc up -d
echo "Feeds refreshed. gvmd will re-sync in the background."

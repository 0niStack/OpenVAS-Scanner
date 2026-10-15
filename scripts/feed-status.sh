#!/usr/bin/env bash
# Show feed versions + whether the scanner is ready
. "$(dirname "$0")/common.sh"
echo "--- feeds ---"
gmp '<get_feeds/>' | grep -oE '<(name|version|description)>[^<]*' | sed 's/<//' | paste - - - || true
echo "--- scanners ---"
gmp '<get_scanners/>' | grep -oE '<name>[^<]*' | sed 's/<name>//' | head
echo
echo "Recent log lines:"
dc logs --tail=5 gvmd ospd-openvas

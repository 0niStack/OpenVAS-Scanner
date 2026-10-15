#!/usr/bin/env bash
# Show status/progress of all tasks
. "$(dirname "$0")/common.sh"
gmp '<get_tasks/>' | python3 -c '
import sys,re
x=sys.stdin.read()
for t in re.findall(r"<task id=\"[^\"]+\".*?</task>",x,re.S):
    n=re.search(r"<name>([^<]*)",t).group(1)
    s=re.search(r"<status>([^<]*)",t).group(1)
    p=re.search(r"<progress>([^<]*)",t)
    print(f"{n:45} {s:12} {p.group(1) if p else \"\"}%")
' 2>/dev/null || gmp '<get_tasks/>'

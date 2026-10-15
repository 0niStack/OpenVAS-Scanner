#!/usr/bin/env bash
# Export a report to ./reports (default: last scan, PDF). Usage: report.sh [report_id] [pdf|html|txt|xml|csv]
. "$(dirname "$0")/common.sh"
RID="${1:-$(cat .last_report 2>/dev/null || true)}"
FMT="${2:-pdf}"
[ -n "$RID" ] || { echo "No report id. Pass one or run a scan first."; exit 1; }
case "$FMT" in
  pdf)  F=c402cc3e-b531-11e1-9163-406186ea4fc5 ;;
  html) F=6c248850-1f62-11e1-b082-406186ea4fc5 ;;
  txt)  F=a3810a62-1f62-11e1-9219-406186ea4fc5 ;;
  xml)  F=a994b278-1f62-11e1-96ac-406186ea4fc5 ;;
  csv)  F=c1645568-627a-4e43-9bfe-02ed6be3ee62 ;;
  *) echo "format: pdf|html|txt|xml|csv"; exit 1 ;;
esac
mkdir -p reports
OUT="reports/report-${RID}.${FMT}"
gmp "<get_reports report_id=\"${RID}\" format_id=\"${F}\" ignore_pagination=\"1\" details=\"1\"/>" \
  | python3 -c '
import sys,re,base64
x=sys.stdin.read()
m=re.search(r"</report_format>(.*?)</report>\s*</get_reports_response>",x,re.S)
body=(m.group(1) if m else x).strip()
sys.stdout.buffer.write(base64.b64decode(body))
' > "$OUT"
echo "Saved $OUT"

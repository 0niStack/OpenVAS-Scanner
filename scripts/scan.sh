#!/usr/bin/env bash
# Create target + task and start a scan.
# Usage: scripts/scan.sh <name> <host|ip|cidr|comma-list> [full|fast|discovery]
. "$(dirname "$0")/common.sh"
NAME="${1:?usage: scan.sh <name> <hosts> [full|fast|discovery]}"
HOSTS="${2:?usage: scan.sh <name> <hosts> [full|fast|discovery]}"
PROFILE="${3:-full}"
[ -n "$GVM_PASSWORD" ] || { echo "Set GVM_PASSWORD in .env"; exit 1; }

# Built-in Greenbone IDs
case "$PROFILE" in
  full)      CONFIG=daba56c8-73ec-11df-a475-002264764cea ;; # Full and fast
  fast)      CONFIG=698f691e-7489-11df-9d8c-002264764cea ;; # Full and fast ultimate
  discovery) CONFIG=8715c877-47a0-438d-98a3-27c7a6ab2196 ;; # Discovery
  *) echo "profile must be full|fast|discovery"; exit 1 ;;
esac
PORT_LIST=33d0cd82-57c6-11e1-8ed1-406186ea4fc5   # All IANA assigned TCP
SCANNER=08b69003-5fc2-4037-a479-93b440211c73     # OpenVAS Default

echo "Only scan systems you own or have written permission to test."
TS="$(date +%Y%m%d-%H%M%S)"

TARGET_ID=$(gmp "<create_target><name>${NAME}-${TS}</name><hosts>${HOSTS}</hosts><port_list id=\"${PORT_LIST}\"/></create_target>" | xml_attr_id)
[ -n "$TARGET_ID" ] || { echo "Failed to create target (is the stack up and the password set?)"; exit 1; }

TASK_ID=$(gmp "<create_task><name>${NAME}-${TS}</name><config id=\"${CONFIG}\"/><target id=\"${TARGET_ID}\"/><scanner id=\"${SCANNER}\"/></create_task>" | xml_attr_id)
[ -n "$TASK_ID" ] || { echo "Failed to create task"; exit 1; }

REPORT_ID=$(gmp "<start_task task_id=\"${TASK_ID}\"/>" | sed -n 's/.*<report_id>\([0-9a-f-]*\)<.*/\1/p')
echo "Task   : $TASK_ID"
echo "Report : $REPORT_ID"
echo "$TASK_ID" > .last_task
echo "$REPORT_ID" > .last_report
echo "Watch progress: scripts/status.sh   |   Export when done: scripts/report.sh"

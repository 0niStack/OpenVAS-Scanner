# OpenVAS (Greenbone Community Edition) - Docker project

Self-hosted vulnerability scanner using the official Greenbone community containers:
gvmd (manager), ospd-openvas (scanner), notus-scanner, gsad (web UI), PostgreSQL, Redis, MQTT, plus feed data containers.

## Requirements
- Linux host (Ubuntu 22.04/24.04 recommended), Docker + Docker Compose v2
- 4 GB RAM minimum (8 GB recommended), 20 GB free disk
- Outbound internet to `registry.community.greenbone.net` (images + feeds)
- Network path from the scanner host to the targets

## Quick start
```bash
unzip openvas-devops.zip && cd openvas-devops
./scripts/setup.sh          # creates .env (random password), pulls images, starts, sets admin password
./scripts/feed-status.sh    # wait for feeds to finish loading (30-90+ min first time)
```
Open http://127.0.0.1:9392 and log in as `admin` with `GVM_PASSWORD` from `.env`.

Remote server? The UI binds to localhost on purpose. Use an SSH tunnel:
```bash
ssh -L 9392:127.0.0.1:9392 user@your-server   # then browse http://127.0.0.1:9392
```
(or set `GSA_BIND=0.0.0.0` in `.env` and put it behind HTTPS reverse proxy + firewall.)

## Using it - web UI
1. **Configuration -> Targets -> New Target**: name, hosts (IP, hostname, CIDR like `10.0.0.0/24`), port list `All IANA assigned TCP`.
   Optional: add SSH/SMB credentials for authenticated scans (far more accurate findings).
2. **Scans -> Tasks -> New Task**: pick the target, scan config `Full and fast`, scanner `OpenVAS Default`.
3. Click **Start**. Progress shows in the task list.
4. Open the report: filter by severity (e.g. `severity>7`), then download as PDF/CSV/XML.
5. **Scans -> Schedules** for recurring scans; **Scans -> Alerts** to email reports.

## Using it - command line
```bash
./scripts/scan.sh office-lan 192.168.1.0/24 full   # profiles: full | fast | discovery
./scripts/status.sh                                # progress of all tasks
./scripts/report.sh                                # export last scan to reports/ (pdf)
./scripts/report.sh <report_id> csv                # pdf|html|txt|xml|csv
```

## Maintenance
```bash
./scripts/update-feeds.sh   # run daily/weekly (cron: 0 3 * * * /path/scripts/update-feeds.sh)
./scripts/set-password.sh   # reset admin password to .env value
./scripts/stop.sh           # stop (volumes preserved)
docker compose logs -f gvmd ospd-openvas
```

## Troubleshooting
| Symptom | Fix |
|---|---|
| Scan finishes instantly / 0 results | Feeds not loaded yet. Check `feed-status.sh`; wait. |
| "Scanner not found / unreachable" | `docker compose restart ospd-openvas gvmd`; check logs. |
| Login fails | `./scripts/set-password.sh` |
| Scan very slow | Use `fast` profile, smaller ranges, more RAM/CPU. |
| Targets show "Host dead" | ICMP blocked; set Alive Test to `Consider Alive` on the target. |
| Port 9392 busy | Change `GSA_PORT` in `.env`, then `docker compose up -d`. |

## Notes
- Only scan systems you own or have **written authorization** to test.
- Scans can stress fragile hosts; start with `discovery` or off-hours for production.
- Authenticated scans (SSH/SMB creds) give much better coverage than unauthenticated.
- Official docs: https://greenbone.github.io/docs/latest/22.4/container/

## Test lab: DVWA (vulnerable web app)
Folder `dvwa/` hosts [DVWA](https://github.com/digininja/DVWA) in Docker on an isolated network (`vulnlab`, 172.30.0.0/24).
`docker-compose.lab.yml` attaches the OpenVAS scanner to that network so it can reach DVWA at **172.30.0.10**.

```bash
./scripts/setup.sh          # OpenVAS first (wait for feeds)
./scripts/lab-up.sh         # start DVWA + connect scanner
```
1. Open http://127.0.0.1:4280, log in `admin` / `password`, click **Create / Reset Database**, log in again.
   (Optionally set Security Level to `low` in DVWA Security.)
2. Scan it: `./scripts/scan-dvwa.sh` (or in the UI create a target `172.30.0.10`).
3. Watch: `./scripts/status.sh`, then `./scripts/report.sh`.
4. Remove the lab: `./scripts/lab-down.sh`.

What to expect: OpenVAS is a **network/host** vulnerability scanner. It will report things like outdated
Apache/PHP versions, missing HTTP security headers, exposed services and default-credential checks.
It will NOT reliably find DVWA's built-in web bugs (SQL injection, XSS, command injection, file upload).
For those, add OWASP ZAP or Burp against http://127.0.0.1:4280 (a ZAP baseline example is below).

```bash
docker run --rm --network vulnlab -v "$PWD/reports:/zap/wrk" ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py -t http://172.30.0.10 -r zap-dvwa.html
```
DVWA is intentionally insecure: never expose it to the internet (it is bound to 127.0.0.1 here).

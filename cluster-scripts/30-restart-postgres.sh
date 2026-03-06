#!/usr/bin/env bash
set -Eeo pipefail
echo "Restarting PostgreSQL to apply configuration changes..."
pg_ctl -D "$PGDATA" -m fast restart

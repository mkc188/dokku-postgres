#!/usr/bin/env bash
set -Eeo pipefail
echo "host all all 0.0.0.0/0 md5" >> "$PGDATA/pg_hba.conf"
echo "host all all ::/0 md5" >> "$PGDATA/pg_hba.conf"
pg_ctl -D "$PGDATA" -m fast reload

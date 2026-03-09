#!/usr/bin/env bash
set -Eeo pipefail
echo "host all all 0.0.0.0/0 md5" >> "$PGDATA/pg_hba.conf"
echo "host all all ::/0 md5" >> "$PGDATA/pg_hba.conf"
if command -v gosu >/dev/null 2>&1; then
  gosu postgres pg_ctl -D "$PGDATA" -m fast reload
else
  su - postgres -c "pg_ctl -D \"$PGDATA\" -m fast reload"
fi

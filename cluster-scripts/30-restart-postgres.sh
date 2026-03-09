#!/usr/bin/env bash
set -Eeo pipefail
echo "Restarting PostgreSQL to apply configuration changes..."
if command -v gosu >/dev/null 2>&1; then
  gosu postgres pg_ctl -D "$PGDATA" -m fast restart
else
  su - postgres -c "pg_ctl -D \"$PGDATA\" -m fast restart"
fi

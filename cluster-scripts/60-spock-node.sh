#!/usr/bin/env bash
set -Eeo pipefail
: "${NODE_NAME:?NODE_NAME not set}"
DB="${POSTGRES_DB:-example_db}"
# Admin executor (local)
ADMIN="${POSTGRES_USER:-admin}"
ADMIN_PASS="${POSTGRES_PASSWORD}"
# Replication user (used in DSNs)
REPL_USER="${PGEDGE_USER:-pgedge}"
REPL_PASS="${PGEDGE_PASSWORD:-password}"
# Use external host and port for node connectivity
HOST="${EXTERNAL_HOST:-postgres-${NODE_NAME}}"
PORT="${EXTERNAL_PORT:-5432}"
export PGPASSWORD="${ADMIN_PASS}"
echo "[spock-node] Ensuring replication role '$REPL_USER' exists and is configured..."
EXISTS=$(psql -tA -U "$ADMIN" -d "$DB" -c "SELECT 1 FROM pg_roles WHERE rolname = '$REPL_USER' LIMIT 1;" || true)
if [ "$EXISTS" != "1" ]; then
  psql -v ON_ERROR_STOP=1 -U "$ADMIN" -d "$DB" \
    -c "CREATE ROLE \"$REPL_USER\" LOGIN REPLICATION PASSWORD '$REPL_PASS';"
else
  psql -v ON_ERROR_STOP=1 -U "$ADMIN" -d "$DB" \
    -c "ALTER ROLE \"$REPL_USER\" LOGIN REPLICATION PASSWORD '$REPL_PASS';"
fi
# Practical privileges (safe to re-run)
psql -v ON_ERROR_STOP=1 -U "$ADMIN" -d "$DB" -c "GRANT pg_read_all_data TO \"$REPL_USER\";"
psql -v ON_ERROR_STOP=1 -U "$ADMIN" -d "$DB" -c "GRANT pg_write_all_data TO \"$REPL_USER\";"
psql -v ON_ERROR_STOP=1 -U "$ADMIN" -d "$DB" -c "GRANT CREATE, TEMP ON DATABASE \"$DB\" TO \"$REPL_USER\";"
psql -v ON_ERROR_STOP=1 -U "$ADMIN" -d "$DB" -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO \"$REPL_USER\";"
psql -v ON_ERROR_STOP=1 -U "$ADMIN" -d "$DB" -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO \"$REPL_USER\";"
psql -v ON_ERROR_STOP=1 -U "$ADMIN" -d "$DB" -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO \"$REPL_USER\";"
echo "[spock-node] Ensuring spock node '${NODE_NAME}' exists (dsn uses '${REPL_USER}')..."
NODE_EXISTS=$(psql -tA -U "$ADMIN" -d "$DB" -c "SELECT 1 FROM spock.node WHERE node_name='${NODE_NAME}' LIMIT 1;" || true)
if [ "$NODE_EXISTS" != "1" ]; then
  psql -v ON_ERROR_STOP=1 -U "$ADMIN" -d "$DB" \
    -c "SELECT spock.node_create(node_name := '${NODE_NAME}', dsn := 'host=${HOST} port=${PORT} dbname=${DB} user=${REPL_USER} password=${REPL_PASS}');"
  echo "[spock-node] node '${NODE_NAME}' created."
else
  echo "[spock-node] node '${NODE_NAME}' already present; skipping."
fi

#!/usr/bin/env bash
set -Eeo pipefail
PGCONF="$PGDATA/postgresql.conf"
echo "Initializing required configuration parameters in postgresql.conf"
# Allow connections from any address (for demo purposes)
echo "listen_addresses = '*'" >> "$PGCONF"
# Enable logical replication
echo "wal_level = 'logical'" >> "$PGCONF"
echo "max_worker_processes = 10" >> "$PGCONF"
echo "max_replication_slots = 10" >> "$PGCONF"
echo "max_wal_senders = 10" >> "$PGCONF"
echo "track_commit_timestamp = 'on'" >> "$PGCONF"
# Set Spock parameters
echo "spock.enable_ddl_replication = 'on'" >> "$PGCONF"
echo "spock.include_ddl_repset = 'on'" >> "$PGCONF"
echo "spock.allow_ddl_from_functions = 'on'" >> "$PGCONF"
echo "spock.conflict_resolution = 'last_update_wins'" >> "$PGCONF"
echo "spock.save_resolutions = 'on'" >> "$PGCONF"
echo "spock.conflict_log_level = 'DEBUG'" >> "$PGCONF"

# Set LOLOR and Snowflake parameters
echo "lolor.node = '${NODE_ORDINAL}'" >> "$PGCONF"
echo "snowflake.node_id = '${NODE_ORDINAL}'" >> "$PGCONF"

# Setup pg_cron
echo "cron.database_name = '${POSTGRES_DB:-example_db}'" >> "$PGCONF"

#!/usr/bin/env bash
set -Eeo pipefail
EXTENSIONS=("pg_stat_statements" "pgaudit" "snowflake" "spock" "postgis-3" "pg_stat_monitor" "pg_tokenizer" "pg_cron" "vectorize" "pgedge_vectorizer")
PGCONF="$PGDATA/postgresql.conf"
echo "Setting shared_preload_libraries to: ${EXTENSIONS[*]}"
LIBS=$(IFS=','; echo "${EXTENSIONS[*]}")
if grep -q '^[ ]*shared_preload_libraries' "$PGCONF"; then
  sed -i "s|^[ ]*shared_preload_libraries.*|shared_preload_libraries = '$LIBS'|" "$PGCONF"
else
  echo "shared_preload_libraries = '$LIBS'" >> "$PGCONF"
fi

#!/usr/bin/env bash
set -Eeo pipefail
EXTENSIONS=("pg_stat_statements" "pgaudit" "snowflake" "spock" "vector" "postgis" "lolor" "pgmq" "pg_cron" "pg_stat_monitor" "pg_tokenizer" "vectorize" "pgedge_vectorizer")
echo "Initializing extensions: ${EXTENSIONS[*]}"
for EXT in "${EXTENSIONS[@]}"; do
  echo "Creating extension: $EXT"
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c "CREATE EXTENSION IF NOT EXISTS \"$EXT\";"
done

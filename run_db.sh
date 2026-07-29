#!/usr/bin/env bash

# Load environment variables
if [ -f .env ]; then
  set -a
  source .env
  set +a
fi

echo "postgresql://${DB_USERNAME}:****@${DB_HOSTNAME}:${DB_PORT}/${DB_NAME}"
psql postgresql://${DB_USERNAME}:${DB_PASSWORD}@${DB_HOSTNAME}:${DB_PORT}/${DB_NAME}

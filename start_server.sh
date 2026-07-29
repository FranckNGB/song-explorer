#!/usr/bin/env bash

# Load environment variables
if [ -f .env ]; then
  set -a
  env_error=$(source .env 2>&1)
  if [ $? -eq 0 ]; then
    source .env
    echo -e "\033[0;32m[OK] Environment variables loaded from .env\033[0m"
  else
    echo -e "\033[0;31m[KO] Failed to load .env file\033[0m"
    echo -e "\033[0;31m$env_error\033[0m"
  fi
  set +a
else
  echo -e "\033[0;33m[WARNING] No .env file found. Please create one from .env.example: cp .env.example .env\033[0m"
fi

echo "Starting SongExplorer server..."
mix phx.server

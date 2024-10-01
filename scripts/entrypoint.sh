#!/bin/bash
set -e

# Construct the DATABASE_URL
export DATABASE_URL="ecto://${DB_USER}:${DB_PASSWORD}@${DB_HOST}/${DB_NAME}"

# Execute the application start command
exec "$@"

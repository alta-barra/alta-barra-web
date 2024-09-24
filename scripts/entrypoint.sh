#!/bin/bash
set -e

# Construct the DATABASE_URL from environment variables
export DATABASE_URL="ecto://${DB_USERNAME}:${DB_PASSWORD}@${DB_HOST}/${DB_NAME}"

echo "DATABASE_URL constructed: $DATABASE_URL"

# Start the application (replace this with your actual start command)
exec "$@"

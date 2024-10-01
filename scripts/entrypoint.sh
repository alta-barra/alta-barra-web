#!/bin/bash
set -e

# Ensure required environment variables are set
: "${DB_USERNAME:?Need to set DB_USERNAME}"
: "${DB_PASSWORD:?Need to set DB_PASSWORD}"
: "${DB_HOST:?Need to set DB_HOST}"
: "${DB_NAME:?Need to set DB_NAME}"

# Construct the DATABASE_URL
export DATABASE_URL="ecto://${DB_USERNAME}:${DB_PASSWORD}@${DB_HOST}/${DB_NAME}"

# Execute the application start command
exec "$@"

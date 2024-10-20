#!/bin/bash

# Function to check if a container is running
is_container_running() {
    podman ps --format '{{.Names}}' | grep -q "^$1$"
}

# Function to restart a container
restart_container() {
    echo "Restarting $1 container..."
    podman-compose -f compose.yml restart $1
}

# Check if the database container is running
if ! is_container_running "alta-barra-pgsql-local"; then
    echo "Database container is not running. Starting it now..."
    podman-compose -f compose.yml up -d db
    # Wait for the database to be ready
    echo "Waiting for the database to be ready..."
    until podman exec alta-barra-pgsql-local pg_isready -U ${DB_USERNAME:-altabarra}; do
        sleep 2
    done
    echo "Database is ready!"
else
    echo "Database container is already running. Restarting it..."
    restart_container db
fi

# Restart all other services
echo "Restarting all services..."
podman-compose -f compose.yml restart

echo "Dev environment has been restarted and is now ready!"

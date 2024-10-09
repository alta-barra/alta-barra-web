#!/bin/bash

# Tofu Destroy Script

# Set the base directory
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Function to display usage information
usage() {
    echo "Usage: $0 <environment>"
    echo "  environment: staging or production"
    exit 1
}

# Check if environment is provided
if [ $# -lt 1 ]; then
    usage
fi

ENVIRONMENT=$1

# Validate environment
if [[ "$ENVIRONMENT" != "staging" && "$ENVIRONMENT" != "production" ]]; then
    echo "Invalid environment. Use 'staging' or 'production'."
    exit 1
fi

# Set the environment directory
ENV_DIR="$BASE_DIR/environments/$ENVIRONMENT"

# Check if the environment directory exists
if [ ! -d "$ENV_DIR" ]; then
    echo "Environment directory not found: $ENV_DIR"
    exit 1
fi

# Function to run Tofu commands
run_tofu() {
    local cmd=$1
    echo "Running: tofu $cmd"
    tofu init
    tofu $cmd -var-file="$ENV_DIR/opentofu.tfvars"
}

# Change to the environment directory
cd "$ENV_DIR"

# Confirm destroy action
echo "WARNING: This will destroy all resources in the $ENVIRONMENT environment."
read -p "Are you absolutely sure you want to proceed? (yes/NO) " confirm

if [[ $confirm == "yes" ]]; then
    echo "Proceeding with destroy operation..."
    run_tofu "destroy -auto-approve"
    echo "Tofu destroy completed for $ENVIRONMENT environment."
else
    echo "Destroy operation cancelled."
fi


#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Function to display usage information
usage() {
    echo "Usage: $0 <environment> [action]"
    echo "  environment: dev, staging, or production"
    echo "  action: plan (default) or apply"
    exit 1
}

# Check if environment is provided
if [ $# -lt 1 ]; then
    usage
fi

ENVIRONMENT=$1
ACTION=${2:-plan}

# Validate environment
if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "staging" && "$ENVIRONMENT" != "production" ]]; then
    echo "Invalid environment. Use 'dev', 'staging', or 'production'."
    exit 1
fi

# Validate action
if [[ "$ACTION" != "plan" && "$ACTION" != "apply" ]]; then
    echo "Invalid action. Use 'plan' or 'apply'."
    exit 1
fi

# Set the environment tfvars file
ENV_TFVARS="$BASE_DIR/environments/$ENVIRONMENT/opentofu.tfvars"

# Check if the environment tfvars file exists
if [ ! -f "$ENV_TFVARS" ]; then
    echo "Environment tfvars file not found: $ENV_TFVARS"
    exit 1
fi

# Function to run Tofu commands
run_tofu() {
    local cmd=$1
    echo "Running: tofu $cmd"
    tofu init
    tofu $cmd -var-file="$BASE_DIR/opentofu.tfvars" -var-file="$ENV_TFVARS"
}

# Change to the base directory
cd "$BASE_DIR"

tofu init

export TF_VAR_hash=$(openssl rand -hex 12)
export TF_VAR_public_ec2_key=$(cat ~/.ssh/id_rsa.pub)
export TF_VAR_secret_key_base="ZyW7r1MbYYdDKNYDRZxANhhuyW4FzU54hQgyebmV2iGyWQtF8PuUccGtAgDkZ0Cu"
export TF_VAR_service_name="alta-barra-webapp"

# Execute the appropriate Tofu command
case $ACTION in
    plan)
        run_tofu "plan"
        ;;
    apply)
        run_tofu "plan"
        read -p "Do you want to apply these changes? (y/N) " confirm
        if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
            run_tofu "apply -auto-approve"
        else
            echo "Apply operation cancelled."
        fi
        ;;
esac

echo "Tofu $ACTION completed for $ENVIRONMENT environment."

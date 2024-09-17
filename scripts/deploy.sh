#!/bin/bash
set -e

## Bootstrap =================================================================
# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for Terraform and OpenTofu
if command_exists tofu; then
    INFRA_TOOL="tofu"
elif command_exists terraform; then
    INFRA_TOOL="terraform"
else
    echo "Error: Neither OpenTofu nor Terraform is installed."
    exit 1
fi

# Check for Docker and Podman
if command_exists docker; then
    CONTAINER_TOOL="docker"
elif command_exists podman; then
    CONTAINER_TOOL="podman"
else
    echo "Error: Neither Docker nor Podman is installed."
    exit 1
fi

# Use the selected tool
echo "Using $INFRA_TOOL and $CONTAINER_TOOL"
$INFRA_TOOL "$@"

## Deployment ================================================================
# Generate a random hash
HASH=$(openssl rand -hex 12)

# Navigate to the infra directory
cd "$(dirname "$0")/../infra" || exit

## Initialize OpenTofu/Terraform
$INFRA_TOOL init

# Generate the OpenTofu plan file
$INFRA_TOOL plan \
      -var "hash=${HASH}" \
      -var-file="environments/prod/terraform.tfvars" \
      -out=infrastructure.tf.plan

# Provision resources
$INFRA_TOOL apply -auto-approve infrastructure.tf.plan
rm -rf infrastructure.tf.plan

## Read ECR repository URL to push Docker image with app to registry
REPOSITORY_URL=$($INFRA_TOOL output -raw ecr_repository_url)
REPOSITORY_BASE_URL=$(sed -r 's#([^/])/[^/].*#\1#' <<< ${REPOSITORY_URL})
aws ecr get-login-password --region us-east-1 | \
    podman login --username AWS --password-stdin ${REPOSITORY_BASE_URL}

# Navigate back to the root directory
cd ../

## Build Docker image and tag new versions for every deployment
APP_NAME=${1:-webapp}
podman build --platform linux/amd64 -t altabarra/${APP_NAME} .
podman tag altabarra/${APP_NAME}:latest ${REPOSITORY_URL}:latest
podman tag altabarra/${APP_NAME}:latest ${REPOSITORY_URL}:${HASH}
podman push ${REPOSITORY_URL}:latest
podman push ${REPOSITORY_URL}:${HASH}

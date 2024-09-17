#!/bin/bash
set -e

# Generate a random hash
HASH=$(openssl rand -hex 12)

# Navigate to the infra directory
cd "$(dirname "$0")/../infra" || exit

## Initialize Tofu/Terraform
tofu init

# Generate the OpenTofu plan file
tofu plan \
     -var "hash=${HASH}" \
     -var-file="environments/prod/terraform.tfvars" \
     -out=infrastructure.tf.plan

# Provision resources
tofu apply -auto-approve infrastructure.tf.plan
rm -rf infrastructure.tf.plan

## Read ECR repository URL to push Docker image with app to registry
REPOSITORY_URL=$(tofu output -raw ecr_repository_url)
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

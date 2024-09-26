#!/bin/bash
set -e

## Bootstrap =================================================================
# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

## Handle Inputs ============================================================
TARGET_ENV=${1:-prod}
APP_NAME=${2:-webapp}

## Deploy Infrastructure  ====================================================
echo "STAGE: Infrastructure Deployment"

# Generate a random hash
HASH=$(openssl rand -hex 12)

# Navigate to the infra directory
cd "$(dirname "$0")/../infra" || exit

## Initialize OpenTofu/Terraform
tofu init

# Generate the OpenTofu plan file
tofu plan \
     -var "hash=${HASH}" \
     -var-file="environments/${TARGET_ENV}/terraform.tfvars" \
     -out=infrastructure.tf.plan

# Provision resources
tofu apply -auto-approve infrastructure.tf.plan
rm -rf infrastructure.tf.plan

# Read ECR repository URL to push Docker image with app to registry
REPOSITORY_URL=$(tofu output -raw ecr_repository_url)
REPOSITORY_BASE_URL=$(sed -r 's#([^/])/[^/].*#\1#' <<< ${REPOSITORY_URL})
aws ecr get-login-password --region us-east-1 | \
    docker login --username AWS --password-stdin ${REPOSITORY_BASE_URL}

# Retrieve the ECS cluster and service name from Terraform output
ECS_CLUSTER=$(tofu output -raw ecs_cluster_name)
ECS_SERVICE=$(tofu output -raw ecs_service_name)

# Navigate back to the root directory
cd ../

## Deploy Application ========================================================
echo "STAGE: Application image deployment"

# Build Docker image and tag new versions for every deployment
docker build --platform linux/amd64 -t altabarra/${APP_NAME} .
docker tag altabarra/${APP_NAME}:latest ${REPOSITORY_URL}:latest
docker tag altabarra/${APP_NAME}:latest ${REPOSITORY_URL}:${HASH}
docker push ${REPOSITORY_URL}:latest
docker push ${REPOSITORY_URL}:${HASH}

echo "Deployment [${HASH}] Completed"
echo "Ready for cluster update via `aws ecs update-servcie --cluster ... --service ... --force-new-deployment`"
echo "Before to run any DB migrations"
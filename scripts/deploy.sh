#!/bin/bash
set -e

## Bootstrap =================================================================
# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

## Deploy Infrastructure  ====================================================
# Generate a random hash
HASH=$(openssl rand -hex 12)

# Navigate to the infra directory
cd "$(dirname "$0")/../infra" || exit

## Initialize OpenTofu/Terraform
tofu init

# Generate the OpenTofu plan file
tofu plan \
     -var "hash=${HASH}" \
     -var-file="environments/prod/terraform.tfvars" \
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
# Build Docker image and tag new versions for every deployment
APP_NAME=${1:-webapp}
docker build --platform linux/amd64 -t altabarra/${APP_NAME} .
docker tag altabarra/${APP_NAME}:latest ${REPOSITORY_URL}:latest
docker tag altabarra/${APP_NAME}:latest ${REPOSITORY_URL}:${HASH}
docker push ${REPOSITORY_URL}:latest
docker push ${REPOSITORY_URL}:${HASH}

## Update ECS Service ========================================================
# Trigger ECS service update to refresh tasks with the new image
aws ecs update-service \
    --cluster ${ECS_CLUSTER} \
    --service ${ECS_SERVICE} \
    --force-new-deployment

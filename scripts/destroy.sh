#!/bin/bash
set -e

START_DIR=$(pwd)

cleanup() {
    cd "$START_DIR"
}
trap cleanup EXIT

# Change to the infra directory
cd "$(dirname "$0")/../infra" || exit 1

# Initialize OpenTofu/Terraform
tofu init

# Function to get ECS service and cluster names
get_ecs_info() {
    ECS_SERVICE_NAME=$(tofu output -state=terraform.tfstate -raw ecs_service_name)
    ECS_CLUSTER_NAME=$(tofu output -state=terraform.tfstate -raw ecs_cluster_name)
    printf '%s\n' "Using ECS Service name '${ECS_SERVICE_NAME}'." >&2
    printf '%s\n' "Using ECS Cluster name '${ECS_CLUSTER_NAME}'." >&2
}

# Function to update ECS service
update_ecs_service() {
    aws ecs update-service --cluster "$ECS_CLUSTER_NAME" --service "$ECS_SERVICE_NAME" --desired-count 0 --no-cli-pager
    printf '%s\n' "'desired_count' of ECS Tasks has been set to 0." >&2
}

# Function to deregister ECS task definition
deregister_task() {
    TASK_ARN=$(aws ecs describe-services --cluster "$ECS_CLUSTER_NAME" --services "$ECS_SERVICE_NAME" --no-cli-pager --query 'services[*].[taskDefinition]' --output text)
    printf '%s\n' "Task ARN to be deregistered: ${TASK_ARN}" >&2
    aws ecs deregister-task-definition --task-definition "$TASK_ARN" --no-cli-pager
    printf '%s\n' "Task deregistered." >&2
}

# Function to delete ECS service
delete_ecs_service() {
    SERVICE_STATUS=$(aws ecs describe-services --cluster "$ECS_CLUSTER_NAME" --services "$ECS_SERVICE_NAME" --query 'services[*].[status]' --output text)
    if [[ $SERVICE_STATUS == "DRAINING" ]]; then
        printf '%s\n' "ECS Service is in status 'DRAINING'. Deployment might fail. Check README for more information before re-running this command." >&2
        exit 1
    else
        printf '%s\n' "ECS Service is in status '${SERVICE_STATUS}', deleting now to avoid draining issues..." >&2
        aws ecs delete-service --cluster "$ECS_CLUSTER_NAME" --service "$ECS_SERVICE_NAME" --no-cli-pager
        printf '%s\n' "ECS Service successfully deleted." >&2
    fi
}

# Function to empty the ECR repository
empty_ecr_repo() {
    IMAGE_IDS=$(aws ecr list-images --repository-name "$ECR_REPO_NAME" --query 'imageIds[*]' --output json)

    if [[ $IMAGE_IDS != "[]" ]]; then
        aws ecr batch-delete-image --repository-name "$ECR_REPO_NAME" --image-ids "$IMAGE_IDS" --no-cli-pager
        printf '%s\n' "All images deleted from ECR repository '${ECR_REPO_NAME}'." >&2
    else
        printf '%s\n' "No images found in ECR repository '${ECR_REPO_NAME}'." >&2
    fi
}

# Function to destroy tofu/terraform resources
destroy_tofu() {
    printf '%s\n' "Running 'tofu destroy' now." >&2
    tofu destroy -var hash=null -auto-approve
}

# Main logic =================================================================
get_ecs_info
update_ecs_service
deregister_task
delete_ecs_service
empty_ecr_repo
destroy_tofu
## Return to the start directory (handled by trap)

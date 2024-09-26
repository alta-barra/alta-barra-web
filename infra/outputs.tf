output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.default.name
}

output "ecs_service_name" {
  value = aws_ecs_service.service.name
}

output "rds_db_instance_endpoint" {
  value = module.rds.db_endpoint
}

output "migration_task_definition_arn" {
  value       = aws_ecs_task_definition.migration_task.arn
  description = "ARN of the migration task definition"
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "IDs of the private subnets"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "IDs of the public subnets"
}

output "ecs_security_group_id" {
  value       = aws_security_group.ecs_instances.id
  description = "ID of the security group for ECS tasks and services"
}

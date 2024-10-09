# output "rds_db_instance_endpoint" {
#   value = module.rds.db_endpoint
# }

# output "private_subnet_ids" {
#   value       = values(aws_subnet.private)[*].id
#   description = "IDs of the private subnets"
# }

# output "public_subnet_ids" {
#   value       = values(aws_subnet.public)[*].id
#   description = "IDs of the public subnets"
# }

# output "ecs_security_group_id" {
#   value       = aws_security_group.ecs_instances.id
#   description = "ID of the security group for ECS tasks and services"
# }
